import Foundation
import SwiftUI

@MainActor
public final class HomeViewModel: ObservableObject {
    @Published public var usuario: Usuario
    @Published public var actividadesRecientes: [ActividadCiclista] = []
    @Published public var mostrarModalResumen: Bool = false
    @Published public var ultimaActividad: ActividadCiclista?
    
    public init() {
        self.usuario = Usuario(
            id: "ios-user-dev",
            nombre: "Iñaki Zabaleta",
            kmcoins_balance: 350,
            kilometros_totales: 48.6,
            co2_evitado_kg: 6.31,
            codigo_referido: "BI-PAM77"
        )
    }
    
    public func guardarActividad(_ actividad: ActividadCiclista) {
        actividadesRecientes.insert(actividad, at: 0)
        usuario.kilometros_totales += actividad.distanciaKm
        usuario.co2_evitado_kg += actividad.co2EvitadoKg
        usuario.kmcoins_balance += actividad.kmcoinsGanadas
        
        ultimaActividad = actividad
        mostrarModalResumen = true
    }
}
