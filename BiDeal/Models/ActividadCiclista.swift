import Foundation

public struct ActividadCiclista: Identifiable, Codable {
    public let id: UUID
    public let fecha: Date
    public let distanciaKm: Double
    public let duracionSegundos: Int
    public let velocidadMediaKmH: Double
    public let kmcoinsGanadas: Int
    public let co2EvitadoKg: Double
    
    public init(
        id: UUID = UUID(),
        fecha: Date = Date(),
        distanciaKm: Double,
        duracionSegundos: Int,
        velocidadMediaKmH: Double,
        kmcoinsGanadas: Int,
        co2EvitadoKg: Double
    ) {
        self.id = id
        self.fecha = fecha
        self.distanciaKm = distanciaKm
        self.duracionSegundos = duracionSegundos
        self.velocidadMediaKmH = velocidadMediaKmH
        self.kmcoinsGanadas = kmcoinsGanadas
        self.co2EvitadoKg = co2EvitadoKg
    }
}
