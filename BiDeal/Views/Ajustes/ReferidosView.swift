import SwiftUI

public struct ReferidosView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var homeVM: HomeViewModel
    
    @State private var inputCodigo: String = ""
    @State private var canjeando: Bool = false
    @State private var mensajeExito: String? = nil
    @State private var mensajeError: String? = nil
    @State private var codigoCopiado: Bool = false
    
    public init() {}
    
    var codigoReferido: String {
        if let cod = authVM.currentUser?.codigo_referido, !cod.isEmpty {
            return cod
        }
        let uid = authVM.currentUser?.id ?? "1001"
        return "BI-\(uid.prefix(6).uppercased())"
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color.bidealBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Tarjeta Principal de Tu Código (Verde Bosque)
                        tarjetaTuCodigo
                        
                        // Sección Canjear Código
                        seccionCanjearCodigo
                        
                        // Sección Cómo Funciona
                        seccionComoFunciona
                        
                        Spacer().frame(height: 30)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Promociones y Amigos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color.bidealDarkGreen)
                    }
                }
            }
        }
    }
    
    private var tarjetaTuCodigo: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 56, height: 56)
                Image(systemName: "gift.fill")
                    .font(.system(size: 26))
                    .foregroundColor(Color.bidealLime)
            }
            
            Text("Invita a tus amigos ciclistas")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            Text("Comparte tu código exclusivo de BiDeal. Cuando un amigo se registre o lo canjee, ambos recibiréis +25 KmCoins.")
                .font(.system(size: 13))
                .foregroundColor(Color.white.opacity(0.85))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 10)
            
            // Código Destacado
            HStack {
                Text(codigoReferido)
                    .font(.system(size: 24, weight: .heavy, design: .monospaced))
                    .foregroundColor(Color.bidealLime)
                
                Spacer()
                
                Button(action: {
                    UIPasteboard.general.string = codigoReferido
                    codigoCopiado = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        codigoCopiado = false
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: codigoCopiado ? "checkmark" : "doc.on.doc")
                        Text(codigoCopiado ? "¡Copiado!" : "Copiar")
                    }
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color.bidealDarkGreen)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .cornerRadius(10)
                }
            }
            .padding(14)
            .background(Color.black.opacity(0.2))
            .cornerRadius(14)
            
            // Botón Compartir en WhatsApp
            Button(action: compartirWhatsApp) {
                HStack(spacing: 8) {
                    Image(systemName: "paperplane.fill")
                    Text("Compartir por WhatsApp")
                        .fontWeight(.bold)
                }
                .font(.system(size: 15))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(BiDealTheme.primary)
                .cornerRadius(14)
                .shadow(color: BiDealTheme.primary.opacity(0.3), radius: 6, y: 3)
            }
        }
        .padding(20)
        .background(Color.bidealForest)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 5)
    }
    
    private var seccionCanjearCodigo: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("¿Tienes el código de un amigo?")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(Color.bidealDarkGreen)
            
            Text("Introdúcelo aquí para sumar +25 KmCoins directamente a tu saldo.")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(spacing: 10) {
                TextField("Ej: BI-8F42A1", text: $inputCodigo)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .font(.system(.body, design: .monospaced).weight(.bold))
                    .padding(12)
                    .background(Color.bidealBackground)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.bidealBorder, lineWidth: 1))
                
                Button(action: canjearCodigoAmigo) {
                    HStack {
                        if canjeando {
                            ProgressView().tint(.white)
                        } else {
                            Text("Canjear")
                                .fontWeight(.bold)
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                    .background(inputCodigo.trimmingCharacters(in: .whitespaces).isEmpty ? Color.gray : BiDealTheme.primary)
                    .cornerRadius(12)
                }
                .disabled(inputCodigo.trimmingCharacters(in: .whitespaces).isEmpty || canjeando)
            }
            
            if let ok = mensajeExito {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(BiDealTheme.primary)
                    Text(ok)
                        .font(.caption)
                        .foregroundColor(BiDealTheme.primaryDark)
                }
                .padding(10)
                .background(BiDealTheme.primaryLight)
                .cornerRadius(8)
            }
            
            if let err = mensajeError {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(.red)
                    Text(err)
                        .font(.caption)
                        .foregroundColor(.red)
                }
                .padding(10)
                .background(Color.red.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding(18)
        .background(Color.bidealSurface)
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.bidealBorder, lineWidth: 1))
    }
    
    private var seccionComoFunciona: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("¿Cómo funcionan las invitaciones?")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(Color.bidealDarkGreen)
            
            PasoReferidoItem(
                numero: "1",
                titulo: "Comparte tu enlace o código",
                descripcion: "Tus amigos se descargan BiDeal e introducen tu código al crear su cuenta o desde esta misma pantalla."
            )
            
            PasoReferidoItem(
                numero: "2",
                titulo: "Tu amigo gana 25 KMC",
                descripcion: "Al vincular tu código, recibe un impulso de bienvenida para canjear en comercios asociados."
            )
            
            PasoReferidoItem(
                numero: "3",
                titulo: "¡Tú recibes 25 KMC!",
                descripcion: "Tu saldo se incrementa al instante con monedas que no caducan en un año."
            )
        }
        .padding(18)
        .background(Color.bidealSurface)
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.bidealBorder, lineWidth: 1))
    }
    
    private func compartirWhatsApp() {
        let texto = "¡Pedalea conmigo por Pamplona en BiDeal! 🚲💨\n\nConvierte tus kilómetros en bici en descuentos en comercios locales.\n\nIntroduce mi código promocional: *\(codigoReferido)* al registrarte para recibir +25 KmCoins gratis.\n\nDescarga la app en: https://www.bideal.org"
        guard let encoded = texto.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "whatsapp://send?text=\(encoded)") else { return }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            let av = UIActivityViewController(activityItems: [texto], applicationActivities: nil)
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                rootVC.present(av, animated: true, completion: nil)
            }
        }
    }
    
    private func canjearCodigoAmigo() {
        let cod = inputCodigo.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard !cod.isEmpty else { return }
        canjeando = true
        mensajeExito = nil
        mensajeError = nil
        
        Task {
            do {
                let userId = authVM.currentUser?.id ?? ""
                let res = try await SupabaseService.shared.unirseAGrupo(userId: userId, codigo: cod)
                canjeando = false
                if res.status == "ok" {
                    mensajeExito = "¡Código canjeado con éxito! +25 KmCoins añadidos a tu saldo."
                    inputCodigo = ""
                    await authVM.cargarSaldoKmCoins()
                } else {
                    mensajeError = res.mensaje
                }
            } catch {
                canjeando = false
                mensajeError = "No se pudo canjear el código: \(error.localizedDescription)"
            }
        }
    }
}

struct PasoReferidoItem: View {
    let numero: String
    let titulo: String
    let descripcion: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(BiDealTheme.primaryLight)
                    .frame(width: 28, height: 28)
                Text(numero)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(BiDealTheme.primaryDark)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(titulo)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color.bidealDarkGreen)
                Text(descripcion)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
    }
}
