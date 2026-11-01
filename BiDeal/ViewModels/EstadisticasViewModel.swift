import Foundation
import SwiftUI
import Combine

public struct DiaEstadistica: Identifiable {
    public var id: String { letra }
    public let letra: String
    public let nombre: String
    public var km: Double
    public let esHoy: Bool
}

@MainActor
public final class EstadisticasViewModel: ObservableObject {
    @Published public var diasSemana: [DiaEstadistica] = []
    @Published public var kmTotalSemana: Double = 0.0
    @Published public var grupo: GrupoCiclistaDto? = nil
    @Published public var miembrosGrupo: [MiembroGrupoDto] = []
    @Published public var estaCargandoGrupo: Bool = false
    @Published public var mensajeToast: String? = nil
    @Published public var mostrarToast: Bool = false
    
    public let minimoParaPremios = 4
    public let maximoGrupo = 20
    
    public init() {
        inicializarDiasSemana()
    }
    
    private func inicializarDiasSemana() {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: Date())
        // En Calendar de Apple: 1 = Domingo, 2 = Lunes, ..., 7 = Sábado
        let hoyIndex = weekday == 1 ? 6 : weekday - 2
        
        self.diasSemana = [
            DiaEstadistica(letra: "L", nombre: "Lunes", km: 0.0, esHoy: hoyIndex == 0),
            DiaEstadistica(letra: "M", nombre: "Martes", km: 0.0, esHoy: hoyIndex == 1),
            DiaEstadistica(letra: "X", nombre: "Miércoles", km: 0.0, esHoy: hoyIndex == 2),
            DiaEstadistica(letra: "J", nombre: "Jueves", km: 0.0, esHoy: hoyIndex == 3),
            DiaEstadistica(letra: "V", nombre: "Viernes", km: 0.0, esHoy: hoyIndex == 4),
            DiaEstadistica(letra: "S", nombre: "Sábado", km: 0.0, esHoy: hoyIndex == 5),
            DiaEstadistica(letra: "D", nombre: "Domingo", km: 0.0, esHoy: hoyIndex == 6)
        ]
    }
    
    // Cargar datos reales desde Supabase RPC
    public func cargarGrupo(userId: String) async {
        guard !userId.isEmpty else { return }
        estaCargandoGrupo = true
        do {
            let res = try await SupabaseService.shared.obtenerGrupoCiclista(userId: userId)
            if res.status == "ok" {
                self.grupo = res.grupo
                self.miembrosGrupo = res.miembros ?? []
            }
        } catch {
            print("Error cargando grupo ciclista en iOS: \(error.localizedDescription)")
        }
        estaCargandoGrupo = false
    }
    
    // Unirse a un grupo por código directo o enlace
    public func unirseAGrupo(userId: String, codigo: String) async -> Bool {
        guard !userId.isEmpty, !codigo.isEmpty else { return false }
        do {
            let res = try await SupabaseService.shared.unirseAGrupo(userId: userId, codigo: codigo)
            await cargarGrupo(userId: userId)
            
            self.mensajeToast = res.mensaje
            self.mostrarToast = true
            return res.status == "ok"
        } catch {
            self.mensajeToast = "No se pudo unir al grupo: \(error.localizedDescription)"
            self.mostrarToast = true
            return false
        }
    }
    
    // Propiedades calculadas en base a datos reales de Supabase
    public var codigoEfectivo: String {
        return grupo?.codigo ?? "BIDEAL"
    }
    
    public var nombreGrupo: String {
        return grupo?.nombre ?? "Liga Ciclista · Grupo"
    }
    
    public var metaKmGrupal: Double {
        return grupo?.meta_km_semanal ?? 200.0
    }
    
    public var boteKmCoins: Int {
        return grupo?.bote_kmcoins ?? 25
    }
    
    public var premioMetaKmCoins: Int {
        return grupo?.premio_meta_kmcoins ?? 10
    }
    
    public var totalMiembros: Int {
        return max(miembrosGrupo.count, 1)
    }
    
    public var kmTotalesGrupo: Double {
        return miembrosGrupo.reduce(0.0) { $0 + $1.km_semana }
    }
    
    public var premiosDesbloqueados: Bool {
        return totalMiembros >= minimoParaPremios
    }
    
    public var metaGrupalAlcanzada: Bool {
        return kmTotalesGrupo >= metaKmGrupal
    }
    
    public var porcentajeMetaGrupal: Double {
        guard metaKmGrupal > 0 else { return 0 }
        return min(max(kmTotalesGrupo / metaKmGrupal, 0.0), 1.0)
    }
    
    public var enlaceDirectoGrupo: String {
        return "https://www.bideal.org/grupo?codigo=\(codigoEfectivo)"
    }
}
