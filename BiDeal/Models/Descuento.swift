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

// Definición canónica y unificada de RespuestaCanje (consumida por ApiClient, SupabaseService y DetalleComercioView)
public struct RespuestaCanje: Identifiable, Codable {
    public var id: String { codigoCanje }
    public let exito: Bool
    public let codigoCanje: String
    public let mensaje: String
    public let kmcoinsRestantes: Int?
    
    enum CodingKeys: String, CodingKey {
        case exito
        case status
        case codigoCupon = "codigo_cupon"
        case codigoCanjeAlt = "codigo_canje"
        case mensaje
        case saldoRestante = "saldo_restante"
        case kmcoinsRestantesAlt = "kmcoins_restantes"
    }
    
    public init(exito: Bool, codigoCanje: String, mensaje: String, kmcoinsRestantes: Int? = nil) {
        self.exito = exito
        self.codigoCanje = codigoCanje
        self.mensaje = mensaje
        self.kmcoinsRestantes = kmcoinsRestantes
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let statusStr = try? container.decodeIfPresent(String.self, forKey: .status)
        let exitoBool = try? container.decodeIfPresent(Bool.self, forKey: .exito)
        self.exito = exitoBool ?? (statusStr == "success" || statusStr == "ok")
        
        let cupon = (try? container.decodeIfPresent(String.self, forKey: .codigoCupon))
            ?? (try? container.decodeIfPresent(String.self, forKey: .codigoCanjeAlt))
            ?? ""
        self.codigoCanje = cupon
        
        self.mensaje = (try? container.decodeIfPresent(String.self, forKey: .mensaje)) ?? "Canje realizado con éxito"
        
        self.kmcoinsRestantes = (try? container.decodeIfPresent(Int.self, forKey: .saldoRestante))
            ?? (try? container.decodeIfPresent(Int.self, forKey: .kmcoinsRestantesAlt))
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(exito, forKey: .exito)
        try container.encode(codigoCanje, forKey: .codigoCupon)
        try container.encode(mensaje, forKey: .mensaje)
        try container.encodeIfPresent(kmcoinsRestantes, forKey: .saldoRestante)
    }
}
