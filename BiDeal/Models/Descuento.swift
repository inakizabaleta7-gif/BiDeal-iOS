import Foundation

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
