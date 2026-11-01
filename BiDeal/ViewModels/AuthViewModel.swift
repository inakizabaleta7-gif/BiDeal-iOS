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
    
    // Almacenamiento local persistente
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
        let email = userDefaults.string(forKey: kUserEmail)
        
        if logged && !token.isEmpty && !uid.isEmpty {
            self.isLoggedIn = true
            Task {
                await fetchPerfilUsuario(userId: uid, email: email)
            }
        } else {
            self.isLoggedIn = false
            self.currentUser = nil
        }
    }
    
    public func clearError() {
        self.errorMessage = nil
    }
    
    // ==========================================
    // 1. INICIAR SESIÓN (SUPABASE AUTH)
    // ==========================================
    @MainActor
    public func login(email: String, pass: String) async -> Bool {
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanEmail.isEmpty, !pass.isEmpty else {
            self.errorMessage = "Por favor, introduce tu correo y contraseña."
            return false
        }
        
        self.isLoading = true
        self.errorMessage = nil
        self.successMessage = nil
        
        do {
            let res = try await SupabaseService.shared.login(email: cleanEmail, password: pass)
            userDefaults.set(true, forKey: kIsLoggedIn)
            userDefaults.set(res.user.id, forKey: kUserId)
            userDefaults.set(res.user.email ?? cleanEmail, forKey: kUserEmail)
            userDefaults.set(res.access_token, forKey: kUserToken)
            userDefaults.set(res.refresh_token, forKey: kUserRefreshToken)
            
            self.isLoggedIn = true
            await fetchPerfilUsuario(userId: res.user.id, email: res.user.email ?? cleanEmail)
            self.isLoading = false
            return true
        } catch {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
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
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanNombre = nombre.trimmingCharacters(in: .whitespacesAndNewlines)
        
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
        self.successMessage = nil
        
        do {
            let res = try await SupabaseService.shared.signup(
                nombre: cleanNombre,
                apellidos: apellidos.trimmingCharacters(in: .whitespacesAndNewlines),
                email: cleanEmail,
                telefono: telefono.trimmingCharacters(in: .whitespacesAndNewlines),
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
            self.errorMessage = error.localizedDescription
            return false
        }
    }
    
    // ==========================================
    // 3. VERIFICAR OTP DE EMAIL
    // ==========================================
    @MainActor
    public func verifyOtp(email: String, token: String) async -> Bool {
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanToken = token.trimmingCharacters(in: .whitespacesAndNewlines)
        
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            let res = try await SupabaseService.shared.verifyEmailOtp(email: cleanEmail, token: cleanToken)
            userDefaults.set(true, forKey: kIsLoggedIn)
            userDefaults.set(res.user.id, forKey: kUserId)
            userDefaults.set(res.user.email ?? cleanEmail, forKey: kUserEmail)
            userDefaults.set(res.access_token, forKey: kUserToken)
            userDefaults.set(res.refresh_token, forKey: kUserRefreshToken)
            
            self.isLoggedIn = true
            await fetchPerfilUsuario(userId: res.user.id, email: res.user.email ?? cleanEmail)
            self.isLoading = false
            return true
        } catch {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
            return false
        }
    }
    
    // ==========================================
    // 4. RECUPERAR CONTRASEÑA
    // ==========================================
    @MainActor
    public func solicitarRecuperacionPassword(email: String) async -> Bool {
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        self.isLoading = true
        self.errorMessage = nil
        do {
            try await SupabaseService.shared.solicitarResetPassword(email: cleanEmail)
            self.isLoading = false
            self.successMessage = "Se ha enviado un código de recuperación a tu correo."
            return true
        } catch {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
            return false
        }
    }
    
    // ==========================================
    // 5. CARGAR PERFIL COMPLETO DESDE BD
    // ==========================================
    @MainActor
    public func fetchPerfilUsuario(userId: String, email: String? = nil) async {
        do {
            var perfilOpt = try await SupabaseService.shared.fetchPerfilUsuario(userId: userId, fallbackEmail: email)
            
            if perfilOpt == nil {
                // Si aún no está en la tabla pública de usuarios, inicializar con los datos básicos
                perfilOpt = Usuario(
                    id: userId,
                    nombre: email?.components(separatedBy: "@").first?.capitalized ?? "Ciclista",
                    email: email,
                    genero: "Prefiero no decirlo",
                    telefono: "",
                    ciudad: "Pamplona",
                    distancia_total_km: 0.0,
                    km_hoy: 0.0,
                    km_semana: 0.0,
                    co2_total_evitado_kg: 0.0,
                    kmcoins_balance: 0,
                    racha_oro_semanal: 1,
                    codigo_referido: "BI-\(userId.prefix(6).uppercased())",
                    activo: true,
                    notificaciones: true
                )
            }
            
            if var perfil = perfilOpt {
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
            print("Error cargando perfil desde Supabase: \(error)")
        }
    }
    
    // ==========================================
    // 6. CERRAR SESIÓN (LOGOUT LIMPIO)
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
