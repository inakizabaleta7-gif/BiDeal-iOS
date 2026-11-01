import SwiftUI

public struct AjustesView: View {
    @EnvironmentObject var homeVM: HomeViewModel
    @StateObject private var healthKitManager = HealthKitManager.shared
    
    @AppStorage("modoOscuro") private var modoOscuro: Bool = false
    @AppStorage("tipoVehiculo") private var tipoVehiculo: String = "coche_combustion"
    
    @State private var editandoPerfil: Bool = false
    @State private var inputNombre: String = ""
    @State private var inputTelefono: String = ""
    @State private var inputGenero: String = "Otro"
    @State private var inputCiudad: String = "Pamplona"
    @State private var guardando: Bool = false
    @State private var toastMensaje: String? = nil
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // ==========================================
                    // 1. TARJETA DE PERFIL
                    // ==========================================
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(spacing: 14) {
                            Circle()
                                .fill(BiDealTheme.primary)
                                .frame(width: 56, height: 56)
                                .overlay(
                                    Text(String((homeVM.usuario.nombre ?? "C").prefix(1)).uppercased())
                                        .font(.title2)
                                        .fontWeight(.heavy)
                                        .foregroundColor(.white)
                                )
                            
                            VStack(alignment: .leading, spacing: 3) {
                                Text(homeVM.usuario.nombre ?? "Ciclista")
                                    .font(.title3)
                                    .fontWeight(.heavy)
                                
                                HStack(spacing: 6) {
                                    Text(homeVM.usuario.email ?? "ciclista@bideal.org")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("✓ Verificado")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(BiDealTheme.primary)
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 1)
                                        .background(BiDealTheme.primaryLight)
                                        .cornerRadius(4)
                                }
                                
                                if let tel = homeVM.usuario.telefono, !tel.isEmpty {
                                    Text(tel)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                        }
                        
                        Divider()
                        
                        Button(action: {
                            inputNombre = homeVM.usuario.nombre ?? ""
                            inputTelefono = homeVM.usuario.telefono ?? ""
                            inputGenero = homeVM.usuario.genero ?? "Otro"
                            inputCiudad = homeVM.usuario.ciudad ?? "Pamplona"
                            editandoPerfil = true
                        }) {
                            HStack {
                                Image(systemName: "pencil")
                                Text("Editar Datos de Contacto")
                                    .fontWeight(.bold)
                            }
                            .font(.caption)
                            .foregroundColor(BiDealTheme.primary)
                        }
                    }
                    .padding(18)
                    .background(Color.bidealSurface)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.bidealBorder, lineWidth: 1)
                    )
                    .padding(.horizontal)
                    
                    // ==========================================
                    // 2. SINCRONIZACIÓN APPLE HEALTH (HEALTHKIT)
                    // ==========================================
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                            Text("Apple Health / Salud")
                                .font(.headline)
                                .fontWeight(.bold)
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
                        
                        Text("Sincroniza tus kilómetros de bicicleta registrados con Apple Watch, Strava o apps de ciclismo para sumarlos a tus KmCoins.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
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
                                        let _ = await healthKitManager.sincronizarConServidor(userId: homeVM.usuario.id)
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
                                        let _ = await healthKitManager.sincronizarConServidor(userId: homeVM.usuario.id)
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
                    .padding(18)
                    .background(Color.bidealSurface)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.bidealBorder, lineWidth: 1)
                    )
                    .padding(.horizontal)
                    
                    // ==========================================
                    // 3. PREFERENCIAS DE MOVILIDAD Y APP
                    // ==========================================
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Preferencias de Movilidad")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Vehículo que sustituyes al pedalear:")
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
                    .padding(18)
                    .background(Color.bidealSurface)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.bidealBorder, lineWidth: 1)
                    )
                    .padding(.horizontal)
                    
                    // ==========================================
                    // 4. INFORMACIÓN Y SOPORTE
                    // ==========================================
                    VStack(alignment: .leading, spacing: 10) {
                        Text("BiDeal Pamplona")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        HStack {
                            Text("Versión:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("v1.0.0 (iOS Build 2026)")
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
                            Text("Base de Datos:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("Supabase (Conectada en vivo)")
                                .font(.caption)
                                .fontWeight(.bold)
                        }
                    }
                    .padding(18)
                    .background(Color.bidealSurface)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.bidealBorder, lineWidth: 1)
                    )
                    .padding(.horizontal)
                    
                }
                .padding(.vertical)
            }
            .background(Color.bidealBackground)
            .navigationTitle("Ajustes")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $editandoPerfil) {
                ModalEditarPerfil(
                    nombre: $inputNombre,
                    telefono: $inputTelefono,
                    genero: $inputGenero,
                    ciudad: $inputCiudad,
                    guardando: $guardando,
                    onGuardar: {
                        Task {
                            guardando = true
                            var u = homeVM.usuario
                            u.nombre = inputNombre
                            u.telefono = inputTelefono
                            u.genero = inputGenero
                            u.ciudad = inputCiudad
                            u.plataforma = "ios"
                            
                            do {
                                try await SupabaseService.shared.actualizarPerfil(usuario: u)
                                homeVM.usuario = u
                                editandoPerfil = false
                            } catch {
                                print("Error guardando perfil: \(error)")
                            }
                            guardando = false
                        }
                    }
                )
            }
        }
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
