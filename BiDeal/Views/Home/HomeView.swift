import SwiftUI

public struct HomeView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var homeVM: HomeViewModel
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Cabecera: Saludo y Balance de KmCoins
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("¡Aupa, \(homeVM.usuario.nombre ?? "Ciclista")! 👋")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            Text("Pedalea por Pamplona y gana descuentos")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        
                        // Badge de KmCoins
                        HStack(spacing: 6) {
                            Image(systemName: "circle.circle.fill")
                                .foregroundColor(BiDealTheme.accentGold)
                            Text("\(homeVM.usuario.kmcoins_balance)")
                                .font(.headline)
                                .fontWeight(.heavy)
                                .foregroundColor(BiDealTheme.accentGold)
                            Text("KMC")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(BiDealTheme.accentGold)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(BiDealTheme.goldLight)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // Tarjeta Principal de Grabación de Trayecto
                    TarjetaGrabacionCiclista()
                        .padding(.horizontal)
                    
                    // Huella Positiva en Pamplona
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Tu Huella Positiva en Pamplona")
                            .font(.headline)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            TarjetaImpacto(
                                icono: "leaf.fill",
                                valor: "\(CO2Calculator.formatearCo2(co2Kg: homeVM.usuario.co2_evitado_kg))",
                                titulo: "CO₂ Evitado",
                                subtitulo: "Sin emisiones fósiles",
                                color: BiDealTheme.primary
                            )
                            TarjetaImpacto(
                                icono: "tree.fill",
                                valor: String(format: "%.1f días", CO2Calculator.calcularDiasArbol(co2Kg: homeVM.usuario.co2_evitado_kg)),
                                titulo: "Árboles",
                                subtitulo: "Absorción equivalente",
                                color: Color.green
                            )
                            TarjetaImpacto(
                                icono: "fuelpump.fill",
                                valor: String(format: "%.1f L", CO2Calculator.calcularLitrosGasolinaAhorrados(distanciaKm: homeVM.usuario.kilometros_totales)),
                                titulo: "Combustible",
                                subtitulo: "Gasolina no quemada",
                                color: BiDealTheme.accentGold
                            )
                            TarjetaImpacto(
                                icono: "eurosign.circle.fill",
                                valor: String(format: "%.2f €", CO2Calculator.calcularEurosAhorrados(distanciaKm: homeVM.usuario.kilometros_totales)),
                                titulo: "Ahorro",
                                subtitulo: "En tu bolsillo",
                                color: Color.blue
                            )
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .background(Color.bidealBackground)
            .navigationTitle("BiDeal")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $homeVM.mostrarModalResumen) {
                if let act = homeVM.ultimaActividad {
                    ModalResumenActividad(actividad: act)
                }
            }
        }
    }
}

struct TarjetaGrabacionCiclista: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var homeVM: HomeViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            if locationManager.estaGrabando {
                // Modo Grabación Activa
                VStack(spacing: 12) {
                    HStack {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 10, height: 10)
                        Text("GRABANDO TRAYECTO")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                        Spacer()
                        Text(formatearTiempo(segundos: locationManager.tiempoSegundos))
                            .font(.headline)
                            .monospacedDigit()
                    }
                    
                    HStack(spacing: 30) {
                        VStack {
                            Text(String(format: "%.2f", locationManager.distanciaKm))
                                .font(.system(size: 38, weight: .black, design: .rounded))
                                .foregroundColor(BiDealTheme.primary)
                            Text("KILÓMETROS")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack {
                            Text(String(format: "%.1f", locationManager.velocidadActualKmH))
                                .font(.system(size: 38, weight: .black, design: .rounded))
                                .foregroundColor(.primary)
                            Text("KM/H")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Button(action: {
                        let actividad = locationManager.finalizarGrabacion()
                        homeVM.guardarActividad(actividad)
                    }) {
                        HStack {
                            Image(systemName: "stop.fill")
                            Text("Finalizar y Guardar Trayecto")
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                    }
                }
            } else {
                // Modo Reposo: Botón Iniciar Pedaleo
                VStack(spacing: 14) {
                    HStack {
                        Image(systemName: "bicycle")
                            .font(.system(size: 32))
                            .foregroundColor(BiDealTheme.primary)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Listo para rodar")
                                .font(.headline)
                                .fontWeight(.bold)
                            Text("Gana 10 KmCoins por cada kilómetro")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    
                    Button(action: {
                        locationManager.solicitarPermisos()
                        locationManager.solicitarPermisoSegundoPlano()
                        locationManager.iniciarGrabacion()
                    }) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Iniciar Pedaleo")
                                .font(.headline)
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(BiDealTheme.primary)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                    }
                }
            }
        }
        .padding(20)
        .background(Color.bidealSurface)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(locationManager.estaGrabando ? BiDealTheme.primary : Color.bidealBorder, lineWidth: locationManager.estaGrabando ? 2 : 1)
        )
    }
    
    private func formatearTiempo(segundos: Int) -> String {
        let hrs = segundos / 3600
        let min = (segundos % 3600) / 60
        let sec = segundos % 60
        if hrs > 0 {
            return String(format: "%02d:%02d:%02d", hrs, min, sec)
        } else {
            return String(format: "%02d:%02d", min, sec)
        }
    }
}

struct TarjetaImpacto: View {
    let icono: String
    let valor: String
    let titulo: String
    let subtitulo: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icono)
                .font(.title3)
                .foregroundColor(color)
            Text(valor)
                .font(.title3)
                .fontWeight(.heavy)
                .foregroundColor(.primary)
            VStack(alignment: .leading, spacing: 2) {
                Text(titulo)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Text(subtitulo)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.bidealSurface)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.bidealBorder, lineWidth: 1)
        )
    }
}

struct ModalResumenActividad: View {
    @Environment(\.dismiss) var dismiss
    let actividad: ActividadCiclista
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(BiDealTheme.primary)
            
            Text("¡Trayecto Completado!")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Has pedaleado por Pamplona y sumado recompensas:")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 20) {
                VStack {
                    Text(String(format: "%.2f km", actividad.distanciaKm))
                        .font(.title2)
                        .fontWeight(.heavy)
                    Text("Distancia")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Divider().frame(height: 40)
                VStack {
                    Text("+\(actividad.kmcoinsGanadas)")
                        .font(.title2)
                        .fontWeight(.heavy)
                        .foregroundColor(BiDealTheme.accentGold)
                    Text("KmCoins Ganadas")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Divider().frame(height: 40)
                VStack {
                    Text(CO2Calculator.formatearCo2(co2Kg: actividad.co2EvitadoKg))
                        .font(.title2)
                        .fontWeight(.heavy)
                        .foregroundColor(BiDealTheme.primary)
                    Text("CO₂ Evitado")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color.bidealBackground)
            .cornerRadius(16)
            
            Button("Genial, volver al inicio") {
                dismiss()
            }
            .font(.headline)
            .fontWeight(.bold)
            .frame(maxWidth: .infinity)
            .padding()
            .background(BiDealTheme.primary)
            .foregroundColor(.white)
            .cornerRadius(14)
        }
        .padding(25)
    }
}
