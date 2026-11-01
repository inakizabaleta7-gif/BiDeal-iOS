import Foundation
import SwiftUI
import Combine

@MainActor
public final class HomeViewModel: ObservableObject {
    @Published public var usuario: Usuario
    @Published public var actividadesRecientes: [ActividadCiclista] = []
    @Published public var mostrarModalResumen: Bool = false
    @Published public var ultimaActividad: ActividadCiclista?
    @Published public var estaCargando: Bool = false
    
    // ID persistente para iOS
    private let kUserIdKey = "bideal_ios_user_id"
    
    public init() {
        let storedId = UserDefaults.standard.string(forKey: kUserIdKey) ?? "ios-" + UUID().uuidString.prefix(8).lowercased()
        UserDefaults.standard.set(storedId, forKey: kUserIdKey)
        
        self.usuario = Usuario(
            id: storedId,
            nombre: "Ciclista Pamplona",
            genero: "Otro",
            ciudad: "Pamplona",
            distancia_total_km: 0.0,
            co2_total_evitado_kg: 0.0,
            km_hoy: 0.0,
            km_semana: 0.0,
            codigo_referido: "BI-IOS" + storedId.suffix(4).uppercased(),
            plataforma: "ios",
            kmcoins_balance: 150
        )
    }
    
    public func cargarDatosSupabase() async {
        estaCargando = true
        do {
            if let userRemoto = try await SupabaseService.shared.fetchPerfilUsuario(userId: usuario.id) {
                self.usuario = userRemoto
            } else {
                // Registrar nuevo usuario en Supabase con plataforma iOS
                try await SupabaseService.shared.actualizarPerfil(usuario: self.usuario)
            }
        } catch {
            print("Info: Usando perfil local offline (\(error.localizedDescription))")
        }
        estaCargando = false
    }
    
    public func guardarActividad(_ actividad: ActividadCiclista) {
        actividadesRecientes.insert(actividad, at: 0)
        usuario.distancia_total_km += actividad.distanciaKm
        usuario.km_hoy += actividad.distanciaKm
        usuario.km_semana += actividad.distanciaKm
        usuario.co2_total_evitado_kg += actividad.co2EvitadoKg
        usuario.kmcoins_balance += actividad.kmcoinsGanadas
        
        ultimaActividad = actividad
        mostrarModalResumen = true
        
        // Guardar lote en Supabase en segundo plano
        Task {
            do {
                try await SupabaseService.shared.registrarLoteKmCoins(
                    userId: usuario.id,
                    km: actividad.distanciaKm,
                    kmcoins: actividad.kmcoinsGanadas
                )
                try await SupabaseService.shared.sincronizarKmSalud(
                    userId: usuario.id,
                    kmHoy: usuario.km_hoy,
                    kmSemana: usuario.km_semana,
                    kmTotales: usuario.distancia_total_km
                )
            } catch {
                print("Error registrando lote en Supabase: \(error.localizedDescription)")
            }
        }
    }
}
