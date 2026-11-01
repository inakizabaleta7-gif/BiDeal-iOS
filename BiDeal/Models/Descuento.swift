import Foundation

public struct Descuento: Identifiable, Codable {
    public let id: Int
    public let comercio_id: Int
    public let titulo: String
    public let descripcion: String?
    public let precio_kmcoins: Int
    public let cooldown_horas: Int?
    public let activo: Bool?
    
    public init(
        id: Int,
        comercio_id: Int,
        titulo: String,
        descripcion: String? = nil,
        precio_kmcoins: Int = 100,
        cooldown_horas: Int? = 0,
        activo: Bool? = true
    ) {
        self.id = id
        self.comercio_id = comercio_id
        self.titulo = titulo
        self.descripcion = descripcion
        self.precio_kmcoins = precio_kmcoins
        self.cooldown_horas = cooldown_horas
        self.activo = activo
    }
}

// Modelo unificado exactamente igual a Android (RecompensaUiModel)
public struct RecompensaUiModel: Identifiable, Codable {
    public let id: Int
    public let comercioId: Int
    public let comercioNombre: String
    public let direccion: String
    public let titulo: String
    public let descripcion: String
    public let precio: Int
    public let categoria: String
    public let latitud: Double?
    public let longitud: Double?
    public let logoUrl: String?
    
    public var imagenUrl: String? {
        return logoUrl
    }
    
    public init(
        id: Int,
        comercioId: Int,
        comercioNombre: String,
        direccion: String,
        titulo: String,
        descripcion: String,
        precio: Int,
        categoria: String,
        latitud: Double? = nil,
        longitud: Double? = nil,
        logoUrl: String? = nil
    ) {
        self.id = id
        self.comercioId = comercioId
        self.comercioNombre = comercioNombre
        self.direccion = direccion
        self.titulo = titulo
        self.descripcion = descripcion
        self.precio = precio
        self.categoria = categoria
        self.latitud = latitud
        self.longitud = longitud
        self.logoUrl = logoUrl
    }
}

public struct RespuestaCanje: Codable {
    public let exito: Bool
    public let codigoCanje: String
    public let mensaje: String
    
    public init(exito: Bool, codigoCanje: String, mensaje: String) {
        self.exito = exito
        self.codigoCanje = codigoCanje
        self.mensaje = mensaje
    }
}
