import Foundation

public struct AuthResponseUser: Codable {
    public let id: String
    public let email: String?
}

public struct SupabaseAuthResponse: Codable {
    public let access_token: String
    public let refresh_token: String
    public let user: AuthResponseUser
}

public struct SupabaseSignupResponse: Codable {
    public let id: String?
    public let email: String?
}

public struct SaldoVistaDto: Codable {
    public let usuario_id: String
    public let nombre: String?
    public let km_hoy: String?
    public let km_semana: String?
    public let kmcoins_disponibles: Int?
}

public struct RespuestaComerciosApi: Codable {
    public let status: String
    public let comercios: [Comercio]
}

public final class SupabaseService {
    public static let shared = SupabaseService()
    
    public let supabaseURL = "https://wtfwkwmvczzyrgdamkpk.supabase.co"
    public let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind0Zndrd212Y3p6eXJnZGFta3BrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTAzNTg5NzYsImV4cCI6MjEwNTkzNDk3Nn0.zLGH9C2J8CfTC4JDzOBydZcl_3BKEW6ePOVTmK8O6Dg"
    public let serviceKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind0Zndrd212Y3p6eXJnZGFta3BrIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc5MDM1ODk3NiwiZXhwIjoyMTA1OTM0OTc2fQ.d3muWXR3b7AblcHXyLxvrhwxbEbij3y6DBr-eoi2tC8"
    
    private init() {}
    
    private var headers: [String: String] {
        return [
            "apikey": serviceKey,
            "Authorization": "Bearer \(serviceKey)",
            "Content-Type": "application/json"
        ]
    }
    
    // ==========================================
    // 1. AUTENTICACIÓN (LOGIN, SIGNUP, OTP)
    // ==========================================
    public func login(email: String, password: String) async throws -> SupabaseAuthResponse {
        guard let url = URL(string: "\(supabaseURL)/auth/v1/token?grant_type=password") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "email": email,
            "password": password
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(SupabaseAuthResponse.self, from: data)
    }
    
    public func signup(
        nombre: String,
        apellidos: String,
        email: String,
        telefono: String,
        genero: String,
        password: String
    ) async throws -> SupabaseSignupResponse {
        guard let url = URL(string: "\(supabaseURL)/auth/v1/signup") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "email": email,
            "password": password,
            "data": [
                "nombre": nombre,
                "apellidos": apellidos,
                "telefono": telefono,
                "genero": genero
            ]
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(SupabaseSignupResponse.self, from: data)
    }
    
    public func verifyEmailOtp(email: String, token: String) async throws -> SupabaseAuthResponse {
        guard let url = URL(string: "\(supabaseURL)/auth/v1/verify") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "type": "signup",
            "email": email,
            "token": token
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(SupabaseAuthResponse.self, from: data)
    }
    
    public func solicitarResetPassword(email: String) async throws {
        guard let url = URL(string: "\(supabaseURL)/auth/v1/recover") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: ["email": email])
        
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }
    
    // ==========================================
    // 2. PERFIL DE USUARIO Y SALDO
    // ==========================================
    public func fetchPerfilUsuario(userId: String) async throws -> Usuario? {
        guard let url = URL(string: "\(supabaseURL)/rest/v1/usuarios?id=eq.\(userId)&select=*") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let usuarios = try JSONDecoder().decode([Usuario].self, from: data)
        return usuarios.first
    }
    
    public func fetchSaldoKmCoins(userId: String) async throws -> Int? {
        guard let url = URL(string: "\(supabaseURL)/rest/v1/vista_saldo_usuarios?usuario_id=eq.\(userId)&select=kmcoins_disponibles") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            return nil
        }
        
        let saldos = try JSONDecoder().decode([SaldoVistaDto].self, from: data)
        return saldos.first?.kmcoins_disponibles
    }
    
    public func actualizarPerfil(usuario: Usuario) async throws {
        guard let url = URL(string: "\(supabaseURL)/rest/v1/usuarios?id=eq.\(usuario.id)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        
        var bodyDict: [String: Any] = [
            "plataforma": "ios"
        ]
        if let nombre = usuario.nombre { bodyDict["nombre"] = nombre }
        if let genero = usuario.genero { bodyDict["genero"] = genero }
        if let telefono = usuario.telefono { bodyDict["telefono"] = telefono }
        if let ciudad = usuario.ciudad { bodyDict["ciudad"] = ciudad }
        if let notif = usuario.notificaciones { bodyDict["notificaciones"] = notif }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: bodyDict)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }
    
    // ==========================================
    // 3. COMERCIOS Y RECOMPENSAS (EXACTAMENTE IGUAL A ANDROID)
    // ==========================================
    public func fetchComerciosYDescuentos() async throws -> [RecompensaUiModel] {
        // Intento 1: API de Vercel (https://www.bideal.org/api/comercios)
        if let url = URL(string: "https://www.bideal.org/api/comercios") {
            var req = URLRequest(url: url)
            req.httpMethod = "GET"
            req.setValue("application/json", forHTTPHeaderField: "Accept")
            
            if let (data, response) = try? await URLSession.shared.data(for: req),
               let http = response as? HTTPURLResponse, http.statusCode == 200 {
                if let apiRes = try? JSONDecoder().decode(RespuestaComerciosApi.self, from: data) {
                    var items: [RecompensaUiModel] = []
                    for c in apiRes.comercios {
                        for d in (c.descuentos ?? []) {
                            items.append(
                                RecompensaUiModel(
                                    id: d.id,
                                    comercioId: c.id,
                                    comercioNombre: c.nombre,
                                    direccion: c.direccion ?? "Pamplona",
                                    titulo: d.titulo,
                                    descripcion: d.descripcion ?? "Sin descripción adicional.",
                                    precio: d.precio_kmcoins,
                                    categoria: c.categoria ?? "Comercio",
                                    latitud: c.latitud,
                                    longitud: c.longitud,
                                    logoUrl: c.logo_url
                                )
                            )
                        }
                    }
                    if !items.isEmpty {
                        return items
                    }
                }
            }
        }
        
        // Intento 2: Fallback directo a Supabase PostgREST
        guard let urlComercios = URL(string: "\(supabaseURL)/rest/v1/comercios?activo=eq.true&select=*"),
              let urlDescuentos = URL(string: "\(supabaseURL)/rest/v1/descuentos?activo=eq.true&select=*") else {
            throw URLError(.badURL)
        }
        
        var reqComercios = URLRequest(url: urlComercios)
        reqComercios.httpMethod = "GET"
        headers.forEach { reqComercios.setValue($1, forHTTPHeaderField: $0) }
        
        var reqDescuentos = URLRequest(url: urlDescuentos)
        reqDescuentos.httpMethod = "GET"
        headers.forEach { reqDescuentos.setValue($1, forHTTPHeaderField: $0) }
        
        let (dataC, respC) = try await URLSession.shared.data(for: reqComercios)
        let (dataD, respD) = try await URLSession.shared.data(for: reqDescuentos)
        
        guard let httpC = respC as? HTTPURLResponse, (200...299).contains(httpC.statusCode),
              let httpD = respD as? HTTPURLResponse, (200...299).contains(httpD.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let comercios = try JSONDecoder().decode([Comercio].self, from: dataC)
        let descuentos = try JSONDecoder().decode([Descuento].self, from: dataD)
        
        var listaUi: [RecompensaUiModel] = []
        for d in descuentos {
            if let c = comercios.first(where: { $0.id == d.comercio_id }) {
                listaUi.append(
                    RecompensaUiModel(
                        id: d.id,
                        comercioId: c.id,
                        comercioNombre: c.nombre,
                        direccion: c.direccion ?? "Pamplona",
                        titulo: d.titulo,
                        descripcion: d.descripcion ?? "Sin descripción adicional.",
                        precio: d.precio_kmcoins,
                        categoria: c.categoria ?? "Comercio",
                        latitud: c.latitud,
                        longitud: c.longitud,
                        logoUrl: c.logo_url
                    )
                )
            }
        }
        return listaUi
    }
    
    // ==========================================
    // 4. CANJEAR RECOMPENSA
    // ==========================================
    public func canjearRecompensa(userId: String, descuentoId: Int, comercioId: Int, precioKmCoins: Int) async throws -> String {
        guard let url = URL(string: "\(supabaseURL)/rest/v1/canjes_descuentos") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        request.setValue("return=minimal", forHTTPHeaderField: "Prefer")
        
        let codigoCanje = "BD-\(Int.random(in: 100000...999999))"
        let body: [String: Any] = [
            "usuario_id": userId,
            "descuento_id": descuentoId,
            "comercio_id": comercioId,
            "kmcoins_pagadas": precioKmCoins
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        // Descontar lote en lotes_kmcoins (consumo de monedas)
        if let urlLote = URL(string: "\(supabaseURL)/rest/v1/lotes_kmcoins") {
            var reqLote = URLRequest(url: urlLote)
            reqLote.httpMethod = "POST"
            headers.forEach { reqLote.setValue($1, forHTTPHeaderField: $0) }
            let bodyLote: [String: Any] = [
                "usuario_id": userId,
                "cantidad_inicial": -precioKmCoins,
                "cantidad_actual": -precioKmCoins,
                "origen": "Canje Descuento #\(descuentoId)"
            ]
            reqLote.httpBody = try? JSONSerialization.data(withJSONObject: bodyLote)
            _ = try? await URLSession.shared.data(for: reqLote)
        }
        
        return codigoCanje
    }
    
    // ==========================================
    // 5. SINCRONIZACIÓN DE KM Y SALUD
    // ==========================================
    public func sincronizarKmSalud(userId: String, kmHoy: Double, kmSemana: Double, kmTotales: Double) async throws {
        guard let url = URL(string: "\(supabaseURL)/rest/v1/usuarios?id=eq.\(userId)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        
        let co2 = kmTotales * 0.142 // 142g CO2/km estándar oficial MITECO
        let bodyDict: [String: Any] = [
            "km_hoy": kmHoy,
            "km_semana": kmSemana,
            "distancia_total_km": kmTotales,
            "co2_total_evitado_kg": co2,
            "plataforma": "ios"
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: bodyDict)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        // Registrar actividad de salud diaria
        if let urlSalud = URL(string: "\(supabaseURL)/rest/v1/actividades_salud") {
            var reqSalud = URLRequest(url: urlSalud)
            reqSalud.httpMethod = "POST"
            headers.forEach { reqSalud.setValue($1, forHTTPHeaderField: $0) }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let fechaHoy = dateFormatter.string(from: Date())
            
            let bodySalud: [String: Any] = [
                "usuario_id": userId,
                "fecha": fechaHoy,
                "distancia_km": kmHoy,
                "origen": "Apple HealthKit (iOS)"
            ]
            reqSalud.httpBody = try? JSONSerialization.data(withJSONObject: bodySalud)
            _ = try? await URLSession.shared.data(for: reqSalud)
        }
    }
    
    // ==========================================
    // 6. LIGA CICLISTA (GRUPO)
    // ==========================================
    public func obtenerGrupoCiclista(userId: String) async throws -> RespuestaGrupoCiclista {
        guard let url = URL(string: "\(supabaseURL)/rest/v1/rpc/obtener_grupo_usuario") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        
        let bodyDict: [String: Any] = ["p_usuario_id": userId]
        request.httpBody = try JSONSerialization.data(withJSONObject: bodyDict)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(RespuestaGrupoCiclista.self, from: data)
    }
    
    public func unirseAGrupo(userId: String, codigo: String) async throws -> RespuestaUnionGrupo {
        guard let url = URL(string: "\(supabaseURL)/rest/v1/rpc/unirse_a_grupo_ciclista") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        
        let bodyDict: [String: Any] = [
            "p_usuario_id": userId,
            "p_codigo": codigo.trimmingCharacters(in: .whitespaces).uppercased()
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: bodyDict)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(RespuestaUnionGrupo.self, from: data)
    }
}
