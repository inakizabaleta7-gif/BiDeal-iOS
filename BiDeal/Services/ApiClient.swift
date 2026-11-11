import Foundation

public final class ApiClient {
    public static let shared = ApiClient()
    
    private let baseURL = "https://www.bideal.org"
    
    private init() {}
    
    private func getDeviceSessionId() -> String {
        let key = "BiDeal_Device_Session_ID"
        if let existing = UserDefaults.standard.string(forKey: key) {
            return existing
        }
        let newId = UUID().uuidString
        UserDefaults.standard.set(newId, forKey: key)
        return newId
    }
    
    private func prepareRequest(url: URL, method: String = "GET", token: String? = nil, bodyData: Data? = nil) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(getDeviceSessionId(), forHTTPHeaderField: "X-Device-Session-ID")
        
        let jwt = token
            ?? UserDefaults.standard.string(forKey: "bideal_access_token")
            ?? UserDefaults.standard.string(forKey: "supabase_access_token")
        if let jwt = jwt, !jwt.isEmpty {
            request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = bodyData {
            request.httpBody = body
        }
        return request
    }
    
    // ==========================================
    // 1. ENVÍO DE RUTAS GPS (CÁLCULO SEGURO EN SERVIDOR)
    // ==========================================
    public func enviarLoteRuta(puntos: [PuntoRuta], token: String? = nil) async -> Result<RespuestaRuta, Error> {
        do {
            guard let url = URL(string: "\(baseURL)/api/calcular_ruta") else {
                return .failure(URLError(.badURL))
            }
            
            let peticion = PeticionRuta(datosRuta: puntos)
            let bodyData = try JSONEncoder().encode(peticion)
            let request = prepareRequest(url: url, method: "POST", token: token, bodyData: bodyData)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(URLError(.badServerResponse))
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                let errorMsg = String(data: data, encoding: .utf8) ?? "Error \(httpResponse.statusCode) al calcular ruta"
                return .failure(NSError(domain: "BiDealApi", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMsg]))
            }
            
            let decoded = try JSONDecoder().decode(RespuestaRuta.self, from: data)
            return .success(decoded)
        } catch {
            return .failure(error)
        }
    }
    
    // ==========================================
    // 2. VALIDACIÓN ÓPTICA DE CÓDIGO QR EN MOSTRADOR
    // ==========================================
    public func escanearQr(codigo: String, token: String? = nil) async -> Result<RespuestaEscaneoQR, Error> {
        do {
            guard let url = URL(string: "\(baseURL)/api/qr_escanear") else {
                return .failure(URLError(.badURL))
            }
            
            let peticion = PeticionEscaneoQR(codigo_qr: codigo)
            let bodyData = try JSONEncoder().encode(peticion)
            let request = prepareRequest(url: url, method: "POST", token: token, bodyData: bodyData)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(URLError(.badServerResponse))
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                let errorMsg = String(data: data, encoding: .utf8) ?? "Error \(httpResponse.statusCode) al escanear QR"
                return .failure(NSError(domain: "BiDealApi", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMsg]))
            }
            
            let decoded = try JSONDecoder().decode(RespuestaEscaneoQR.self, from: data)
            return .success(decoded)
        } catch {
            return .failure(error)
        }
    }
    
    // ==========================================
    // 3. CANJE ATÓMICO DE DESCUENTO
    // ==========================================
    public func canjearDescuento(descuentoId: Int, comercioId: Int? = nil, codigoQr: String? = nil, token: String? = nil) async -> Result<RespuestaCanje, Error> {
        do {
            guard let url = URL(string: "\(baseURL)/api/canjear_descuento") else {
                return .failure(URLError(.badURL))
            }
            
            let peticion = PeticionCanje(descuento_id: descuentoId, comercio_id: comercioId, codigo_qr: codigoQr)
            let bodyData = try JSONEncoder().encode(peticion)
            let request = prepareRequest(url: url, method: "POST", token: token, bodyData: bodyData)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(URLError(.badServerResponse))
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                let errorMsg = String(data: data, encoding: .utf8) ?? "Error \(httpResponse.statusCode) al canjear descuento"
                return .failure(NSError(domain: "BiDealApi", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMsg]))
            }
            
            let decoded = try JSONDecoder().decode(RespuestaCanje.self, from: data)
            return .success(decoded)
        } catch {
            return .failure(error)
        }
    }
    
    public func canjearDescuentoThrowing(descuentoId: Int, comercioId: Int? = nil, codigoQr: String? = nil, token: String? = nil) async throws -> RespuestaCanje {
        let res = await canjearDescuento(descuentoId: descuentoId, comercioId: comercioId, codigoQr: codigoQr, token: token)
        switch res {
        case .success(let val): return val
        case .failure(let err): throw err
        }
    }
    
    // ==========================================
    // 4. PERFIL DE USUARIO Y MÉTRICAS
    // ==========================================
    public func obtenerPerfilUsuario(token: String? = nil) async throws -> PerfilUsuarioDto {
        guard let url = URL(string: "\(baseURL)/api/perfil_usuario") else {
            throw URLError(.badURL)
        }
        
        let request = prepareRequest(url: url, method: "GET", token: token)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(PerfilUsuarioDto.self, from: data)
    }
    
    // ==========================================
    // 5. REFERIDOS
    // ==========================================
    public func obtenerReferidos(token: String? = nil) async throws -> RespuestaReferidosDto {
        guard let url = URL(string: "\(baseURL)/api/referidos") else {
            throw URLError(.badURL)
        }
        
        let request = prepareRequest(url: url, method: "GET", token: token)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(RespuestaReferidosDto.self, from: data)
    }
    
    public func canjearCodigoReferido(codigo: String, token: String? = nil) async throws -> String {
        guard let url = URL(string: "\(baseURL)/api/referidos") else {
            throw URLError(.badURL)
        }
        
        let bodyData = try JSONSerialization.data(withJSONObject: ["codigo": codigo.uppercased().trimmingCharacters(in: .whitespaces)])
        let request = prepareRequest(url: url, method: "POST", token: token, bodyData: bodyData)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let errorMsg = String(data: data, encoding: .utf8) ?? "Error al canjear código"
            throw NSError(domain: "BiDealApi", code: 400, userInfo: [NSLocalizedDescriptionKey: errorMsg])
        }
        
        return "Código de referido aplicado con éxito"
    }
}
