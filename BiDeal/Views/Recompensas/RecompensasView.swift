import SwiftUI

public struct RecompensasView: View {
    @EnvironmentObject var comerciosVM: ComerciosViewModel
    @EnvironmentObject var homeVM: HomeViewModel
    
    @State private var descuentoSeleccionado: (Descuento, Comercio)?
    @State private var mostrarModalQR: Bool = false
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Balance de KmCoins en la parte superior
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Tus KmCoins Disponibles")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            HStack(spacing: 6) {
                                Image(systemName: "circle.circle.fill")
                                    .foregroundColor(BiDealTheme.accentGold)
                                Text("\(homeVM.usuario.kmcoins_balance)")
                                    .font(.title)
                                    .fontWeight(.heavy)
                                    .foregroundColor(BiDealTheme.accentGold)
                                Text("KMC")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(BiDealTheme.accentGold)
                            }
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color.bidealSurface)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.bidealBorder, lineWidth: 1)
                    )
                    .padding(.horizontal)
                    
                    // Lista de Recompensas de Comercios de Pamplona
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Ventajas y Descuentos en Pamplona")
                            .font(.headline)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        ForEach(comerciosVM.comercios) { comercio in
                            if let descuentos = comercio.descuentos {
                                ForEach(descuentos) { d in
                                    TarjetaRecompensaItem(descuento: d, comercio: comercio) {
                                        descuentoSeleccionado = (d, comercio)
                                        mostrarModalQR = true
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(Color.bidealBackground)
            .navigationTitle("Recompensas")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $mostrarModalQR) {
                if let (descuento, comercio) = descuentoSeleccionado {
                    ModalCanjeQR(descuento: descuento, comercio: comercio)
                }
            }
        }
    }
}

struct TarjetaRecompensaItem: View {
    let descuento: Descuento
    let comercio: Comercio
    let onCanjear: () -> Void
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(BiDealTheme.primaryLight)
                    .frame(width: 48, height: 48)
                Text(comercio.emojiCategoria)
                    .font(.title3)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(comercio.nombre)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(BiDealTheme.primary)
                Text(descuento.titulo)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                if let dir = comercio.direccion {
                    Text(dir)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Button(action: onCanjear) {
                VStack(spacing: 2) {
                    Text("\(descuento.precio_kmcoins)")
                        .font(.caption)
                        .fontWeight(.heavy)
                    Text("KMC")
                        .font(.system(size: 8, weight: .bold))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(BiDealTheme.primary)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
        .padding(14)
        .background(Color.bidealSurface)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.bidealBorder, lineWidth: 1)
        )
    }
}

struct ModalCanjeQR: View {
    @Environment(\.dismiss) var dismiss
    let descuento: Descuento
    let comercio: Comercio
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Canje en Mostrador")
                .font(.headline)
            
            Text(comercio.nombre)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(descuento.titulo)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            // Simulación visual del Código QR
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .frame(width: 220, height: 220)
                    .shadow(radius: 6)
                
                VStack(spacing: 8) {
                    Image(systemName: "qrcode")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 170, height: 170)
                        .foregroundColor(.black)
                    Text("BD-\(descuento.id.prefix(6).uppercased())")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(.gray)
                }
            }
            .padding()
            
            Text("Muestra este código al dependiente de \(comercio.nombre) para disfrutar de tu ventaja.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            
            Button("Cerrar") {
                dismiss()
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.bidealBackground)
            .foregroundColor(.primary)
            .cornerRadius(12)
        }
        .padding(25)
    }
}
