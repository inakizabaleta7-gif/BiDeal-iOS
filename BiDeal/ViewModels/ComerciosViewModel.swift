import Foundation
import SwiftUI

@MainActor
public final class ComerciosViewModel: ObservableObject {
    @Published public var recompensas: [RecompensaUiModel] = []
    @Published public var categoriaSeleccionada: String = "Todos"
    @Published public var textoBusqueda: String = ""
    @Published public var estaCargando: Bool = false
    @Published public var recompensaSeleccionada: RecompensaUiModel? = nil
    
    // Estado de Canje
    @Published public var codigoCanjeGenerado: String? = nil
    @Published public var canjeando: Bool = false
    @Published public var mostrarDialogoCanje: Bool = false
    @Published public var errorCanje: String? = nil
    
    public let categorias = ["Todos", "Deportes", "Taller", "Moda Sostenible", "Restauración"]
    
    public init() {
        Task {
            await cargarRecompensas()
        }
    }
    
    public func cargarRecompensas() async {
        estaCargando = true
        do {
            let resultado = try await SupabaseService.shared.fetchComerciosYDescuentos()
            if !resultado.isEmpty {
                self.recompensas = resultado
            } else {
                cargarFallback()
            }
        } catch {
            print("Error cargando comercios: \(error)")
            cargarFallback()
        }
        estaCargando = false
    }
    
    private func cargarFallback() {
        self.recompensas = [
            RecompensaUiModel(
                id: 4,
                comercioId: 8,
                comercioNombre: "EcoDeportes Central",
                direccion: "Avenida Comercial 42, Pamplona",
                titulo: "Vale 5€ de Regalo",
                descripcion: "Válido en accesorios ciclistas y material de seguridad.",
                precio: 300,
                categoria: "Deportes",
                latitud: 42.799341,
                longitud: -1.634022,
                logoUrl: "https://www.bideal.org/logos/prueba.jpg"
            ),
            RecompensaUiModel(
                id: 3,
                comercioId: 7,
                comercioNombre: "Taller Bicis Eder",
                direccion: "Calle Estafeta 15, Pamplona",
                titulo: "10% Dto. en Reparación",
                descripcion: "Válido solo para mano de obra y puesta a punto de tu bicicleta.",
                precio: 150,
                categoria: "Taller",
                latitud: 42.8166,
                longitud: -1.6433,
                logoUrl: "https://www.bideal.org/logos/prueba.jpg"
            ),
            RecompensaUiModel(
                id: 7,
                comercioId: 10,
                comercioNombre: "Artázcoz",
                direccion: "C/ Mayor, 5, Pamplona",
                titulo: "10% Dto. en Ropa",
                descripcion: "10% de descuento en prendas sostenibles de colección actual.",
                precio: 500,
                categoria: "Moda Sostenible",
                latitud: 42.820454,
                longitud: -1.641087,
                logoUrl: "https://wtfwkwmvczzyrgdamkpk.supabase.co/storage/v1/object/public/logos/gemini_generated_image_5t4hcx5t4hcx5t4h_1793481454412.jpg"
            )
        ]
    }
    
    public var recompensasFiltradas: [RecompensaUiModel] {
        return recompensas.filter { r in
            let coincideCat = (categoriaSeleccionada == "Todos" || r.categoria.localizedCaseInsensitiveContains(categoriaSeleccionada))
            let q = textoBusqueda.lowercased().trimmingCharacters(in: .whitespaces)
            let coincideBusqueda = q.isEmpty ||
                r.comercioNombre.lowercased().contains(q) ||
                r.titulo.lowercased().contains(q) ||
                r.direccion.lowercased().contains(q) ||
                r.categoria.lowercased().contains(q)
            return coincideCat && coincideBusqueda
        }
    }
    
    public func canjear(recompensa: RecompensaUiModel, userId: String, saldoActual: Int) async -> Bool {
        guard saldoActual >= recompensa.precio else {
            errorCanje = "No tienes suficientes KmCoins (KMC). Saldo actual: \(saldoActual) KMC."
            return false
        }
        
        canjeando = true
        errorCanje = nil
        do {
            let codigo = try await SupabaseService.shared.canjearRecompensa(
                userId: userId,
                descuentoId: recompensa.id,
                comercioId: recompensa.comercioId,
                precioKmCoins: recompensa.precio
            )
            self.codigoCanjeGenerado = codigo
            self.mostrarDialogoCanje = true
            self.canjeando = false
            return true
        } catch {
            self.canjeando = false
            self.errorCanje = "Error al procesar el canje en la tienda. Inténtalo de nuevo."
            return false
        }
    }
}
