import Foundation
import HealthKit
import Combine

@MainActor
public final class HealthKitManager: ObservableObject {
    public static let shared = HealthKitManager()
    
    private let healthStore = HKHealthStore()
    
    @Published public var estaDisponible: Bool = HKHealthStore.isHealthDataAvailable()
    @Published public var estaAutorizado: Bool = false
    @Published public var kmHoy: Double = 0.0
    @Published public var kmSemana: Double = 0.0
    @Published public var estaSincronizando: Bool = false
    @Published public var ultimaSincronizacion: Date? = nil
    @Published public var mensajeEstado: String = ""
    
    private init() {
        verificarEstadoAutorizacion()
    }
    
    public func verificarEstadoAutorizacion() {
        guard estaDisponible else {
            mensajeEstado = "Apple Health no está disponible en este dispositivo."
            return
        }
        
        guard let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceCycling) else { return }
        let status = healthStore.authorizationStatus(for: distanceType)
        estaAutorizado = (status == .sharingAuthorized)
    }
    
    public func solicitarPermisos() async -> Bool {
        guard estaDisponible else { return false }
        
        guard let distanceCycling = HKQuantityType.quantityType(forIdentifier: .distanceCycling),
              let workoutType = HKObjectType.workoutType() as? HKWorkoutType else {
            return false
        }
        
        let readTypes: Set<HKObjectType> = [distanceCycling, workoutType]
        let shareTypes: Set<HKSampleType> = [distanceCycling, workoutType]
        
        do {
            try await healthStore.requestAuthorization(toShare: shareTypes, read: readTypes)
            estaAutorizado = true
            await leerKmSemanaYHoy()
            return true
        } catch {
            mensajeEstado = "No se concedieron permisos de Apple Health: \(error.localizedDescription)"
            return false
        }
    }
    
    public func leerKmSemanaYHoy() async {
        guard estaDisponible, let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceCycling) else { return }
        
        let calendar = Calendar.current
        let ahora = Date()
        
        // 1. Calcular km de Hoy
        let inicioHoy = calendar.startOfDay(for: ahora)
        kmHoy = await consultarDistancia(tipo: distanceType, inicio: inicioHoy, fin: ahora)
        
        // 2. Calcular km de la Semana actual (desde el lunes)
        let componentesSemana = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: ahora)
        let inicioSemana = calendar.date(from: componentesSemana) ?? inicioHoy
        kmSemana = await consultarDistancia(tipo: distanceType, inicio: inicioSemana, fin: ahora)
        
        ultimaSincronizacion = Date()
    }
    
    private func consultarDistancia(tipo: HKQuantityType, inicio: Date, fin: Date) async -> Double {
        return await withCheckedContinuation { continuation in
            let predicate = HKQuery.predicateForSamples(withStart: inicio, end: fin, options: .strictStartDate)
            let query = HKStatisticsQuery(quantityType: tipo, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, stats, _ in
                guard let sum = stats?.sumQuantity() else {
                    continuation.resume(returning: 0.0)
                    return
                }
                let km = sum.doubleValue(for: .meter()) / 1000.0
                continuation.resume(returning: km)
            }
            healthStore.execute(query)
        }
    }
    
    public func sincronizarConServidor(userId: String) async -> Bool {
        guard !userId.isEmpty else { return false }
        estaSincronizando = true
        await leerKmSemanaYHoy()
        
        do {
            let kmTotalesAproximados = kmSemana // Base acumulada
            try await SupabaseService.shared.sincronizarKmSalud(
                userId: userId,
                kmHoy: kmHoy,
                kmSemana: kmSemana,
                kmTotales: kmTotalesAproximados
            )
            estaSincronizando = false
            mensajeEstado = "Sincronizado con éxito: \(String(format: "%.1f", kmHoy)) km hoy / \(String(format: "%.1f", kmSemana)) km semana."
            return true
        } catch {
            estaSincronizando = false
            mensajeEstado = "Error al sincronizar con Supabase: \(error.localizedDescription)"
            return false
        }
    }
}
