import Foundation

public final class SupabaseService {
    public static let shared = SupabaseService()
    
    public let supabaseURL = "https://wtfwkwmvczzyrgdamkpk.supabase.co"
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
    // 1. COMERCIOS Y DESCUENTOS
    // ==========================================
    public func fetchComercios() async throws -> [Comercio] {
        guard let url = URL(string: "\(supabaseURL)/rest/v1/comercios?activo=eq.true&select=*,descuentos(*)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode([Comercio].self, from: data)
    }
    
    // ==========================================
    // 2. PERFIL DE USUARIO
    // ==========================================
    public func fetchPerfilUsuario(userId: String) async throws -> Usuario? {
        guard let url = URL(string: "\(supabaseURL)/rest/v1/usuarios?id=eq.\(userId)&select=*") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let usuarios = try JSONDecoder().decode([Usuario].self, from: data)
        return usuarios.first
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
    // 3. SINCRONIZACIÓN DE KM Y SALUD
    // ==========================================
    public func sincronizarKmSalud(userId: String, kmHoy: Double, kmSemana: Double, kmTotales: Double) async throws {
        guard let url = URL(string: "\(supabaseURL)/rest/v1/usuarios?id=eq.\(userId)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        
        let co2 = kmTotales * 0.130 // 130g CO2/km estándar MITECO
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
    }
    
    // ==========================================
    // 4. LIGA CICLISTA / GRUPO (RPC EN VIVO)
    // ==========================================
    public func obtenerGrupoCiclista(userId: String) async throws -> RespuestaGrupoCiclista {
        guard let url = URL(string: "\(supabaseURL)/rest/v1/rpc/obtener_grupo_usuario") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        
        let body = ["p_usuario_id": userId]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let errorMsg = String(data: data, encoding: .utf8) ?? "Error RPC grupo"
            throw NSError(domain: "SupabaseService", code: 500, userInfo: [NSLocalizedDescriptionKey: errorMsg])
        }
        
        return try JSONDecoder().decode(RespuestaGrupoCiclista.self, from: data)
    }
    
    public func unirseAGrupo(userId: String, codigo: String) async throws -> RespuestaUnionGrupo {
        guard let url = URL(string: "\(supabaseURL)/rest/v1/rpc/unirse_a_grupo") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        
        let body = [
            "p_usuario_id": userId,
            "p_codigo": codigo.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let errorMsg = String(data: data, encoding: .utf8) ?? "Error uniéndose al grupo"
            throw NSError(domain: "SupabaseService", code: 500, userInfo: [NSLocalizedDescriptionKey: errorMsg])
        }
        
        return try JSONDecoder().decode(RespuestaUnionGrupo.self, from: data)
    }
    
    // ==========================================
    // 5. REGISTRAR LOTES DE KMCOINS
    // ==========================================
    public func registrarLoteKmCoins(userId: String, km: Double, kmcoins: Int) async throws {
        guard let url = URL(string: "\(supabaseURL)/rest/v1/lotes_kmcoins") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        
        let formatter = ISO8601DateFormatter()
        let ahora = formatter.string(from: Date())
        let unAno = formatter.string(from: Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date())
        
        let body: [String: Any] = [
            "usuario_id": userId,
            "cantidad_inicial": kmcoins,
            "cantidad_actual": kmcoins,
            "origen": "ruta_ciclismo_ios",
            "fecha_obtencion": ahora,
            "fecha_caducidad": unAno
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }
}
