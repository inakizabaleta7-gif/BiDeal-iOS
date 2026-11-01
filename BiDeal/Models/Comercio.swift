import Foundation
import CoreLocation

public struct Comercio: Identifiable, Codable {
    public let id: Int
    public let nombre: String
    public let categoria: String?
    public let direccion: String?
    public let ciudad: String?
    public let telefono: String?
    public let email_contacto: String?
    public let codigo_qr_comercio: String?
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
        if cat.contains("moda") || cat.contains("ropa") || cat.contains("sostenible") { return "moda" }
        return "comercio"
    }
    
    public var emojiCategoria: String {
        switch categoriaNormalizada {
        case "deportes": return "🚲"
        case "restauracion": return "☕"
        case "cultura": return "📚"
        case "moda": return "👕"
        default: return "🛍️"
        }
    }
}
