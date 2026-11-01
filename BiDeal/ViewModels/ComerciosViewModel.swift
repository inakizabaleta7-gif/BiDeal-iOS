import Foundation
import SwiftUI

@MainActor
public final class ComerciosViewModel: ObservableObject {
    @Published public var comercios: [Comercio] = []
    @Published public var categoriaSeleccionada: String = "all"
    @Published public var textoBusqueda: String = ""
    @Published public var estaCargando: Bool = false
    @Published public var comercioSeleccionado: Comercio?
    
    public init() {
        Task {
            await cargarComercios()
        }
    }
    
    public func cargarComercios() async {
        estaCargando = true
        do {
            let resultado = try await SupabaseService.shared.fetchComercios()
            self.comercios = resultado
        } catch {
            // Muestra de fallback segura si no hay conexión
            self.comercios = [
                Comercio(
                    id: "1",
                    nombre: "EcoDeportes Central",
                    categoria: "Deportes",
                    direccion: "Av. de Zaragoza, 45, Pamplona",
                    latitud: 42.799341,
                    longitud: -1.634022,
                    logo_url: nil,
                    activo: true,
                    descuentos: [
                        Descuento(id: "d1", comercio_id: "1", titulo: "10% en Accesorios Ciclistas", precio_kmcoins: 100)
                    ]
                ),
                Comercio(
                    id: "2",
                    nombre: "Taller Bicis Eder",
                    categoria: "Taller",
                    direccion: "C/ San Antón, 12, Pamplona",
                    latitud: 42.8166,
                    longitud: -1.6433,
                    logo_url: nil,
                    activo: true,
                    descuentos: [
                        Descuento(id: "d2", comercio_id: "2", titulo: "Ajuste de frenos gratis", precio_kmcoins: 120),
                        Descuento(id: "d3", comercio_id: "2", titulo: "15% en puesta a punto", precio_kmcoins: 180)
                    ]
                ),
                Comercio(
                    id: "3",
                    nombre: "Artázcoz Moda Sostenible",
                    categoria: "Moda Sostenible",
                    direccion: "C/ Mayor, 34, Pamplona",
                    latitud: 42.820454,
                    longitud: -1.641087,
                    logo_url: nil,
                    activo: true,
                    descuentos: [
                        Descuento(id: "d4", comercio_id: "3", titulo: "Vale 5€ en compras", precio_kmcoins: 150)
                    ]
                )
            ]
        }
        estaCargando = false
    }
    
    public var comerciosFiltrados: [Comercio] {
        return comercios.filter { comercio in
            let coincideCat = (categoriaSeleccionada == "all" || comercio.categoriaNormalizada == categoriaSeleccionada)
            let q = textoBusqueda.lowercased().trimmingCharacters(in: .whitespaces)
            let coincideBusqueda = q.isEmpty ||
                comercio.nombre.lowercased().contains(q) ||
                (comercio.direccion?.lowercased().contains(q) ?? false) ||
                (comercio.categoria?.lowercased().contains(q) ?? false)
            return coincideCat && coincideBusqueda
        }
    }
}
