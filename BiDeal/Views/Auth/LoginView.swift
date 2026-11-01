import SwiftUI

public struct LoginView: View {
    @EnvironmentObject var authVM: AuthViewModel
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showPassword: Bool = false
    
    @State private var showRegister: Bool = false
    @State private var showForgotPasswordDialog: Bool = false
    @State private var forgotEmail: String = ""
    @State private var forgotSuccess: Bool = false
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color.bidealBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        Spacer().frame(height: 20)
                        
                        // Logo Oficial BiDeal
                        ZStack {
                            RoundedRectangle(cornerRadius: 22)
                                .fill(BiDealTheme.primary)
                                .frame(width: 90, height: 90)
                            
                            Image(systemName: "bicycle")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 52, height: 52)
                                .foregroundColor(.white)
                        }
                        .shadow(color: BiDealTheme.primary.opacity(0.3), radius: 10, x: 0, y: 5)
                        
                        // Títulos de marca
                        VStack(spacing: 4) {
                            Text("BiDeal")
                                .font(.system(size: 34, weight: .heavy, design: .rounded))
                                .italic()
                                .foregroundColor(BiDealTheme.primary)
                            
                            Text("Tu movilidad sostenible tiene premio")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer().frame(height: 10)
                        
                        // Tarjeta de Formulario de Acceso
                        VStack(alignment: .leading, spacing: 18) {
                            Text("Acceder a tu cuenta")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(Color.bidealDarkGreen)
                            
                            // Campo Correo Electrónico
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Correo electrónico")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.secondary)
                                
                                HStack {
                                    Image(systemName: "envelope.fill")
                                        .foregroundColor(BiDealTheme.primary)
                                        .frame(width: 24)
                                    TextField("ejemplo@correo.com", text: $email)
                                        .keyboardType(.emailAddress)
                                        .textInputAutocapitalization(.never)
                                        .autocorrectionDisabled()
                                }
                                .padding(12)
                                .background(Color.bidealBackground)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.bidealBorder, lineWidth: 1)
                                )
                            }
                            
                            // Campo Contraseña
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Contraseña")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.secondary)
                                
                                HStack {
                                    Image(systemName: "lock.fill")
                                        .foregroundColor(BiDealTheme.primary)
                                        .frame(width: 24)
                                    
                                    if showPassword {
                                        TextField("Tu contraseña", text: $password)
                                    } else {
                                        SecureField("Tu contraseña", text: $password)
                                    }
                                    
                                    Button(action: { showPassword.toggle() }) {
                                        Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(12)
                                .background(Color.bidealBackground)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.bidealBorder, lineWidth: 1)
                                )
                            }
                            
                            // Olvidé mi contraseña
                            HStack {
                                Spacer()
                                Button(action: {
                                    forgotEmail = email
                                    showForgotPasswordDialog = true
                                }) {
                                    Text("¿Has olvidado tu contraseña?")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(BiDealTheme.primary)
                                }
                            }
                            
                            // Mensaje de Error
                            if let error = authVM.errorMessage {
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
                            
                            // Botón de Iniciar Sesión
                            Button(action: {
                                Task {
                                    _ = await authVM.login(email: email, pass: password)
                                }
                            }) {
                                HStack {
                                    if authVM.isLoading {
                                        ProgressView().tint(.white)
                                    } else {
                                        Text("Iniciar Sesión")
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
                        .padding(22)
                        .background(Color.bidealSurface)
                        .cornerRadius(24)
                        .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
                        .padding(.horizontal)
                        
                        // Enlace a Registro
                        HStack(spacing: 4) {
                            Text("¿No tienes cuenta?")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Button(action: { showRegister = true }) {
                                Text("Regístrate aquí")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(BiDealTheme.primary)
                            }
                        }
                        .padding(.top, 8)
                        
                        Spacer()
                    }
                }
            }
            .navigationDestination(isPresented: $showRegister) {
                RegisterView()
            }
            .sheet(isPresented: $showForgotPasswordDialog) {
                NavigationStack {
                    VStack(spacing: 20) {
                        Text("Recuperar Contraseña")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.top)
                        
                        Text("Introduce tu correo electrónico registrado y te enviaremos las instrucciones de recuperación.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        TextField("tu_correo@ejemplo.com", text: $forgotEmail)
                            .padding()
                            .background(Color.bidealBackground)
                            .cornerRadius(12)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .padding(.horizontal)
                        
                        if forgotSuccess {
                            Text("¡Correo de recuperación enviado!")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(BiDealTheme.primary)
                        }
                        
                        Button(action: {
                            Task {
                                let ok = await authVM.solicitarRecuperacionPassword(email: forgotEmail)
                                if ok {
                                    forgotSuccess = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        showForgotPasswordDialog = false
                                        forgotSuccess = false
                                    }
                                }
                            }
                        }) {
                            Text("Enviar enlace")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(BiDealTheme.primary)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                    }
                    .presentationDetents([.medium])
                }
            }
        }
    }
}
