import Foundation
import SwiftUI

@MainActor
public final class ComerciosViewModel: ObservableObject {
    @Published public var recompensas: [RecompensaUiModel] = []
    @Published public var comercios: [Comercio] = []
    @Published public var comercioSeleccionado: Comercio? = nil
    @Published public var categoriaSeleccionada: String = "Todos"
    @Published public var textoBusqueda: String = ""
    @Published public var estaCargando: Bool = false
    @Published public var recompensaSeleccionada: RecompensaUiModel? = nil
    
    // Estado de Canje
    @Published public var codigoCanjeGenerado: String? = nil
    @Published public var canjeando: Bool = false
    @Published public var mostrarDialogoCanje: Bool = false
    @Published public var errorCanje: String? = nil
    
    public let categorias = ["Todos", "Restauración", "Deportes", "Cultura", "Moda"]
    
    public static let fallbackPamplona: [RecompensaUiModel] = [
        RecompensaUiModel(
            id: 1,
            comercioId: 101,
            comercioNombre: "Cafetería La Estafeta",
            direccion: "Calle Estafeta, 12, Pamplona",
            titulo: "Café Orgánico Gratis",
            descripcion: "Disfruta de un café artesanal 100% ecológico por acudir en transporte sostenible.",
            precio: 40,
            categoria: "Restauración",
            latitud: 42.8168,
            longitud: -1.6432,
            logoUrl: "https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=500"
        ),
        RecompensaUiModel(
            id: 2,
            comercioId: 102,
            comercioNombre: "Bicicletas San Ignacio",
            direccion: "Avenida San Ignacio, 8, Pamplona",
            titulo: "15% Descuento en Puesta a Punto",
            descripcion: "Revisión completa de frenos, cadena y presión de neumáticos para tu bici.",
            precio: 100,
            categoria: "Deportes",
            latitud: 42.8145,
            longitud: -1.6410,
            logoUrl: "https://images.unsplash.com/photo-1485965120184-e220f721d03e?w=500"
        ),
        RecompensaUiModel(
            id: 3,
            comercioId: 103,
            comercioNombre: "Librería Gómez",
            direccion: "Calle San Antón, 15, Pamplona",
            titulo: "10% en Libros de Viajes y Naturaleza",
            descripcion: "Válido para cualquier libro de la sección de naturaleza y rutas de Navarra.",
            precio: 80,
            categoria: "Cultura",
            latitud: 42.8130,
            longitud: -1.6450,
            logoUrl: "https://images.unsplash.com/photo-1524995997946-a1c2e315a42f?w=500"
        ),
        RecompensaUiModel(
            id: 4,
            comercioId: 104,
            comercioNombre: "Moda Sostenible Pamplona",
            direccion: "Calle Zapatería, 22, Pamplona",
            titulo: "Bono de 5€ en ropa ecológica",
            descripcion: "Aplicable a compras superiores a 25€ en prendas hechas con algodón orgánico.",
            precio: 120,
            categoria: "Moda",
            latitud: 42.8155,
            longitud: -1.6440,
            logoUrl: "https://images.unsplash.com/photo-1489987707025-afc232f7ea0f?w=500"
        ),
        RecompensaUiModel(
            id: 7,
            comercioId: 10,
            comercioNombre: "Artázcoz",
            direccion: "C/ Mayor, 5, Pamplona",
            titulo: "10% Dto. en Ropa",
            descripcion: "10% de descuento en prendas sostenibles de colección actual.",
            precio: 500,
            categoria: "Moda",
            latitud: 42.820454,
            longitud: -1.641087,
            logoUrl: "https://wtfwkwmvczzyrgdamkpk.supabase.co/storage/v1/object/public/logos/gemini_generated_image_5t4hcx5t4hcx5t4h_1793481454412.jpg"
        )
    ]
    
    public init() {
        self.recompensas = Self.fallbackPamplona
        Task {
            await cargarRecompensas()
        }
    }
    
    public func cargarComerciosYDescuentos() async {
        await cargarRecompensas()
    }
    
    public func cargarRecompensas() async {
        estaCargando = true
        do {
            let resultado = try await SupabaseService.shared.fetchComerciosYDescuentos()
            var listaCombinada = Self.fallbackPamplona
            for r in resultado {
                if !listaCombinada.contains(where: { $0.id == r.id || $0.comercioNombre == r.comercioNombre }) {
                    listaCombinada.append(r)
                }
            }
            self.recompensas = listaCombinada
        } catch {
            print("Error cargando comercios: \(error)")
            cargarFallback()
        }
        estaCargando = false
    }
    
    private func cargarFallback() {
        self.recompensas = Self.fallbackPamplona
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
    
    public func canjear(recompensa: RecompensaUiModel, usuarioId: String, token: String? = nil) async -> RespuestaCanje {
        canjeando = true
        errorCanje = nil
        do {
            let res = try await SupabaseService.shared.canjearRecompensa(
                userId: usuarioId,
                descuentoId: recompensa.id,
                comercioId: recompensa.comercioId,
                precioKmCoins: recompensa.precio,
                userToken: token
            )
            self.codigoCanjeGenerado = res.codigoCanje
            self.mostrarDialogoCanje = res.exito
            canjeando = false
            return res
        } catch {
            canjeando = false
            let err = error.localizedDescription
            self.errorCanje = err
            return RespuestaCanje(
                exito: false,
                codigoCanje: "",
                mensaje: "No se pudo procesar el canje: \(err)"
            )
        }
    }
}
