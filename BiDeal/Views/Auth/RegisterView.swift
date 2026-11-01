import SwiftUI

public struct RegisterView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authVM: AuthViewModel
    
    @State private var nombre: String = ""
    @State private var apellidos: String = ""
    @State private var email: String = ""
    @State private var telefono: String = ""
    @State private var genero: String = "Hombre"
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var aceptarTerminos: Bool = false
    
    @State private var showPassword: Bool = false
    @State private var showConfirmPassword: Bool = false
    
    @State private var showOtpModal: Bool = false
    @State private var otpCode: String = ""
    @State private var validationError: String? = nil
    
    let generos = ["Hombre", "Mujer", "No binario", "Prefiero no decirlo"]
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color.bidealBackground
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    // Cabecera
                    VStack(spacing: 4) {
                        Text("Crear nueva cuenta")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color.bidealDarkGreen)
                        
                        Text("Únete a la comunidad ciclista de Pamplona")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 10)
                    
                    // Tarjeta de Formulario
                    VStack(alignment: .leading, spacing: 14) {
                        // Nombre
                        CampoTextoRegistro(titulo: "Nombre *", icono: "person.fill", placeholder: "Ej. Iñaki", texto: $nombre)
                        
                        // Apellidos
                        CampoTextoRegistro(titulo: "Apellidos", icono: "person.2.fill", placeholder: "Ej. Zabaleta Iraizoz", texto: $apellidos)
                        
                        // Correo Electrónico
                        CampoTextoRegistro(titulo: "Correo electrónico *", icono: "envelope.fill", placeholder: "tu_correo@ejemplo.com", texto: $email, keyboard: .emailAddress)
                        
                        // Teléfono
                        CampoTextoRegistro(titulo: "Teléfono móvil", icono: "phone.fill", placeholder: "600 000 000", texto: $telefono, keyboard: .phonePad)
                        
                        // Género
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Género")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                            
                            Picker("Género", selection: $genero) {
                                ForEach(generos, id: \.self) { g in
                                    Text(g).tag(g)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        
                        // Contraseña
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Contraseña (mínimo 6 caracteres) *")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(BiDealTheme.primary)
                                    .frame(width: 24)
                                
                                if showPassword {
                                    TextField("Contraseña", text: $password)
                                } else {
                                    SecureField("Contraseña", text: $password)
                                }
                                
                                Button(action: { showPassword.toggle() }) {
                                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(12)
                            .background(Color.bidealBackground)
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.bidealBorder, lineWidth: 1))
                        }
                        
                        // Confirmar Contraseña
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Confirmar contraseña *")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Image(systemName: "lock.shield.fill")
                                    .foregroundColor(BiDealTheme.primary)
                                    .frame(width: 24)
                                
                                if showConfirmPassword {
                                    TextField("Repite tu contraseña", text: $confirmPassword)
                                } else {
                                    SecureField("Repite tu contraseña", text: $confirmPassword)
                                }
                                
                                Button(action: { showConfirmPassword.toggle() }) {
                                    Image(systemName: showConfirmPassword ? "eye.slash.fill" : "eye.fill")
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(12)
                            .background(Color.bidealBackground)
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.bidealBorder, lineWidth: 1))
                        }
                        
                        // Checkbox Términos
                        HStack(alignment: .top, spacing: 10) {
                            Button(action: { aceptarTerminos.toggle() }) {
                                Image(systemName: aceptarTerminos ? "checkmark.square.fill" : "square")
                                    .font(.title3)
                                    .foregroundColor(aceptarTerminos ? BiDealTheme.primary : .secondary)
                            }
                            
                            Text("He leído y acepto los Términos y Condiciones del Servicio y la Política de Privacidad de BiDeal Pamplona.")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                        
                        // Errores
                        if let error = validationError ?? authVM.errorMessage {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundColor(.red)
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(10)
                        }
                        
                        // Botón Registro
                        Button(action: {
                            validarYRegistrar()
                        }) {
                            HStack {
                                if authVM.isLoading {
                                    ProgressView().tint(.white)
                                } else {
                                    Text("Crear Cuenta")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(BiDealTheme.primary)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                            .shadow(color: BiDealTheme.primary.opacity(0.3), radius: 6, x: 0, y: 3)
                        }
                        .disabled(authVM.isLoading)
                    }
                    .padding(20)
                    .background(Color.bidealSurface)
                    .cornerRadius(24)
                    .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 4)
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showOtpModal) {
            NavigationStack {
                VStack(spacing: 20) {
                    Image(systemName: "envelope.badge.shield.half.filled")
                        .font(.system(size: 50))
                        .foregroundColor(BiDealTheme.primary)
                        .padding(.top, 24)
                    
                    Text("Verifica tu Correo")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Introduce el código de verificación que acabamos de enviar a **\(email)**.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    TextField("Código OTP", text: $otpCode)
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .keyboardType(.numberPad)
                        .padding()
                        .background(Color.bidealBackground)
                        .cornerRadius(14)
                        .padding(.horizontal, 40)
                    
                    Button(action: {
                        Task {
                            let ok = await authVM.verifyOtp(email: email, token: otpCode)
                            if ok {
                                showOtpModal = false
                                dismiss()
                            }
                        }
                    }) {
                        HStack {
                            if authVM.isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text("Verificar y Acceder")
                                    .fontWeight(.bold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(BiDealTheme.primary)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                    }
                    .padding(.horizontal, 40)
                    .disabled(authVM.isLoading || otpCode.trimmingCharacters(in: .whitespaces).isEmpty)
                    
                    Spacer()
                }
                .presentationDetents([.medium])
            }
        }
    }
    
    private func validarYRegistrar() {
        validationError = nil
        let cleanNombre = nombre.trimmingCharacters(in: .whitespaces)
        let cleanEmail = email.trimmingCharacters(in: .whitespaces)
        
        if cleanNombre.isEmpty {
            validationError = "El nombre es obligatorio."
            return
        }
        if !cleanEmail.contains("@") {
            validationError = "Introduce un correo válido."
            return
        }
        if password.count < 6 {
            validationError = "La contraseña debe tener mínimo 6 caracteres."
            return
        }
        if password != confirmPassword {
            validationError = "Las contraseñas no coinciden."
            return
        }
        if !aceptarTerminos {
            validationError = "Debes aceptar los Términos y Condiciones."
            return
        }
        
        Task {
            let ok = await authVM.register(
                nombre: cleanNombre,
                apellidos: apellidos,
                email: cleanEmail,
                telefono: telefono,
                genero: genero,
                pass: password
            )
            if ok {
                showOtpModal = true
            }
        }
    }
}

struct CampoTextoRegistro: View {
    let titulo: String
    let icono: String
    let placeholder: String
    @Binding var texto: String
    var keyboard: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(titulo)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            HStack {
                Image(systemName: icono)
                    .foregroundColor(BiDealTheme.primary)
                    .frame(width: 24)
                TextField(placeholder, text: $texto)
                    .keyboardType(keyboard)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
            }
            .padding(12)
            .background(Color.bidealBackground)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.bidealBorder, lineWidth: 1))
        }
    }
}
