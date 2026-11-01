import Foundation
import SwiftUI
import Combine

public struct MisionUiModel: Identifiable {
    public let id = UUID()
    public let titulo: String
    public let kmObjetivo: Double
    public let kmActuales: Double
    public let recompensaCoins: Int
    
    public var completada: Bool {
        kmActuales >= kmObjetivo
    }
    
    public var progreso: Double {
        min(max(kmActuales / kmObjetivo, 0.0), 1.0)
    }
}

@MainActor
public final class HomeViewModel: ObservableObject {
    @Published public var usuario: Usuario = Usuario.mock
    @Published public var kmHoy: Double = 0.0
    @Published public var distanciaTotal: Double = 0.0
    @Published public var co2Evitado: Double = 0.0
    @Published public var rachaSemanas: Int = 1
    @Published public var proximaCaducidad: String? = nil
    @Published public var caducidadCoins: (cantidad: Int, dias: Int)? = nil
    @Published public var estaCargando: Bool = false
    
    public var distanciaTotalKm: Double { distanciaTotal }
    public var co2TotalEvitadoKg: Double { co2Evitado }
    
    // Lista de misiones diarias (igual a Android)
    public var misionesDiarias: [MisionUiModel] {
        return [
            MisionUiModel(titulo: "Primer pedaleo del día", kmObjetivo: 2.0, kmActuales: kmHoy, recompensaCoins: 10),
            MisionUiModel(titulo: "Vuelta por Pamplona", kmObjetivo: 5.0, kmActuales: kmHoy, recompensaCoins: 25),
            MisionUiModel(titulo: "Reto Urbano Verde", kmObjetivo: 10.0, kmActuales: kmHoy, recompensaCoins: 50),
            MisionUiModel(titulo: "Gran Fondo Sostenible", kmObjetivo: 15.0, kmActuales: kmHoy, recompensaCoins: 100)
        ]
    }
    
    public var siguienteMision: (meta: Double, faltan: Double, progreso: Double, completadoTodo: Bool) {
        let metas: [Double] = [2.0, 5.0, 10.0, 15.0]
        if let meta = metas.first(where: { $0 > kmHoy }) {
            let faltan = meta - kmHoy
            let progreso = min(max(kmHoy / meta, 0.0), 1.0)
            return (meta, faltan, progreso, false)
        } else {
            return (15.0, 0.0, 1.0, true)
        }
    }
    
    public init() {
        sincronizarHealthKitAutomatico()
    }
    
    public func sincronizarHealthKitAutomatico() {
        Task {
            let auth = await HealthKitManager.shared.solicitarPermisos()
            if auth {
                await HealthKitManager.shared.leerKmSemanaYHoy()
                let km = HealthKitManager.shared.kmHoy
                if km > self.kmHoy {
                    self.kmHoy = km
                    self.distanciaTotal += km
                    self.co2Evitado = self.distanciaTotal * 0.142
                    self.usuario.km_hoy = km
                    self.usuario.distancia_total_km = self.distanciaTotal
                }
            }
        }
    }
    
    public func cargarDatosSupabase() async {
        estaCargando = false
    }
    
    public func actualizarConUsuario(_ user: Usuario?) {
        guard let u = user else { return }
        self.usuario = u
        if u.km_hoy > self.kmHoy {
            self.kmHoy = u.km_hoy
        }
        self.distanciaTotal = max(u.distancia_total_km, self.kmHoy)
        self.co2Evitado = self.distanciaTotal * 0.142
        self.rachaSemanas = max(u.racha_oro_semanal, 1)
    }
}
