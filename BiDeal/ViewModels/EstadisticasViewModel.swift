import Foundation
import SwiftUI

public struct DiaEstadistica: Identifiable {
    public var id: String { letra }
    public let letra: String
    public let nombre: String
    public let km: Double
    public let esHoy: Bool
}

@MainActor
public final class EstadisticasViewModel: ObservableObject {
    @Published public var diasSemana: [DiaEstadistica] = []
    @Published public var kmTotalSemana: Double = 32.5
    @Published public var numAmigosSimulados: Int = 2
    @Published public var codigoGrupo: String = "BI-PAM77"
    
    public let minimoParaPremios = 4
    public let maximoGrupo = 20
    public let metaKmGrupal = 200.0
    
    public init() {
        self.diasSemana = [
            DiaEstadistica(letra: "L", nombre: "Lunes", km: 4.2, esHoy: false),
            DiaEstadistica(letra: "M", nombre: "Martes", km: 6.8, esHoy: false),
            DiaEstadistica(letra: "X", nombre: "Miércoles", km: 5.1, esHoy: false),
            DiaEstadistica(letra: "J", nombre: "Jueves", km: 7.4, esHoy: false),
            DiaEstadistica(letra: "V", nombre: "Viernes", km: 9.0, esHoy: false),
            DiaEstadistica(letra: "S", nombre: "Sábado", km: 0.0, esHoy: false),
            DiaEstadistica(letra: "D", nombre: "Domingo", km: 0.0, esHoy: true)
        ]
        self.kmTotalSemana = diasSemana.reduce(0) { $0 + $1.km }
    }
    
    public var miembrosLiga: [MiembroLiga] {
        var lista: [MiembroLiga] = [
            MiembroLiga(nombre: "Tú", kmSemana: kmTotalSemana, esUsuario: true),
            MiembroLiga(nombre: "Iker G.", kmSemana: 28.4, esUsuario: false)
        ]
        if numAmigosSimulados >= 3 {
            lista.append(MiembroLiga(nombre: "Jesús A.", kmSemana: 22.1, esUsuario: false))
        }
        if numAmigosSimulados >= 4 {
            lista.append(MiembroLiga(nombre: "Íñigo Y.", kmSemana: 34.5, esUsuario: false))
        }
        if numAmigosSimulados >= 5 {
            lista.append(MiembroLiga(nombre: "Mikel P.", kmSemana: 18.2, esUsuario: false))
        }
        if numAmigosSimulados >= 6 {
            lista.append(MiembroLiga(nombre: "Ainhoa L.", kmSemana: 25.8, esUsuario: false))
        }
        if numAmigosSimulados >= 7 {
            lista.append(MiembroLiga(nombre: "Uxue S.", kmSemana: 31.0, esUsuario: false))
        }
        if numAmigosSimulados >= 8 {
            lista.append(MiembroLiga(nombre: "Xabier E.", kmSemana: 42.6, esUsuario: false))
        }
        return lista.sorted(by: { $0.kmSemana > $1.kmSemana })
    }
    
    public var kmTotalesGrupeta: Double {
        return miembrosLiga.reduce(0) { $0 + $1.kmSemana }
    }
    
    public var premiosDesbloqueados: Bool {
        return numAmigosSimulados >= minimoParaPremios
    }
    
    public var metaGrupalAlcanzada: Bool {
        return kmTotalesGrupeta >= metaKmGrupal
    }
    
    public var porcentajeMetaGrupal: Double {
        return min(max(kmTotalesGrupeta / metaKmGrupal, 0.0), 1.0)
    }
}
