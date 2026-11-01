import SwiftUI

public struct PaginaTutorialModel: Identifiable {
    public let id = UUID()
    public let titulo: String
    public let descripcion: String
    public let icono: String
    public let colorFondo: Color
}

public struct TutorialView: View {
    let onFinishTutorial: () -> Void
    @State private var paginaActual: Int = 0
    
    let paginas: [PaginaTutorialModel] = [
        PaginaTutorialModel(
            titulo: "¡Bienvenido a BiDeal!",
            descripcion: "Mueve tu ciudad de forma sostenible. Pedalea por Pamplona y convierte cada kilómetro en ventajas reales en tus tiendas locales.",
            icono: "bicycle",
            colorFondo: BiDealTheme.primary
        ),
        PaginaTutorialModel(
            titulo: "Rastreo Pasivo Inteligente",
            descripcion: "El sistema detecta automáticamente cuando montas en bici en segundo plano. No necesitas iniciar ningún botón de ruta; solo sal a pedalear.",
            icono: "figure.outdoor.cycle",
            colorFondo: Color(red: 20/255, green: 83/255, blue: 45/255)
        ),
        PaginaTutorialModel(
            titulo: "Gana KMCoins con Misiones",
            descripcion: "Supera tus metas diarias y semanales en el 'Camino de Misiones' para multiplicar tus recompensas y ayudar al medio ambiente.",
            icono: "star.fill",
            colorFondo: Color(red: 2/255, green: 132/255, blue: 199/255)
        ),
        PaginaTutorialModel(
            titulo: "Canjea en Comercios Locales",
            descripcion: "Acumula KMCoins y escanea el código QR en los mostradores de los comercios adheridos para disfrutar de descuentos exclusivos.",
            icono: "qrcode.viewfinder",
            colorFondo: Color(red: 234/255, green: 88/255, blue: 12/255)
        )
    ]
    
    public init(onFinishTutorial: @escaping () -> Void = {}) {
        self.onFinishTutorial = onFinishTutorial
    }
    
    public var body: some View {
        ZStack {
            Color.bidealBackground
                .ignoresSafeArea()
            
            VStack {
                // Barra superior con botón Saltar
                HStack {
                    Spacer()
                    Button(action: onFinishTutorial) {
                        Text("Saltar")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                
                // Indicador de pasos superior (Pill animado)
                HStack(spacing: 8) {
                    ForEach(0..<paginas.count, id: \.self) { index in
                        Capsule()
                            .fill(index == paginaActual ? BiDealTheme.primary : Color.gray.opacity(0.3))
                            .frame(width: index == paginaActual ? 32 : 12, height: 6)
                            .animation(.spring(), value: paginaActual)
                    }
                }
                .padding(.top, 8)
                
                Spacer()
                
                // Carrusel / Paginación central
                TabView(selection: $paginaActual) {
                    ForEach(0..<paginas.count, id: \.self) { index in
                        let pag = paginas[index]
                        VStack(spacing: 24) {
                            // Círculo grande con icono
                            ZStack {
                                Circle()
                                    .fill(pag.colorFondo.opacity(0.15))
                                    .frame(width: 150, height: 150)
                                
                                Image(systemName: pag.icono)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 70, height: 70)
                                    .foregroundColor(pag.colorFondo)
                            }
                            
                            VStack(spacing: 12) {
                                Text(pag.titulo)
                                    .font(.system(size: 26, weight: .heavy, design: .rounded))
                                    .foregroundColor(Color.bidealDarkGreen)
                                    .multilineTextAlignment(.center)
                                
                                Text(pag.descripcion)
                                    .font(.system(size: 15))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(4)
                                    .padding(.horizontal, 24)
                            }
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 380)
                
                Spacer()
                
                // Botón Siguiente / Empezar
                VStack(spacing: 12) {
                    Button(action: {
                        if paginaActual < paginas.count - 1 {
                            withAnimation {
                                paginaActual += 1
                            }
                        } else {
                            onFinishTutorial()
                        }
                    }) {
                        HStack(spacing: 8) {
                            Text(paginaActual == paginas.count - 1 ? "Empezar a Rodar" : "Siguiente")
                                .font(.system(size: 16, weight: .bold))
                            
                            Image(systemName: paginaActual == paginas.count - 1 ? "bicycle" : "arrow.right")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(BiDealTheme.primary)
                        .cornerRadius(18)
                        .shadow(color: BiDealTheme.primary.opacity(0.35), radius: 8, x: 0, y: 4)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
    }
}
