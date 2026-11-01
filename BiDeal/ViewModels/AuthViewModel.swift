import Foundation
import SwiftUI
import Combine

public final class AuthViewModel: ObservableObject {
    @Published public var isLoggedIn: Bool = false
    @Published public var currentUser: Usuario? = nil
    @Published public var kmcoinsBalance: Int = 0
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String? = nil
    @Published public var successMessage: String? = nil
    
    // Almacenamiento local seguro
    private let userDefaults = UserDefaults.standard
    private let kIsLoggedIn = "bideal_is_logged_in"
    private let kUserId = "bideal_user_id"
    private let kUserEmail = "bideal_user_email"
    private let kUserToken = "bideal_access_token"
    private let kUserRefreshToken = "bideal_refresh_token"
    
    public init() {
        checkPersistedSession()
    }
    
    public func checkPersistedSession() {
        let logged = userDefaults.bool(forKey: kIsLoggedIn)
        let token = userDefaults.string(forKey: kUserToken) ?? ""
        let uid = userDefaults.string(forKey: kUserId) ?? ""
        
        if logged && !token.isEmpty && !uid.isEmpty {
            self.isLoggedIn = true
            Task {
                await fetchPerfilUsuario(userId: uid)
            }
        } else {
            self.isLoggedIn = false
        }
    }
    
    // ==========================================
    // 1. INICIAR SESIÓN (SUPABASE AUTH)
    // ==========================================
    @MainActor
    public func login(email: String, pass: String) async -> Bool {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !pass.isEmpty else {
            self.errorMessage = "Por favor, introduce tu correo y contraseña."
            return false
        }
        
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            let res = try await SupabaseService.shared.login(email: email.trimmingCharacters(in: .whitespaces), password: pass)
            userDefaults.set(true, forKey: kIsLoggedIn)
            userDefaults.set(res.user.id, forKey: kUserId)
            userDefaults.set(res.user.email ?? email, forKey: kUserEmail)
            userDefaults.set(res.access_token, forKey: kUserToken)
            userDefaults.set(res.refresh_token, forKey: kUserRefreshToken)
            
            self.isLoggedIn = true
            await fetchPerfilUsuario(userId: res.user.id)
            self.isLoading = false
            return true
        } catch {
            self.isLoading = false
            self.errorMessage = "Credenciales incorrectas o usuario no registrado."
            return false
        }
    }
    
    // ==========================================
    // 2. REGISTRO (SUPABASE AUTH SIGNUP)
    // ==========================================
    @MainActor
    public func register(
        nombre: String,
        apellidos: String,
        email: String,
        telefono: String,
        genero: String,
        pass: String
    ) async -> Bool {
        let cleanEmail = email.trimmingCharacters(in: .whitespaces)
        let cleanNombre = nombre.trimmingCharacters(in: .whitespaces)
        
        guard !cleanNombre.isEmpty else {
            self.errorMessage = "El nombre es obligatorio."
            return false
        }
        guard cleanEmail.contains("@") else {
            self.errorMessage = "Introduce un correo electrónico válido."
            return false
        }
        guard pass.count >= 6 else {
            self.errorMessage = "La contraseña debe tener al menos 6 caracteres."
            return false
        }
        
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            let res = try await SupabaseService.shared.signup(
                nombre: cleanNombre,
                apellidos: apellidos.trimmingCharacters(in: .whitespaces),
                email: cleanEmail,
                telefono: telefono.trimmingCharacters(in: .whitespaces),
                genero: genero,
                password: pass
            )
            
            if let uid = res.id {
                userDefaults.set(uid, forKey: kUserId)
            }
            userDefaults.set(cleanEmail, forKey: kUserEmail)
            
            self.isLoading = false
            self.successMessage = "Código de confirmación enviado a tu correo."
            return true
        } catch {
            self.isLoading = false
            self.errorMessage = "Error al registrar: \(error.localizedDescription)"
            return false
        }
    }
    
    // ==========================================
    // 3. VERIFICAR OTP DE EMAIL
    // ==========================================
    @MainActor
    public func verifyOtp(email: String, token: String) async -> Bool {
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            let res = try await SupabaseService.shared.verifyEmailOtp(email: email.trimmingCharacters(in: .whitespaces), token: token.trimmingCharacters(in: .whitespaces))
            userDefaults.set(true, forKey: kIsLoggedIn)
            userDefaults.set(res.user.id, forKey: kUserId)
            userDefaults.set(res.user.email ?? email, forKey: kUserEmail)
            userDefaults.set(res.access_token, forKey: kUserToken)
            userDefaults.set(res.refresh_token, forKey: kUserRefreshToken)
            
            self.isLoggedIn = true
            await fetchPerfilUsuario(userId: res.user.id)
            self.isLoading = false
            return true
        } catch {
            self.isLoading = false
            self.errorMessage = "Código incorrecto o caducado."
            return false
        }
    }
    
    // ==========================================
    // 4. RECUPERAR CONTRASEÑA
    // ==========================================
    @MainActor
    public func solicitarRecuperacionPassword(email: String) async -> Bool {
        self.isLoading = true
        self.errorMessage = nil
        do {
            try await SupabaseService.shared.solicitarResetPassword(email: email.trimmingCharacters(in: .whitespaces))
            self.isLoading = false
            self.successMessage = "Se ha enviado un enlace/código de recuperación a tu correo."
            return true
        } catch {
            self.isLoading = false
            self.errorMessage = "No se pudo enviar el correo de recuperación."
            return false
        }
    }
    
    // ==========================================
    // 5. CARGAR PERFIL COMPLETO
    // ==========================================
    @MainActor
    public func fetchPerfilUsuario(userId: String) async {
        do {
            if var perfil = try await SupabaseService.shared.fetchPerfilUsuario(userId: userId) {
                // Obtener saldo exacto desde vista_saldo_usuarios
                if let saldo = try await SupabaseService.shared.fetchSaldoKmCoins(userId: userId) {
                    perfil.kmcoins_balance = saldo
                    self.kmcoinsBalance = saldo
                } else {
                    self.kmcoinsBalance = perfil.kmcoins_balance
                }
                self.currentUser = perfil
            }
        } catch {
            print("Error al cargar perfil de usuario: \(error)")
        }
    }
    
    // ==========================================
    // 6. CERRAR SESIÓN (LOGOUT)
    // ==========================================
    public func logout() {
        userDefaults.set(false, forKey: kIsLoggedIn)
        userDefaults.removeObject(forKey: kUserId)
        userDefaults.removeObject(forKey: kUserEmail)
        userDefaults.removeObject(forKey: kUserToken)
        userDefaults.removeObject(forKey: kUserRefreshToken)
        
        self.isLoggedIn = false
        self.currentUser = nil
        self.kmcoinsBalance = 0
    }
    
    public func cerrarSesion() {
        logout()
    }
    
    @MainActor
    public func entrarModoInvitado() {
        self.currentUser = Usuario(
            id: "local-demo-user",
            nombre: "Iñaki",
            email: "demo@bideal.org",
            telefono: "600123456",
            genero: "Hombre",
            ciudad: "Pamplona",
            kmcoins_balance: 140,
            distancia_total_km: 42.5,
            tiempo_total_segundos: 7800,
            co2_ahorrado_kg: 8.9,
            arboles_equivalentes: 0.5,
            notificaciones: true,
            codigo_amigo: "BIDEAL-PAMPLONA",
            fecha_registro: ISO8601DateFormatter().string(from: Date())
        )
        self.kmcoinsBalance = 140
        self.isLoggedIn = true
    }
    
    @MainActor
    public func cargarSaldoKmCoins() async {
        guard let uid = currentUser?.id ?? userDefaults.string(forKey: kUserId) else { return }
        if let saldo = try? await SupabaseService.shared.fetchSaldoKmCoins(userId: uid) {
            self.kmcoinsBalance = saldo
            if var user = self.currentUser {
                user.kmcoins_balance = saldo
                self.currentUser = user
            }
        }
    }
    
    // ==========================================
    // 7. SINCRONIZACIÓN DE KM DESDE HEALTHKIT
    // ==========================================
    @MainActor
    public func sincronizarKmSalud(kmHoy: Double) async {
        guard let uid = currentUser?.id ?? userDefaults.string(forKey: kUserId) else { return }
        do {
            try await SupabaseService.shared.sincronizarKmSalud(
                userId: uid,
                kmHoy: kmHoy,
                kmSemana: (currentUser?.km_semana ?? 0.0) + kmHoy,
                kmTotales: (currentUser?.distancia_total_km ?? 0.0) + kmHoy
            )
            await fetchPerfilUsuario(userId: uid)
        } catch {
            print("Error sincronizando HealthKit con Supabase: \(error)")
        }
    }
}
