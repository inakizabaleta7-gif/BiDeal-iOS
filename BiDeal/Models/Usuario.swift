import Foundation

public struct Usuario: Identifiable, Codable {
    public let id: String
    public var email: String?
    public var nombre: String?
    public var kmcoins_balance: Int
    public var kilometros_totales: Double
    public var co2_evitado_kg: Double
    public var codigo_referido: String?
    public var referido_por: String?
    public var created_at: String?
    
    public init(
        id: String,
        email: String? = nil,
        nombre: String? = nil,
        kmcoins_balance: Int = 150,
        kilometros_totales: Double = 0.0,
        co2_evitado_kg: Double = 0.0,
        codigo_referido: String? = "BI-PAM77",
        referido_por: String? = nil,
        created_at: String? = nil
    ) {
        self.id = id
        self.email = email
        self.nombre = nombre
        self.kmcoins_balance = kmcoins_balance
        self.kilometros_totales = kilometros_totales
        self.co2_evitado_kg = co2_evitado_kg
        self.codigo_referido = codigo_referido
        self.referido_por = referido_por
        self.created_at = created_at
    }
}
