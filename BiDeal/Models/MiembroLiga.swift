import Foundation

public struct MiembroLiga: Identifiable, Codable {
    public var id: String { nombre }
    public let nombre: String
    public let kmSemana: Double
    public let esUsuario: Bool
    public let rol: String?
    
    public init(nombre: String, kmSemana: Double, esUsuario: Bool = false, rol: String? = "miembro") {
        self.nombre = nombre
        self.kmSemana = kmSemana
        self.esUsuario = esUsuario
        self.rol = rol
    }
}

public struct GrupoCiclistaDto: Codable {
    public let id: String
    public let codigo: String
    public let nombre: String
    public let meta_km_semanal: Double
    public let bote_kmcoins: Int
    public let premio_meta_kmcoins: Int
    public let total_miembros: Int
}

public struct MiembroGrupoDto: Codable, Identifiable {
    public var id: String { usuario_id }
    public let usuario_id: String
    public let nombre: String
    public let km_semana: Double
    public let km_hoy: Double?
    public let distancia_total_km: Double?
    public let rol: String?
    public let es_usuario: Bool
    public let unido_en: String?
}

public struct RespuestaGrupoCiclista: Codable {
    public let status: String
    public let grupo: GrupoCiclistaDto?
    public let miembros: [MiembroGrupoDto]?
}

public struct RespuestaUnionGrupo: Codable {
    public let status: String
    public let mensaje: String
    public let grupo_id: String?
    public let nombre: String?
    public let codigo: String?
}
