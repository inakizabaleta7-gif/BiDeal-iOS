import SwiftUI

public struct AjustesView: View {
    @EnvironmentObject var homeVM: HomeViewModel
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @StateObject private var healthKitManager = HealthKitManager.shared
    
    @AppStorage("modoOscuro") private var modoOscuro: Bool = false
    @AppStorage("notificacionesEnabled") private var notificacionesEnabled: Bool = true
    @AppStorage("tipoVehiculo") private var tipoVehiculo: String = "coche_combustion"
    
    @State private var editandoPerfil: Bool = false
    @State private var mostrarEstadoRastreador: Bool = false
    @State private var mostrarReferidos: Bool = false
    @State private var mostrarTerminos: Bool = false
    @State private var mostrarAlertaEliminarCuenta: Bool = false
    
    @State private var inputNombre: String = ""
    @State private var inputTelefono: String = ""
    @State private var inputGenero: String = "Otro"
    @State private var inputCiudad: String = "Pamplona"
    @State private var guardando: Bool = false
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    tarjetaPerfil
                    tarjetaEstadoRastreador
                    seccionPromociones
                    seccionSalud
                    seccionPreferencias
                    seccionSoporte
                    seccionInfo
                    botonCerrarSesion
                    enlaceEliminarCuenta
                    Spacer().frame(height: 20)
                }
                .padding(.vertical)
            }
            .background(Color.bidealBackground)
            .navigationTitle("Ajustes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Listo") { dismiss() }
                        .fontWeight(.bold)
                        .foregroundColor(BiDealTheme.primary)
                }
            }
            .sheet(isPresented: $editandoPerfil) {
                ModalEditarPerfil(
                    nombre: $inputNombre,
                    telefono: $inputTelefono,
                    genero: $inputGenero,
                    ciudad: $inputCiudad,
                    guardando: $guardando,
                    onGuardar: guardarPerfil
                )
            }
            .sheet(isPresented: $mostrarEstadoRastreador) {
                EstadoRastreadorView()
            }
            .sheet(isPresented: $mostrarReferidos) {
                ReferidosView()
            }
            .sheet(isPresented: $mostrarTerminos) {
                TerminosView(showBackButton: true)
            }
            .alert("Eliminar cuenta", isPresented: $mostrarAlertaEliminarCuenta) {
                Button("Cancelar", role: .cancel) { }
                Button("Eliminar definitivamente", role: .destructive) {
                    authVM.cerrarSesion()
                    dismiss()
                }
            } message: {
                Text("¿Estás seguro de que deseas eliminar tu cuenta? Esta acción borrará permanentemente todos tus KmCoins acumulados, tus estadísticas y tu registro en BiDeal.")
            }
        }
    }
    
    private var tarjetaPerfil: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 14) {
                Circle()
                    .fill(BiDealTheme.primary)
                    .frame(width: 56, height: 56)
                    .overlay(
                        Text(String((authVM.currentUser?.nombre ?? homeVM.usuario.nombre ?? "C").prefix(1)).uppercased())
                            .font(.title2)
                            .fontWeight(.heavy)
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(authVM.currentUser?.nombre ?? homeVM.usuario.nombre ?? "Ciclista")
                        .font(.title3)
                        .fontWeight(.heavy)
                    
                    HStack(spacing: 6) {
                        Text(authVM.currentUser?.email ?? homeVM.usuario.email ?? "ciclista@bideal.org")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("• Verificado")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(BiDealTheme.primary)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(BiDealTheme.primaryLight)
                            .cornerRadius(4)
                    }
                    
                    if let tel = authVM.currentUser?.telefono ?? homeVM.usuario.telefono, !tel.isEmpty {
                        Text(tel)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Button(action: {
                    let u = authVM.currentUser ?? homeVM.usuario
                    inputNombre = u.nombre ?? ""
                    inputTelefono = u.telefono ?? ""
                    inputGenero = u.genero ?? "Otro"
                    inputCiudad = u.ciudad ?? "Pamplona"
                    editandoPerfil = true
                }) {
                    ZStack {
                        Circle()
                            .fill(BiDealTheme.primaryLight)
                            .frame(width: 36, height: 36)
                        Image(systemName: "pencil")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(BiDealTheme.primary)
                    }
                }
            }
        }
        .padding(18)
        .background(Color.bidealSurface)
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.bidealBorder, lineWidth: 1))
        .padding(.horizontal)
    }
    
    private var tarjetaEstadoRastreador: some View {
        Button(action: { mostrarEstadoRastreador = true }) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color(red: 220/255, green: 252/255, blue: 231/255))
                        .frame(width: 44, height: 44)
                    Image(systemName: "shield.lefthalf.filled.badge.checkmark")
                        .font(.system(size: 20))
                        .foregroundColor(BiDealTheme.primary)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text("Estado del Rastreador y Permisos")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.primary)
                        Spacer()
                        Text("ACTIVO")
                            .font(.system(size: 9, weight: .heavy))
                            .foregroundColor(BiDealTheme.primary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(BiDealTheme.primaryLight)
                            .cornerRadius(6)
                    }
                    Text("Sensores pasivos, GPS y HealthKit automáticos")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .background(Color.bidealSurface)
            .cornerRadius(18)
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.bidealBorder, lineWidth: 1))
            .padding(.horizontal)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var seccionPromociones: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Promociones")
                .font(.headline)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            Button(action: { mostrarReferidos = true }) {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 254/255, green: 243/255, blue: 199/255))
                            .frame(width: 40, height: 40)
                        Image(systemName: "gift.fill")
                            .font(.system(size: 18))
                            .foregroundColor(Color(red: 180/255, green: 83/255, blue: 9/255))
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("¿Tienes un código promocional?")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.primary)
                        Text("Canjea o comparte tu código para ganar KmCoins")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.secondary)
                }
                .padding(16)
                .background(Color.bidealSurface)
                .cornerRadius(18)
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.bidealBorder, lineWidth: 1))
                .padding(.horizontal)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    private var seccionSalud: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Integraciones")
                .font(.headline)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(Color.red.opacity(0.12))
                            .frame(width: 36, height: 36)
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                            .font(.system(size: 16))
                    }
                    
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Apple Health / Salud")
                            .font(.system(size: 14, weight: .bold))
                        Text(healthKitManager.estaAutorizado ? "Sincronización activa" : "Conectar entrenamientos")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text(healthKitManager.estaAutorizado ? "Conectado" : "Pendiente")
                        .font(.caption2)
                        .fontWeight(.heavy)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(healthKitManager.estaAutorizado ? BiDealTheme.primaryLight : Color.gray.opacity(0.15))
                        .foregroundColor(healthKitManager.estaAutorizado ? BiDealTheme.primaryDark : .secondary)
                        .cornerRadius(8)
                }
                
                if healthKitManager.estaAutorizado {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Hoy:")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text(String(format: "%.1f km", healthKitManager.kmHoy))
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(BiDealTheme.primary)
                        }
                        Divider().frame(height: 24)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Esta semana:")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text(String(format: "%.1f km", healthKitManager.kmSemana))
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(BiDealTheme.primary)
                        }
                        Spacer()
                        
                        Button(action: {
                            Task {
                                let uid = authVM.currentUser?.id ?? homeVM.usuario.id
                                let _ = await healthKitManager.sincronizarConServidor(userId: uid)
                            }
                        }) {
                            HStack(spacing: 4) {
                                if healthKitManager.estaSincronizando {
                                    ProgressView().scaleEffect(0.8)
                                } else {
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                    Text("Sincronizar")
                                }
                            }
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(BiDealTheme.primaryLight)
                            .foregroundColor(BiDealTheme.primaryDark)
                            .cornerRadius(8)
                        }
                    }
                    .padding(10)
                    .background(Color.bidealBackground)
                    .cornerRadius(12)
                } else {
                    Button(action: {
                        Task {
                            let ok = await healthKitManager.solicitarPermisos()
                            if ok {
                                let uid = authVM.currentUser?.id ?? homeVM.usuario.id
                                let _ = await healthKitManager.sincronizarConServidor(userId: uid)
                            }
                        }
                    }) {
                        HStack {
                            Image(systemName: "link")
                            Text("Conectar con Apple Health")
                                .fontWeight(.bold)
                        }
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(BiDealTheme.primary)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
            }
            .padding(16)
            .background(Color.bidealSurface)
            .cornerRadius(18)
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.bidealBorder, lineWidth: 1))
            .padding(.horizontal)
        }
    }
    
    private var seccionPreferencias: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Preferencias")
                .font(.headline)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                Toggle(isOn: $notificacionesEnabled) {
                    HStack(spacing: 12) {
                        Image(systemName: "bell.fill")
                            .foregroundColor(BiDealTheme.primary)
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Notificaciones")
                                .font(.system(size: 14, weight: .bold))
                            Text("Alertas de retos y recompensas")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Divider()
                
                Toggle(isOn: $modoOscuro) {
                    HStack(spacing: 12) {
                        Image(systemName: "moon.fill")
                            .foregroundColor(BiDealTheme.primary)
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Modo Oscuro")
                                .font(.system(size: 14, weight: .bold))
                            Text("Ajustar apariencia visual")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Vehículo sustituido al pedalear:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Picker("Vehículo Sustituido", selection: $tipoVehiculo) {
                        Text("Coche de Combustión (130 g CO₂/km)").tag("coche_combustion")
                        Text("Motocicleta (80 g CO₂/km)").tag("moto")
                        Text("Coche Híbrido (95 g CO₂/km)").tag("coche_hibrido")
                        Text("Transporte Público (40 g CO₂/km)").tag("bus")
                    }
                    .pickerStyle(.menu)
                    .padding(8)
                    .background(Color.bidealBackground)
                    .cornerRadius(10)
                }
            }
            .padding(16)
            .background(Color.bidealSurface)
            .cornerRadius(18)
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.bidealBorder, lineWidth: 1))
            .padding(.horizontal)
        }
    }
    
    private var seccionSoporte: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Soporte y Más")
                .font(.headline)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                Button(action: {
                    if let url = URL(string: "mailto:info@bideal.org") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    FilaAjusteClick(icono: "questionmark.circle.fill", titulo: "Centro de ayuda", subtitulo: "Contacta con el equipo")
                }
                
                Divider().padding(.leading, 44)
                
                Button(action: { mostrarTerminos = true }) {
                    FilaAjusteClick(icono: "lock.shield.fill", titulo: "Privacidad y Términos", subtitulo: "Condiciones de uso y RGPD")
                }
                
                Divider().padding(.leading, 44)
                
                Button(action: {
                    if let url = URL(string: "https://www.bideal.org/") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    FilaAjusteClick(icono: "info.circle.fill", titulo: "Acerca de BiDeal", subtitulo: "www.bideal.org")
                }
            }
            .padding(12)
            .background(Color.bidealSurface)
            .cornerRadius(18)
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.bidealBorder, lineWidth: 1))
            .padding(.horizontal)
        }
    }
    
    private var seccionInfo: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Versión:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("v1.0.0 (iOS Oficial 2026)")
                    .font(.caption)
                    .fontWeight(.bold)
            }
            
            HStack {
                Text("Plataforma:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("iOS Nativo (SwiftUI + HealthKit)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(BiDealTheme.primary)
            }
            
            HStack {
                Text("Servidor:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("Supabase Cloud (Pamplona)")
                    .font(.caption)
                    .fontWeight(.bold)
            }
        }
        .padding(16)
        .background(Color.bidealSurface)
        .cornerRadius(18)
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.bidealBorder, lineWidth: 1))
        .padding(.horizontal)
    }
    
    private var botonCerrarSesion: some View {
        Button(action: {
            authVM.cerrarSesion()
            dismiss()
        }) {
            HStack(spacing: 8) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 16, weight: .bold))
                Text("Cerrar Sesión")
                    .font(.system(size: 15, weight: .bold))
            }
            .foregroundColor(Color(red: 220/255, green: 38/255, blue: 38/255))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color(red: 254/255, green: 242/255, blue: 242/255))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(red: 254/255, green: 202/255, blue: 202/255), lineWidth: 1)
            )
        }
        .padding(.horizontal)
        .padding(.top, 4)
    }
    
    private var enlaceEliminarCuenta: some View {
        Button(action: { mostrarAlertaEliminarCuenta = true }) {
            Text("Eliminar cuenta y datos personales")
                .font(.system(size: 12))
                .foregroundColor(Color.gray)
                .underline()
        }
        .padding(.top, 4)
    }
    
    private func guardarPerfil() {
        Task {
            guardando = true
            var u = authVM.currentUser ?? homeVM.usuario
            u.nombre = inputNombre
            u.telefono = inputTelefono
            u.genero = inputGenero
            u.ciudad = inputCiudad
            u.plataforma = "ios"
            
            do {
                try await SupabaseService.shared.actualizarPerfil(usuario: u)
                homeVM.usuario = u
                authVM.currentUser = u
                editandoPerfil = false
            } catch {
                print("Error guardando perfil: \(error)")
            }
            guardando = false
        }
    }
}

struct FilaAjusteClick: View {
    let icono: String
    let titulo: String
    let subtitulo: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icono)
                .font(.system(size: 18))
                .foregroundColor(BiDealTheme.primary)
                .frame(width: 28)
            
            VStack(alignment: .leading, spacing: 1) {
                Text(titulo)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                Text(subtitulo)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 10)
    }
}

struct ModalEditarPerfil: View {
    @Binding var nombre: String
    @Binding var telefono: String
    @Binding var genero: String
    @Binding var ciudad: String
    @Binding var guardando: Bool
    let onGuardar: () -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Datos Personales")) {
                    TextField("Nombre completo", text: $nombre)
                    TextField("Teléfono de contacto", text: $telefono)
                        .keyboardType(.phonePad)
                    Picker("Género", selection: $genero) {
                        Text("Masculino").tag("Masculino")
                        Text("Femenino").tag("Femenino")
                        Text("Otro").tag("Otro")
                    }
                    TextField("Ciudad", text: $ciudad)
                }
                
                Section {
                    Button(action: onGuardar) {
                        HStack {
                            Spacer()
                            if guardando {
                                ProgressView().tint(.white)
                            } else {
                                Text("Guardar Cambios")
                                    .fontWeight(.bold)
                            }
                            Spacer()
                        }
                    }
                    .listRowBackground(BiDealTheme.primary)
                    .foregroundColor(.white)
                    .disabled(guardando)
                }
            }
            .navigationTitle("Editar Perfil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
            }
        }
    }
}
