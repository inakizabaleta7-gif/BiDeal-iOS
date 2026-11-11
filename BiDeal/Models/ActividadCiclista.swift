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
    
    // Compatibilidad y accesores tipados camelCase
    public var distanciaSumadaKm: Double { distancia_sumada_km }
    public var kmcoinsGanadas: Int { kmcoins_ganadas }
    public var saldoActualKmcoins: Int { saldo_actual_kmcoins ?? 0 }
    public var velocidadMediaKmH: Double? { velocidad_media_kmh }
    public var tiempoSegundos: Int? { tiempo_segundos }
    
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

public struct ComercioDto: Codable, Identifiable {
    public let id: Int
    public let nombre: String
    public let categoria: String?
    public let direccion: String?
    public let logoUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id, nombre, categoria, direccion
        case logoUrl = "logo_url"
    }
    
    public init(id: Int, nombre: String, categoria: String? = nil, direccion: String? = nil, logoUrl: String? = nil) {
        self.id = id
        self.nombre = nombre
        self.categoria = categoria
        self.direccion = direccion
        self.logoUrl = logoUrl
    }
}

public struct DescuentoDto: Codable, Identifiable {
    public let id: Int
    public let titulo: String
    public let descripcion: String
    public let precioKmcoins: Int
    public let cooldownHoras: Int?
    public let enCooldown: Bool?
    public let disponibleEn: String?
    public let puedePagarlo: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id, titulo, descripcion
        case precioKmcoins = "precio_kmcoins"
        case cooldownHoras = "cooldown_horas"
        case enCooldown = "en_cooldown"
        case disponibleEn = "disponible_en"
        case puedePagarlo = "puede_pagarlo"
    }
    
    public init(
        id: Int,
        titulo: String,
        descripcion: String = "",
        precioKmcoins: Int,
        cooldownHoras: Int? = 0,
        enCooldown: Bool? = false,
        disponibleEn: String? = nil,
        puedePagarlo: Bool? = true
    ) {
        self.id = id
        self.titulo = titulo
        self.descripcion = descripcion
        self.precioKmcoins = precioKmcoins
        self.cooldownHoras = cooldownHoras
        self.enCooldown = enCooldown
        self.disponibleEn = disponibleEn
        self.puedePagarlo = puedePagarlo
    }
}

public struct RespuestaEscaneoQR: Codable {
    public let status: String?
    public let mensaje: String?
    public let comercio: ComercioDto
    public let saldoUsuarioKmcoins: Int
    public let descuentos: [DescuentoDto]
    
    enum CodingKeys: String, CodingKey {
        case status, mensaje, comercio, descuentos
        case saldoUsuarioKmcoins = "saldo_usuario_kmcoins"
    }
    
    public init(
        status: String? = "ok",
        mensaje: String? = nil,
        comercio: ComercioDto,
        saldoUsuarioKmcoins: Int,
        descuentos: [DescuentoDto]
    ) {
        self.status = status
        self.mensaje = mensaje
        self.comercio = comercio
        self.saldoUsuarioKmcoins = saldoUsuarioKmcoins
        self.descuentos = descuentos
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
