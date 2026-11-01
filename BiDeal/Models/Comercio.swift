import Foundation
import CoreLocation

public struct Descuento: Identifiable, Codable {
    public let id: String
    public let comercio_id: String
    public let titulo: String
    public let descripcion: String?
    public let precio_kmcoins: Int
    public let activo: Bool
    
    public init(id: String, comercio_id: String, titulo: String, descripcion: String? = nil, precio_kmcoins: Int = 100, activo: Bool = true) {
        self.id = id
        self.comercio_id = comercio_id
        self.titulo = titulo
        self.descripcion = descripcion
        self.precio_kmcoins = precio_kmcoins
        self.activo = activo
    }
}

public struct Comercio: Identifiable, Codable {
    public let id: String
    public let nombre: String
    public let categoria: String?
    public let direccion: String?
    public let latitud: Double?
    public let longitud: Double?
    public let logo_url: String?
    public let activo: Bool?
    public var descuentos: [Descuento]?
    
    public var coordinate: CLLocationCoordinate2D? {
        guard let lat = latitud, let lon = longitud else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    public var categoriaNormalizada: String {
        guard let cat = categoria?.lowercased() else { return "comercio" }
        if cat.contains("deporte") || cat.contains("bici") || cat.contains("taller") { return "deportes" }
        if cat.contains("cafe") || cat.contains("bar") || cat.contains("restauran") { return "restauracion" }
        if cat.contains("cultur") || cat.contains("libro") || cat.contains("librer") { return "cultura" }
        if cat.contains("salud") || cat.contains("optic") || cat.contains("clinic") { return "salud" }
        return "comercio"
    }
    
    public var emojiCategoria: String {
        switch categoriaNormalizada {
        case "deportes": return "🚲"
        case "restauracion": return "☕"
        case "cultura": return "📚"
        case "salud": return "🌿"
        default: return "🛍️"
        }
    }
}
