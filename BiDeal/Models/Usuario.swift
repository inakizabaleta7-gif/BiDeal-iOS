import Foundation

public struct Usuario: Identifiable, Codable, Equatable {
    public let id: String
    public var email: String?
    public var nombre: String?
    public var apellidos: String?
    public var genero: String?
    public var telefono: String?
    public var ciudad: String?
    public var notificaciones: Bool?
    public var activo: Bool?
    public var distancia_total_km: Double
    public var co2_total_evitado_kg: Double
    public var km_hoy: Double
    public var km_semana: Double
    public var racha_oro_semanal: Int
    public var codigo_referido: String?
    public var referido_por: String?
    public var plataforma: String?
    public var kmcoins_balance: Int
    public var creado_en: String?
    
    public var kmcoinsBalance: Int {
        get { kmcoins_balance }
        set { kmcoins_balance = newValue }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case nombre
        case apellidos
        case genero
        case telefono
        case ciudad
        case notificaciones
        case activo
        case distancia_total_km
        case co2_total_evitado_kg
        case km_hoy
        case km_semana
        case racha_oro_semanal
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
        apellidos: String? = "",
        genero: String? = "Otro",
        telefono: String? = nil,
        ciudad: String? = "Pamplona",
        notificaciones: Bool? = true,
        activo: Bool? = true,
        distancia_total_km: Double = 0.0,
        co2_total_evitado_kg: Double = 0.0,
        km_hoy: Double = 0.0,
        km_semana: Double = 0.0,
        racha_oro_semanal: Int = 0,
        codigo_referido: String? = nil,
        referido_por: String? = nil,
        plataforma: String? = "ios",
        kmcoins_balance: Int = 0,
        creado_en: String? = nil
    ) {
        self.id = id
        self.email = email
        self.nombre = nombre
        self.apellidos = apellidos
        self.genero = genero
        self.telefono = telefono
        self.ciudad = ciudad
        self.notificaciones = notificaciones
        self.activo = activo
        self.distancia_total_km = distancia_total_km
        self.co2_total_evitado_kg = co2_total_evitado_kg
        self.km_hoy = km_hoy
        self.km_semana = km_semana
        self.racha_oro_semanal = racha_oro_semanal
        self.codigo_referido = codigo_referido
        self.referido_por = referido_por
        self.plataforma = plataforma
        self.kmcoins_balance = kmcoins_balance
        self.creado_en = creado_en
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.nombre = try container.decodeIfPresent(String.self, forKey: .nombre)
        self.apellidos = try container.decodeIfPresent(String.self, forKey: .apellidos)
        self.genero = try container.decodeIfPresent(String.self, forKey: .genero)
        self.telefono = try container.decodeIfPresent(String.self, forKey: .telefono)
        self.ciudad = try container.decodeIfPresent(String.self, forKey: .ciudad)
        self.notificaciones = try container.decodeIfPresent(Bool.self, forKey: .notificaciones)
        self.activo = try container.decodeIfPresent(Bool.self, forKey: .activo) ?? true
        
        self.distancia_total_km = (try? container.decodeIfPresent(Double.self, forKey: .distancia_total_km)) ?? 0.0
        self.co2_total_evitado_kg = (try? container.decodeIfPresent(Double.self, forKey: .co2_total_evitado_kg)) ?? 0.0
        self.km_hoy = (try? container.decodeIfPresent(Double.self, forKey: .km_hoy)) ?? 0.0
        self.km_semana = (try? container.decodeIfPresent(Double.self, forKey: .km_semana)) ?? 0.0
        self.racha_oro_semanal = (try? container.decodeIfPresent(Int.self, forKey: .racha_oro_semanal)) ?? 0
        
        self.codigo_referido = try container.decodeIfPresent(String.self, forKey: .codigo_referido)
        self.referido_por = try container.decodeIfPresent(String.self, forKey: .referido_por)
        self.plataforma = try container.decodeIfPresent(String.self, forKey: .plataforma)
        self.kmcoins_balance = (try? container.decodeIfPresent(Int.self, forKey: .kmcoins_balance)) ?? 0
        self.creado_en = try container.decodeIfPresent(String.self, forKey: .creado_en)
    }
}

extension Usuario {
    public static let mock = Usuario(
        id: "mock-user-1",
        email: "ciclista@bideal.org",
        nombre: "Ciclista",
        apellidos: "",
        genero: "Otro",
        telefono: "",
        ciudad: "Pamplona",
        notificaciones: true,
        distancia_total_km: 0.0,
        co2_total_evitado_kg: 0.0,
        km_hoy: 0.0,
        km_semana: 0.0,
        racha_oro_semanal: 1,
        codigo_referido: "BIDEAL",
        referido_por: nil,
        plataforma: "ios",
        kmcoins_balance: 0,
        creado_en: nil
    )
}

