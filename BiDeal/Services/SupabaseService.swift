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
    
    public func parseSupabaseError(data: Data, statusCode: Int) -> String {
        if statusCode == 429 {
            return "Has realizado varias solicitudes seguidas. Por seguridad, espera 1 minuto."
        }
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return "Error en el servidor (\(statusCode))."
        }
        
        let raw = json["msg"] as? String
            ?? json["message"] as? String
            ?? json["error_description"] as? String
            ?? json["error"] as? String
            ?? ""
        
        let lower = raw.lowercased()
        if lower.contains("invalid login credentials") || lower.contains("invalid credentials") {
            return "Correo electrónico o contraseña incorrectos."
        }
        if lower.contains("user already registered") || lower.contains("already exists") {
            return "Este correo ya está registrado. Inicia sesión con tu contraseña."
        }
        if lower.contains("email not confirmed") {
            return "Por favor, confirma tu correo electrónico antes de acceder."
        }
        if lower.contains("password should be at least 6 characters") {
            return "La contraseña debe tener al menos 6 caracteres."
        }
        if lower.contains("rate limit") || lower.contains("security purposes") {
            return "Has realizado varias solicitudes seguidas. Por seguridad, espera 1 minuto."
        }
        return raw.isEmpty ? "Error en el servidor (\(statusCode))." : raw
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
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            let errorMsg = parseSupabaseError(data: data, statusCode: httpResponse.statusCode)
            throw NSError(domain: "BiDealAuth", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMsg])
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
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            let errorMsg = parseSupabaseError(data: data, statusCode: httpResponse.statusCode)
            throw NSError(domain: "BiDealAuth", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMsg])
        }
        
        // Anti-enumeration check: Si identities está vacío [], el usuario ya existe previamente
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let identities = json["identities"] as? [Any], identities.isEmpty {
            throw NSError(
                domain: "BiDealAuth",
                code: 409,
                userInfo: [NSLocalizedDescriptionKey: "Este correo electrónico ya está registrado. Por favor, inicia sesión con tu contraseña."]
            )
        }
        
        var uid: String? = nil
        var uemail: String? = nil
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            if let id = json["id"] as? String {
                uid = id
                uemail = json["email"] as? String
            } else if let userDict = json["user"] as? [String: Any] {
                uid = userDict["id"] as? String
                uemail = userDict["email"] as? String
            }
        }
        
        return SupabaseSignupResponse(id: uid, email: uemail ?? email)
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
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            let errorMsg = parseSupabaseError(data: data, statusCode: httpResponse.statusCode)
            throw NSError(domain: "BiDealAuth", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMsg])
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
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            let errorMsg = parseSupabaseError(data: data, statusCode: httpResponse.statusCode)
            throw NSError(domain: "BiDealAuth", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMsg])
        }
    }
    
    // ==========================================
    // 2. PERFIL DE USUARIO Y SALDO
    // ==========================================
    public func fetchPerfilUsuario(userId: String, fallbackEmail: String? = nil) async throws -> Usuario? {
        guard let url = URL(string: "\(supabaseURL)/rest/v1/usuarios?id=eq.\(userId)&select=*") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
            let usuarios = try JSONDecoder().decode([Usuario].self, from: data)
            if let user = usuarios.first {
                return user
            }
        }
        
        // Búsqueda alternativa por email si no encontró por ID
        if let email = fallbackEmail, let urlEmail = URL(string: "\(supabaseURL)/rest/v1/usuarios?email=eq.\(email)&select=*") {
            var reqEmail = URLRequest(url: urlEmail)
            reqEmail.httpMethod = "GET"
            headers.forEach { reqEmail.setValue($1, forHTTPHeaderField: $0) }
            if let (dataE, respE) = try? await URLSession.shared.data(for: reqEmail),
               let httpE = respE as? HTTPURLResponse, (200...299).contains(httpE.statusCode),
               let usersEmail = try? JSONDecoder().decode([Usuario].self, from: dataE) {
                return usersEmail.first
            }
        }
        
        return nil
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
    // 3. COMERCIOS Y RECOMPENSAS (CONEXIÓN DIRECTA EN VIVO)
    // ==========================================
    public func fetchComerciosYDescuentos() async throws -> [RecompensaUiModel] {
        var items: [RecompensaUiModel] = []
        
        // 1. Consulta directa a Supabase PostgREST
        if let urlComercios = URL(string: "\(supabaseURL)/rest/v1/comercios?activo=eq.true&select=*"),
           let urlDescuentos = URL(string: "\(supabaseURL)/rest/v1/descuentos?activo=eq.true&select=*") {
            
            var reqC = URLRequest(url: urlComercios)
            headers.forEach { reqC.setValue($1, forHTTPHeaderField: $0) }
            
            var reqD = URLRequest(url: urlDescuentos)
            headers.forEach { reqD.setValue($1, forHTTPHeaderField: $0) }
            
            if let (dataC, respC) = try? await URLSession.shared.data(for: reqC),
               let (dataD, respD) = try? await URLSession.shared.data(for: reqD),
               let httpC = respC as? HTTPURLResponse, (200...299).contains(httpC.statusCode),
               let httpD = respD as? HTTPURLResponse, (200...299).contains(httpD.statusCode) {
                
                if let comercios = try? JSONDecoder().decode([Comercio].self, from: dataC),
                   let descuentos = try? JSONDecoder().decode([Descuento].self, from: dataD) {
                    
                    for d in descuentos {
                        if let c = comercios.first(where: { $0.id == d.comercio_id }) {
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
                }
            }
        }
        
        // 2. Si falló la consulta directa o está vacía, intentar API Vercel
        if items.isEmpty, let url = URL(string: "https://www.bideal.org/api/comercios") {
            var req = URLRequest(url: url)
            req.setValue("application/json", forHTTPHeaderField: "Accept")
            if let (data, response) = try? await URLSession.shared.data(for: req),
               let http = response as? HTTPURLResponse, http.statusCode == 200,
               let apiRes = try? JSONDecoder().decode(RespuestaComerciosApi.self, from: data) {
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
            }
        }
        
        // 3. Fallback de comercios emblemáticos de Pamplona (igual que Android mockRecompensasFallback)
        let fallback = [
            RecompensaUiModel(
                id: 1001,
                comercioId: 101,
                comercioNombre: "Cafetería La Estafeta",
                direccion: "Calle Estafeta, 12, Pamplona",
                titulo: "Café Orgánico Gratis",
                descripcion: "Disfruta de un café artesanal 100% ecológico por acudir en transporte sostenible.",
                precio: 40,
                categoria: "Restauración",
                latitud: 42.8168,
                longitud: -1.6432,
                logoUrl: "https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=500"
            ),
            RecompensaUiModel(
                id: 1002,
                comercioId: 102,
                comercioNombre: "Bicicletas San Ignacio",
                direccion: "Avenida San Ignacio, 8, Pamplona",
                titulo: "15% Descuento en Puesta a Punto",
                descripcion: "Revisión completa de frenos, cadena y presión de neumáticos para tu bici.",
                precio: 100,
                categoria: "Deportes",
                latitud: 42.8145,
                longitud: -1.6410,
                logoUrl: "https://images.unsplash.com/photo-1485965120184-e220f721d03e?w=500"
            ),
            RecompensaUiModel(
                id: 1003,
                comercioId: 103,
                comercioNombre: "Librería Gómez",
                direccion: "Calle San Antón, 15, Pamplona",
                titulo: "10% en Libros de Viajes y Naturaleza",
                descripcion: "Válido para cualquier libro de la sección de naturaleza y rutas de Navarra.",
                precio: 80,
                categoria: "Cultura",
                latitud: 42.8130,
                longitud: -1.6450,
                logoUrl: "https://images.unsplash.com/photo-1524995997946-a1c2e315a42f?w=500"
            ),
            RecompensaUiModel(
                id: 1004,
                comercioId: 104,
                comercioNombre: "Moda Sostenible Pamplona",
                direccion: "Calle Zapatería, 22, Pamplona",
                titulo: "Bono de 5€ en ropa ecológica",
                descripcion: "Aplicable a compras superiores a 25€ en prendas hechas con algodón orgánico.",
                precio: 120,
                categoria: "Moda",
                latitud: 42.8155,
                longitud: -1.6440,
                logoUrl: "https://images.unsplash.com/photo-1489987707025-afc232f7ea0f?w=500"
            )
        ]
        
        for f in fallback {
            if !items.contains(where: { $0.comercioNombre == f.comercioNombre }) {
                items.append(f)
            }
        }
        
        return items
    }
    
    // ==========================================
    // 4. CANJEAR RECOMPENSA (EN VIVO CON BASE DE DATOS)
    // ==========================================
    public func canjearRecompensa(userId: String, descuentoId: Int, comercioId: Int, precioKmCoins: Int, userToken: String? = nil) async throws -> RespuestaCanje {
        // Intento 1: API oficial de Vercel /api/canjear_descuento (exacta a Android)
        if let token = userToken, !token.isEmpty,
           let urlApi = URL(string: "https://www.bideal.org/api/canjear_descuento") {
            var req = URLRequest(url: urlApi)
            req.httpMethod = "POST"
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body: [String: Any] = ["descuento_id": descuentoId]
            req.httpBody = try? JSONSerialization.data(withJSONObject: body)
            
            if let (data, resp) = try? await URLSession.shared.data(for: req),
               let http = resp as? HTTPURLResponse, (200...299).contains(http.statusCode) {
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    let codigo = json["codigo_canje"] as? String ?? "BD-\(Int.random(in: 100000...999999))"
                    let msg = json["mensaje"] as? String ?? "¡Canje realizado con éxito!"
                    return RespuestaCanje(exito: true, codigoCanje: codigo, mensaje: msg)
                }
            }
        }
        
        // Intento 2: Registro directo en Supabase (canjes_descuentos + lotes_kmcoins)
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
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let errorMsg = parseSupabaseError(data: data, statusCode: (response as? HTTPURLResponse)?.statusCode ?? 500)
            return RespuestaCanje(exito: false, codigoCanje: "", mensaje: errorMsg)
        }
        
        // Descontar monedas en lotes_kmcoins
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
        
        return RespuestaCanje(
            exito: true,
            codigoCanje: codigoCanje,
            mensaje: "¡Canje completado con éxito! Muestra este código en el comercio."
        )
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
