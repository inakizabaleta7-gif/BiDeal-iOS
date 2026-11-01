import SwiftUI
import CoreImage.CIFilterBuiltins

public struct DetalleComercioView: View {
    let recompensa: RecompensaUiModel
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var comerciosVM: ComerciosViewModel
    @EnvironmentObject var homeVM: HomeViewModel
    
    @State private var procesandoCanje: Bool = false
    @State private var mostrarAlertaSaldo: Bool = false
    @State private var mensajeAlerta: String = ""
    @State private var resultadoCanje: RespuestaCanje? = nil
    @State private var mostrarCelebracion: Bool = false
    
    public init(recompensa: RecompensaUiModel) {
        self.recompensa = recompensa
    }
    
    public var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(spacing: 0) {
                        // Cabecera con imagen grande o degradado
                        ZStack(alignment: .topLeading) {
                            if let urlStr = recompensa.imagenUrl, let url = URL(string: urlStr) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .empty:
                                        Color.bidealDarkGreen.opacity(0.8)
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    case .failure:
                                        degradadoCabecera
                                    @unknown default:
                                        degradadoCabecera
                                    }
                                }
                                .frame(height: 280)
                                .clipped()
                            } else {
                                degradadoCabecera
                                    .frame(height: 280)
                            }
                            
                            // Botón Volver circular
                            Button(action: { dismiss() }) {
                                Image(systemName: "arrow.left")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color.bidealDarkGreen)
                                    .frame(width: 40, height: 40)
                                    .background(Color.white.opacity(0.9))
                                    .clipShape(Circle())
                                    .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
                            }
                            .padding(.top, 50)
                            .padding(.leading, 20)
                        }
                        
                        // Panel de detalles superpuesto
                        VStack(alignment: .leading, spacing: 20) {
                            // Chip de Categoría
                            Text(recompensa.categoria.uppercased())
                                .font(.system(size: 11, weight: .heavy))
                                .foregroundColor(BiDealTheme.primary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(BiDealTheme.primaryLight)
                                .cornerRadius(8)
                            
                            // Título de la promoción
                            Text(recompensa.titulo)
                                .font(.system(size: 26, weight: .heavy, design: .rounded))
                                .foregroundColor(Color.bidealDarkGreen)
                                .lineLimit(3)
                            
                            // Nombre del comercio
                            HStack(spacing: 8) {
                                Image(systemName: "storefront.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(BiDealTheme.primary)
                                Text(recompensa.comercioNombre)
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.secondary)
                            }
                            
                            Divider()
                                .padding(.vertical, 4)
                            
                            // Descripción detallada
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Detalles de la promoción")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(Color.bidealDarkGreen)
                                
                                Text(recompensa.descripcion)
                                    .font(.system(size: 15))
                                    .foregroundColor(.secondary)
                                    .lineSpacing(4)
                            }
                            
                            // Tarjeta de Ubicación y Horarios
                            VStack(alignment: .leading, spacing: 14) {
                                HStack(spacing: 14) {
                                    ZStack {
                                        Circle()
                                            .fill(BiDealTheme.primaryLight)
                                            .frame(width: 44, height: 44)
                                        Image(systemName: "mappin.and.ellipse")
                                            .font(.system(size: 20))
                                            .foregroundColor(BiDealTheme.primary)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text("Ubicación en Pamplona")
                                            .font(.system(size: 15, weight: .bold))
                                            .foregroundColor(Color.bidealDarkGreen)
                                        Text(recompensa.direccion)
                                            .font(.system(size: 13))
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Divider()
                                
                                HStack(spacing: 14) {
                                    ZStack {
                                        Circle()
                                            .fill(Color(red: 224/255, green: 242/255, blue: 254/255))
                                            .frame(width: 44, height: 44)
                                        Image(systemName: "clock.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(Color(red: 2/255, green: 132/255, blue: 199/255))
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text("Horario de Atención")
                                            .font(.system(size: 15, weight: .bold))
                                            .foregroundColor(Color.bidealDarkGreen)
                                        Text("09:00 - 14:00 | 17:00 - 20:30")
                                            .font(.system(size: 13))
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding(18)
                            .background(Color.white)
                            .cornerRadius(18)
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(Color.bidealBorder, lineWidth: 1)
                            )
                            
                            Spacer().frame(height: 120) // Espacio para barra flotante inferior
                        }
                        .padding(24)
                        .background(Color.bidealBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                        .offset(y: -30)
                    }
                }
                .ignoresSafeArea(edges: .top)
                
                // Barra Flotante Inferior de Canje (Exacta a Android)
                VStack(spacing: 0) {
                    Divider()
                    
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Coste de canje")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 4) {
                                ZStack {
                                    Circle()
                                        .fill(Color(red: 251/255, green: 191/255, blue: 36/255))
                                        .frame(width: 18, height: 18)
                                    Text("KM")
                                        .font(.system(size: 8, weight: .heavy))
                                        .foregroundColor(Color(red: 146/255, green: 64/255, blue: 14/255))
                                }
                                Text("\(recompensa.precio)")
                                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                                    .foregroundColor(Color(red: 146/255, green: 64/255, blue: 14/255))
                                Text("KMC")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(Color(red: 146/255, green: 64/255, blue: 14/255))
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: ejecutarCanje) {
                            HStack(spacing: 8) {
                                if procesandoCanje {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Image(systemName: "gift.fill")
                                        .font(.system(size: 16, weight: .bold))
                                    Text("Canjear recompensa")
                                        .font(.system(size: 15, weight: .bold))
                                }
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)
                            .background(BiDealTheme.primary)
                            .cornerRadius(16)
                            .shadow(color: BiDealTheme.primary.opacity(0.3), radius: 6, x: 0, y: 3)
                        }
                        .disabled(procesandoCanje)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 24)
                    .background(Color.white)
                }
            }
            .alert("Información de Canje", isPresented: $mostrarAlertaSaldo) {
                Button("Entendido", role: .cancel) { }
            } message: {
                Text(mensajeAlerta)
            }
            .sheet(isPresented: $mostrarCelebracion) {
                if let canje = resultadoCanje {
                    CelebracionCanjeModal(canje: canje, recompensa: recompensa)
                }
            }
        }
    }
    
    private var degradadoCabecera: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [BiDealTheme.primary, Color.bidealDarkGreen]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Image(systemName: "storefront.fill")
                .font(.system(size: 80))
                .foregroundColor(.white.opacity(0.25))
        }
    }
    
    private func ejecutarCanje() {
        let saldoActual = authVM.kmcoinsBalance
        if saldoActual < recompensa.precio {
            mensajeAlerta = "No tienes suficientes KmCoins. Tienes \(saldoActual) KMC y necesitas \(recompensa.precio) KMC. ¡Sigue pedaleando para acumular más!"
            mostrarAlertaSaldo = true
            return
        }
        
        guard let userId = authVM.currentUser?.id, !userId.isEmpty else {
            mensajeAlerta = "Debes iniciar sesión para canjear recompensas."
            mostrarAlertaSaldo = true
            return
        }
        
        procesandoCanje = true
        Task {
            let res = await comerciosVM.canjear(recompensa: recompensa, usuarioId: userId)
            procesandoCanje = false
            
            if res.exito {
                resultadoCanje = res
                mostrarCelebracion = true
                await authVM.cargarSaldoKmCoins()
            } else {
                mensajeAlerta = res.mensaje
                mostrarAlertaSaldo = true
            }
        }
    }
}

// ==========================================
// MODAL CELEBRACIÓN DE CANJE (IDÉNTICO A ANDROID)
// ==========================================
struct CelebracionCanjeModal: View {
    let canje: RespuestaCanje
    let recompensa: RecompensaUiModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Cabecera con icono de éxito
                ZStack {
                    Circle()
                        .fill(BiDealTheme.primaryLight)
                        .frame(width: 80, height: 80)
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(BiDealTheme.primary)
                }
                .padding(.top, 24)
                
                VStack(spacing: 6) {
                    Text("¡Canje Exitoso!")
                        .font(.system(size: 26, weight: .heavy, design: .rounded))
                        .foregroundColor(Color.bidealDarkGreen)
                    
                    Text("Muestra este código al dependiente de \(recompensa.comercioNombre)")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                // Tarjeta con Código QR real y Código Alfanumérico
                VStack(spacing: 16) {
                    if let qrImage = generarCodigoQR(de: canje.codigoCanje) {
                        Image(uiImage: qrImage)
                            .interpolation(.none)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 190, height: 190)
                            .padding(12)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                    }
                    
                    // Código en grande
                    VStack(spacing: 4) {
                        Text("CÓDIGO DE CUPÓN")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.secondary)
                            .tracking(2)
                        
                        Text(canje.codigoCanje)
                            .font(.system(size: 28, weight: .heavy, design: .monospaced))
                            .foregroundColor(BiDealTheme.primary)
                            .tracking(3)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 8)
                    .background(BiDealTheme.primaryLight.opacity(0.5))
                    .cornerRadius(12)
                }
                .padding(20)
                .background(Color(red: 249/255, green: 250/255, blue: 251/255))
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.bidealBorder, lineWidth: 1)
                )
                
                // Resumen del producto
                HStack(spacing: 12) {
                    Image(systemName: "tag.fill")
                        .foregroundColor(BiDealTheme.primary)
                    Text(recompensa.titulo)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color.bidealDarkGreen)
                    Spacer()
                    Text("-\(recompensa.precio) KMC")
                        .font(.system(size: 14, weight: .heavy))
                        .foregroundColor(Color(red: 234/255, green: 88/255, blue: 12/255))
                }
                .padding(14)
                .background(Color.white)
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.bidealBorder, lineWidth: 1))
                .padding(.horizontal, 20)
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Text("Listo, volver")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(BiDealTheme.primary)
                        .cornerRadius(16)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    private func generarCodigoQR(de texto: String) -> UIImage? {
        let data = Data(texto.utf8)
        let filter = CIFilter.qrCodeGenerator()
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("M", forKey: "inputCorrectionLevel")
        
        guard let outputImage = filter.outputImage else { return nil }
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledImage = outputImage.transformed(by: transform)
        
        let context = CIContext()
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}
