import Foundation

public struct Usuario: Identifiable, Codable {
    public let id: String
    public var email: String?
    public var nombre: String?
    public var genero: String?
    public var telefono: String?
    public var ciudad: String?
    public var notificaciones: Bool?
    public var distancia_total_km: Double
    public var co2_total_evitado_kg: Double
    public var km_hoy: Double
    public var km_semana: Double
    public var codigo_referido: String?
    public var referido_por: String?
    public var plataforma: String?
    public var kmcoins_balance: Int
    public var creado_en: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case nombre
        case genero
        case telefono
        case ciudad
        case notificaciones
        case distancia_total_km
        case co2_total_evitado_kg
        case km_hoy
        case km_semana
        case codigo_referido
        case referido_por
        case plataforma
        case kmcoins_balance
        case creado_en
    }
    
    public init(
        id: String,
        email: String? = nil,
        nombre: String? = "Ciclista",
        genero: String? = "Otro",
        telefono: String? = nil,
        ciudad: String? = "Pamplona",
        notificaciones: Bool? = true,
        distancia_total_km: Double = 0.0,
        co2_total_evitado_kg: Double = 0.0,
        km_hoy: Double = 0.0,
        km_semana: Double = 0.0,
        codigo_referido: String? = nil,
        referido_por: String? = nil,
        plataforma: String? = "ios",
        kmcoins_balance: Int = 150,
        creado_en: String? = nil
    ) {
        self.id = id
        self.email = email
        self.nombre = nombre
        self.genero = genero
        self.telefono = telefono
        self.ciudad = ciudad
        self.notificaciones = notificaciones
        self.distancia_total_km = distancia_total_km
        self.co2_total_evitado_kg = co2_total_evitado_kg
        self.km_hoy = km_hoy
        self.km_semana = km_semana
        self.codigo_referido = codigo_referido
        self.referido_por = referido_por
        self.plataforma = plataforma
        self.kmcoins_balance = kmcoins_balance
        self.creado_en = creado_en
    }
    
    // Compatibilidad con vistas existentes
    public var kilometros_totales: Double {
        get { distancia_total_km }
        set { distancia_total_km = newValue }
    }
    
    public var co2_evitado_kg: Double {
        get { co2_total_evitado_kg }
        set { co2_total_evitado_kg = newValue }
    }
}
