import Foundation

// ==========================================
// 1. MODELOS DE REGISTRO GPS Y RUTA (PARIDAD ANDROID)
// ==========================================

public struct PuntoRuta: Codable {
    public let timestamp: Int64
    public let latitud: Double
    public let longitud: Double
    public let precision_metros: Double
    public let velocidad_kmh: Double?
    public let actividad: String
    public let confianza: Int

    public init(
        timestamp: Int64 = Int64(Date().timeIntervalSince1970 * 1000),
        latitud: Double,
        longitud: Double,
        precision_metros: Double,
        velocidad_kmh: Double?,
        actividad: String = "ON_BICYCLE",
        confianza: Int = 80
    ) {
        self.timestamp = timestamp
        self.latitud = latitud
        self.longitud = longitud
        self.precision_metros = precision_metros
        self.velocidad_kmh = velocidad_kmh
        self.actividad = actividad
        self.confianza = confianza
    }
}

public struct PeticionRuta: Codable {
    public let datosRuta: [PuntoRuta]
    
    public init(datosRuta: [PuntoRuta]) {
        self.datosRuta = datosRuta
    }
}

public struct RespuestaRuta: Codable {
    public let distancia_sumada_km: Double
    public let kmcoins_ganadas: Int
    public let velocidad_media_kmh: Double?
    public let tiempo_segundos: Int?
    public let saldo_actual_kmcoins: Int?
    public let mensaje: String?
    
    public init(
        distancia_sumada_km: Double,
        kmcoins_ganadas: Int,
        velocidad_media_kmh: Double? = nil,
        tiempo_segundos: Int? = nil,
        saldo_actual_kmcoins: Int? = nil,
        mensaje: String? = nil
    ) {
        self.distancia_sumada_km = distancia_sumada_km
        self.kmcoins_ganadas = kmcoins_ganadas
        self.velocidad_media_kmh = velocidad_media_kmh
        self.tiempo_segundos = tiempo_segundos
        self.saldo_actual_kmcoins = saldo_actual_kmcoins
        self.mensaje = mensaje
    }
}

// ==========================================
// 2. MODELOS DE ESCÁNER QR Y CANJE EN TIENDA
// ==========================================

public struct PeticionEscaneoQR: Codable {
    public let codigo_qr: String
    
    public init(codigo_qr: String) {
        self.codigo_qr = codigo_qr
    }
}

public struct RespuestaEscaneoQR: Codable {
    public let valido: Bool
    public let comercio_id: Int?
    public let nombre_comercio: String?
    public let direccion: String?
    public let categoria: String?
    public let descuento_id: Int?
    public let titulo_descuento: String?
    public let precio_kmcoins: Int?
    public let mensaje: String?
    
    public init(
        valido: Bool,
        comercio_id: Int? = nil,
        nombre_comercio: String? = nil,
        direccion: String? = nil,
        categoria: String? = nil,
        descuento_id: Int? = nil,
        titulo_descuento: String? = nil,
        precio_kmcoins: Int? = nil,
        mensaje: String? = nil
    ) {
        self.valido = valido
        self.comercio_id = comercio_id
        self.nombre_comercio = nombre_comercio
        self.direccion = direccion
        self.categoria = categoria
        self.descuento_id = descuento_id
        self.titulo_descuento = titulo_descuento
        self.precio_kmcoins = precio_kmcoins
        self.mensaje = mensaje
    }
}

public struct PeticionCanje: Codable {
    public let descuento_id: Int
    public let comercio_id: Int?
    public let codigo_qr: String?
    
    public init(descuento_id: Int, comercio_id: Int? = nil, codigo_qr: String? = nil) {
        self.descuento_id = descuento_id
        self.comercio_id = comercio_id
        self.codigo_qr = codigo_qr
    }
}

// ==========================================
// 3. MODELO DE PERFIL Y REFERIDOS
// ==========================================

public struct PerfilUsuarioDto: Codable {
    public let id: String
    public let nombre: String?
    public let apellidos: String?
    public let email: String?
    public let telefono: String?
    public let ciudad: String?
    public let km_hoy: Double?
    public let km_semana: Double?
    public let distancia_total_km: Double?
    public let kmcoins_disponibles: Int?
    public let racha_semanas: Int?
    public let nivel: Int?
    public let co2_total_evitado_kg: Double?
}

public struct RespuestaReferidosDto: Codable {
    public let codigo_referido: String?
    public let total_referidos: Int?
    public let kmcoins_ganadas: Int?
}

// ==========================================
// 4. ACTIVIDAD LOCAL HISTÓRICA
// ==========================================

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
