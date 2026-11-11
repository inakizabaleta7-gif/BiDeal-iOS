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
    // Clave anónima pública segura para clientes móviles (Row Level Security activo)
    public let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind0Zndrd212Y3p6eXJnZGFta3BrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTAzNTg5NzYsImV4cCI6MjEwNTkzNDk3Nn0.zLGH9C2J8CfTC4JDzOBydZcl_3BKEW6ePOVTmK8O6Dg"
    
    public var isAuthenticated: Bool {
        let token = UserDefaults.standard.string(forKey: "supabase_access_token")
            ?? UserDefaults.standard.string(forKey: "bideal_access_token")
        return token != nil && !token!.isEmpty
    }
    
    private init() {}
    
    private var headers: [String: String] {
        var h = [
            "apikey": anonKey,
            "Content-Type": "application/json"
        ]
        if let token = UserDefaults.standard.string(forKey: "supabase_access_token"), !token.isEmpty {
            h["Authorization"] = "Bearer \(token)"
        } else {
            h["Authorization"] = "Bearer \(anonKey)"
        }
        return h
    }
    
    public func saveTokens(accessToken: String, refreshToken: String) {
        UserDefaults.standard.set(accessToken, forKey: "supabase_access_token")
        UserDefaults.standard.set(refreshToken, forKey: "supabase_refresh_token")
    }
    
    public func clearTokens() {
        UserDefaults.standard.removeObject(forKey: "supabase_access_token")
        UserDefaults.standard.removeObject(forKey: "supabase_refresh_token")
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
    // 1. AUTENTICACIÓN (LOGIN, SIGNUP, OTP, REFRESH)
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
            "email": email.trimmingCharacters(in: .whitespaces).lowercased(),
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
        
        let authRes = try JSONDecoder().decode(SupabaseAuthResponse.self, from: data)
        saveTokens(accessToken: authRes.access_token, refreshToken: authRes.refresh_token)
        return authRes
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
            "email": email.trimmingCharacters(in: .whitespaces).lowercased(),
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
            "email": email.trimmingCharacters(in: .whitespaces).lowercased(),
            "token": token.trimmingCharacters(in: .whitespaces)
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
        
        let authRes = try JSONDecoder().decode(SupabaseAuthResponse.self, from: data)
        saveTokens(accessToken: authRes.access_token, refreshToken: authRes.refresh_token)
        return authRes
    }
    
    public func refreshToken() async throws -> String {
        guard let refresh = UserDefaults.standard.string(forKey: "supabase_refresh_token"), !refresh.isEmpty,
              let url = URL(string: "\(supabaseURL)/auth/v1/token?grant_type=refresh_token") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: ["refresh_token": refresh])
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let authRes = try JSONDecoder().decode(SupabaseAuthResponse.self, from: data)
        saveTokens(accessToken: authRes.access_token, refreshToken: authRes.refresh_token)
        return authRes.access_token
    }
    
    public func solicitarResetPassword(email: String) async throws {
        guard let url = URL(string: "\(supabaseURL)/auth/v1/recover") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: ["email": email.trimmingCharacters(in: .whitespaces).lowercased()])
        
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
        // Primero intentamos la API oficial de Vercel
        if let perfil = try? await ApiClient.shared.obtenerPerfilUsuario() {
            return Usuario(
                id: perfil.id,
                email: perfil.email ?? "",
                nombre: perfil.nombre ?? "Ciclista",
                apellidos: perfil.apellidos,
                genero: "Otro",
                telefono: perfil.telefono,
                ciudad: perfil.ciudad ?? "Pamplona",
                notificaciones: true,
                activo: true,
                distancia_total_km: perfil.distancia_total_km ?? 0.0,
                co2_total_evitado_kg: perfil.co2_total_evitado_kg ?? 0.0,
                km_hoy: perfil.km_hoy ?? 0.0,
                km_semana: perfil.km_semana ?? 0.0,
                racha_oro_semanal: perfil.racha_semanas ?? 0,
                codigo_referido: nil,
                referido_por: nil,
                plataforma: "ios",
                kmcoins_balance: perfil.kmcoins_disponibles ?? 0,
                creado_en: nil
            )
        }
        
        // Fallback a consulta directa PostgREST
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
        
        return nil
    }
    
    public func fetchSaldoKmCoins(userId: String) async throws -> Int? {
        // Primero mediante API oficial
        if let perfil = try? await ApiClient.shared.obtenerPerfilUsuario() {
            return perfil.kmcoins_disponibles
        }
        
        // Fallback a vista_saldo_usuarios en Supabase
        guard let url = URL(string: "\(supabaseURL)/rest/v1/vista_saldo_usuarios?usuario_id=eq.\(userId)&select=kmcoins_disponibles") else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        
        guard let (data, response) = try? await URLSession.shared.data(for: request),
              let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            return nil
        }
        
        let saldos = try? JSONDecoder().decode([SaldoVistaDto].self, from: data)
        return saldos?.first?.kmcoins_disponibles
    }
    
    // ==========================================
    // 3. COMERCIOS Y RECOMPENSAS
    // ==========================================
    public func fetchComerciosYDescuentos() async throws -> [RecompensaUiModel] {
        var items: [RecompensaUiModel] = []
        
        // 1. Consulta a Supabase PostgREST
        if let urlComercios = URL(string: "\(supabaseURL)/rest/v1/comercios?select=*"),
           let urlRecompensas = URL(string: "\(supabaseURL)/rest/v1/recompensas?activa=eq.true&select=*") {
            
            var reqC = URLRequest(url: urlComercios)
            headers.forEach { reqC.setValue($1, forHTTPHeaderField: $0) }
            
            var reqR = URLRequest(url: urlRecompensas)
            headers.forEach { reqR.setValue($1, forHTTPHeaderField: $0) }
            
            if let (dataC, respC) = try? await URLSession.shared.data(for: reqC),
               let (dataR, respR) = try? await URLSession.shared.data(for: reqR),
               let httpC = respC as? HTTPURLResponse, (200...299).contains(httpC.statusCode),
               let httpR = respR as? HTTPURLResponse, (200...299).contains(httpR.statusCode) {
                
                if let comercios = try? JSONDecoder().decode([Comercio].self, from: dataC) {
                    struct RecDTO: Codable {
                        let id: Int
                        let comercio_id: Int
                        let titulo: String
                        let descripcion: String?
                        let precio_bicoins: Int
                    }
                    if let recs = try? JSONDecoder().decode([RecDTO].self, from: dataR) {
                        for r in recs {
                            if let c = comercios.first(where: { $0.id == r.comercio_id }) {
                                items.append(
                                    RecompensaUiModel(
                                        id: r.id,
                                        comercioId: c.id,
                                        comercioNombre: c.nombre,
                                        direccion: c.direccion ?? "Pamplona",
                                        titulo: r.titulo,
                                        descripcion: r.descripcion ?? "Sin descripción adicional.",
                                        precio: r.precio_bicoins,
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
        }
        
        // 2. Si falló la consulta o está vacía, intentar API Vercel /api/comercios
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
        
        // 3. Fallback oficial con comercios reales de Pamplona (idéntico a Android)
        if items.isEmpty {
            items = [
                RecompensaUiModel(
                    id: 1,
                    comercioId: 101,
                    comercioNombre: "Mundo Raintxe",
                    direccion: "Calle Nueva 121, Casco Antiguo",
                    titulo: "50% dto. en revisión básica de taller",
                    descripcion: "Ajuste de cambios, frenos, presión de neumáticos y lubricación de transmisión.",
                    precio: 50,
                    categoria: "Deportes",
                    latitud: 42.8175,
                    longitud: -1.6442,
                    logoUrl: nil
                ),
                RecompensaUiModel(
                    id: 2,
                    comercioId: 102,
                    comercioNombre: "Óptica Iturrama",
                    direccion: "Calle Iturrama 24, Pamplona",
                    titulo: "15% de descuento en gafas graduadas",
                    descripcion: "15% en monturas graduadas y 10% en gafas de sol y lentes de contacto.",
                    precio: 80,
                    categoria: "Salud",
                    latitud: 42.8062,
                    longitud: -1.6508,
                    logoUrl: nil
                ),
                RecompensaUiModel(
                    id: 3,
                    comercioId: 103,
                    comercioNombre: "Donde Siempre / TEO3 Moda",
                    direccion: "Calle San Nicolás 18, Pamplona",
                    titulo: "10% de descuento en ropa",
                    descripcion: "Descuento en compras de temporada de textil y moda de proximidad.",
                    precio: 350,
                    categoria: "Moda",
                    latitud: 42.8152,
                    longitud: -1.6440,
                    logoUrl: nil
                ),
                RecompensaUiModel(
                    id: 4,
                    comercioId: 104,
                    comercioNombre: "Salting Pamplona",
                    direccion: "Polígono Agustinos, Pamplona",
                    titulo: "2 € de descuento por hora de saltos",
                    descripcion: "Pasa una tarde divertida en camas elásticas pagando 9€ en lugar de 11€.",
                    precio: 60,
                    categoria: "Cultura",
                    latitud: 42.8350,
                    longitud: -1.6620,
                    logoUrl: nil
                )
            ]
        }
        
        return items
    }
    
    // ==========================================
    // 5. CANJEAR RECOMPENSA (VÍA BACKEND ATÓMICO VERCEL)
    // ==========================================
    public func canjearRecompensa(
        userId: String,
        descuentoId: Int,
        comercioId: Int?,
        precioKmCoins: Int,
        userToken: String? = nil
    ) async throws -> RespuestaCanje {
        let token = userToken ?? UserDefaults.standard.string(forKey: "supabase_access_token")
        return try await ApiClient.shared.canjearDescuentoThrowing(
            descuentoId: descuentoId,
            comercioId: comercioId,
            token: token
        )
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
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let jwt = UserDefaults.standard.string(forKey: "supabase_access_token"), !jwt.isEmpty {
            request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
        }
        
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
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let jwt = UserDefaults.standard.string(forKey: "supabase_access_token"), !jwt.isEmpty {
            request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
        }
        
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
    
    // ==========================================
    // 7. ACTUALIZACIÓN DE PERFIL Y SALUD
    // ==========================================
    public func actualizarPerfil(usuario: Usuario) async throws {
        guard let url = URL(string: "\(supabaseURL)/rest/v1/usuarios?id=eq.\(usuario.id)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        request.setValue("return=minimal", forHTTPHeaderField: "Prefer")
        
        var dict: [String: Any] = [
            "plataforma": usuario.plataforma ?? "ios"
        ]
        if let nombre = usuario.nombre { dict["nombre"] = nombre }
        if let apellidos = usuario.apellidos { dict["apellidos"] = apellidos }
        if let telefono = usuario.telefono { dict["telefono"] = telefono }
        if let genero = usuario.genero { dict["genero"] = genero }
        if let ciudad = usuario.ciudad { dict["ciudad"] = ciudad }
        if let notif = usuario.notificaciones { dict["notificaciones"] = notif }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: dict)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }
    
    public func sincronizarKmSalud(userId: String, kmHoy: Double, kmSemana: Double, kmTotales: Double) async throws {
        guard let url = URL(string: "\(supabaseURL)/rest/v1/usuarios?id=eq.\(userId)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        request.setValue("return=minimal", forHTTPHeaderField: "Prefer")
        
        let dict: [String: Any] = [
            "km_hoy": kmHoy,
            "km_semana": kmSemana,
            "distancia_total_km": kmTotales,
            "co2_total_evitado_kg": kmTotales * 0.165,
            "plataforma": "ios"
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: dict)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }
}
