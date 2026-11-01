import Foundation

public final class SupabaseService {
    public static let shared = SupabaseService()
    
    public let supabaseURL = "https://wtfwkwmvczzyrgdamkpk.supabase.co"
    public let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind0Zndrd212Y3p6eXJnZGFta3BrIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc5MDM1ODk3NiwiZXhwIjoyMTA1OTM0OTc2fQ.d3muWXR3b7AblcHXyLxvrhwxbEbij3y6DBr-eoi2tC8"
    
    private init() {}
    
    private var baseHeaders: [String: String] {
        return [
            "apikey": anonKey,
            "Authorization": "Bearer \(anonKey)",
            "Content-Type": "application/json"
        ]
    }
    
    // Obtener comercios activos con sus descuentos
    public func fetchComercios() async throws -> [Comercio] {
        guard let url = URL(string: "\(supabaseURL)/rest/v1/comercios?activo=eq.true&select=*,descuentos(*)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        baseHeaders.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode([Comercio].self, from: data)
    }
    
    // Obtener o inicializar perfil de usuario
    public func fetchPerfilUsuario(userId: String) async throws -> Usuario? {
        guard let url = URL(string: "\(supabaseURL)/rest/v1/usuarios?id=eq.\(userId)&select=*") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        baseHeaders.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let usuarios = try JSONDecoder().decode([Usuario].self, from: data)
        return usuarios.first
    }
    
    // Sumar KmCoins por trayecto completado
    public func registrarLoteKmCoins(userId: String, km: Double, kmcoins: Int) async throws {
        guard let url = URL(string: "\(supabaseURL)/rest/v1/lotes_kmcoins") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        baseHeaders.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        request.setValue("return=minimal", forHTTPHeaderField: "Prefer")
        
        let body: [String: Any] = [
            "usuario_id": userId,
            "cantidad": kmcoins,
            "motivo": "Trayecto en bicicleta (\(String(format: "%.1f", km)) km)"
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.cannotCreateFile)
        }
    }
}
