import SwiftUI

public struct EstadisticasView: View {
    @EnvironmentObject var estadisticasVM: EstadisticasViewModel
    @EnvironmentObject var homeVM: HomeViewModel
    @EnvironmentObject var authVM: AuthViewModel
    
    @AppStorage("tipoVehiculo") private var tipoVehiculo: String = "coche_combustion"
    
    @State private var mostrarDialogoTotal: Bool = false
    @State private var mostrarDialogoCo2: Bool = false
    @State private var mostrarDialogoTiempo: Bool = false
    @State private var mostrarDialogoDias: Bool = false
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color.bidealBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    cabeceraImpacto
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            graficoSemanal
                            logrosGlobales
                            huellaPamplona
                            TarjetaLigaAmigosView()
                                .padding(.horizontal)
                            Spacer().frame(height: 30)
                        }
                        .padding(.vertical)
                    }
                }
            }
            .alert("Total Rodado en Pamplona", isPresented: $mostrarDialogoTotal) {
                Button("Genial", role: .cancel) { }
            } message: {
                Text("Has recorrido un total de \(String(format: "%.1f", homeVM.distanciaTotalKm)) km en bicicleta. ¡Eso equivale a dar más de \(max(1, Int(homeVM.distanciaTotalKm / 8.0))) vueltas completas a Pamplona!")
            }
            .alert("Impacto Ambiental CO₂", isPresented: $mostrarDialogoCo2) {
                Button("Entendido", role: .cancel) { }
            } message: {
                Text("Has evitado la emisión de \(String(format: "%.1f", homeVM.co2TotalEvitadoKg)) kg de CO₂ a la atmósfera de Navarra pedaleando en vez de conducir.")
            }
            .alert("Tiempo Activo y Salud", isPresented: $mostrarDialogoTiempo) {
                Button("Continuar", role: .cancel) { }
            } message: {
                Text("Has pedaleado activamente durante \(Int(homeVM.distanciaTotalKm * 3.5)) minutos, mejorando tu capacidad cardiovascular y reduciendo el estrés urbano.")
            }
            .alert("Constancia y Días Activos", isPresented: $mostrarDialogoDias) {
                Button("Aceptar", role: .cancel) { }
            } message: {
                Text("Llevas pedaleando con constancia este mes. ¡Cada día que eliges la bici sumas puntos para tu salud y para el comercio local!")
            }
        }
    }
    
    private var cabeceraImpacto: some View {
        HStack {
            Spacer()
            Text("Tu Impacto")
                .font(.system(size: 26, weight: .heavy, design: .rounded))
                .foregroundColor(BiDealTheme.primary)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .background(Color.bidealBackground)
    }
    
    private var graficoSemanal: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Actividad Semanal")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Color.bidealDarkGreen)
                    Text("Media: \(String(format: "%.1f", estadisticasVM.kmTotalSemana / 5.0)) km/día")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text("\(String(format: "%.1f", estadisticasVM.kmTotalSemana)) km")
                    .font(.headline)
                    .fontWeight(.heavy)
                    .foregroundColor(BiDealTheme.primary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(BiDealTheme.primaryLight)
                    .cornerRadius(10)
            }
            
            HStack(alignment: .bottom, spacing: 12) {
                ForEach(estadisticasVM.diasSemana) { dia in
                    VStack(spacing: 6) {
                        Text(dia.km > 0 ? String(format: "%.1f", dia.km) : "")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.secondary)
                        
                        ZStack(alignment: .bottom) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(red: 243/255, green: 244/255, blue: 246/255))
                                .frame(width: 32, height: 110)
                            
                            RoundedRectangle(cornerRadius: 6)
                                .fill(dia.esHoy ? Color(red: 234/255, green: 88/255, blue: 12/255) : BiDealTheme.primary)
                                .frame(width: 32, height: max(CGFloat(dia.km / 10.0) * 110.0, dia.km > 0 ? 10 : 0))
                        }
                        
                        Text(dia.letra)
                            .font(.caption)
                            .fontWeight(dia.esHoy ? .heavy : .medium)
                            .foregroundColor(dia.esHoy ? Color(red: 234/255, green: 88/255, blue: 12/255) : .primary)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
        .padding(18)
        .background(Color.white)
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.bidealBorder, lineWidth: 1))
        .padding(.horizontal)
    }
    
    private var logrosGlobales: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Logros Globales")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color.bidealDarkGreen)
            
            HStack(spacing: 12) {
                TarjetaLogroItem(
                    icono: "bicycle",
                    valor: "\(String(format: "%.1f", homeVM.distanciaTotalKm)) km",
                    etiqueta: "Total Rodado",
                    subetiqueta: "Histórico acumulado"
                ) {
                    mostrarDialogoTotal = true
                }
                
                TarjetaLogroItem(
                    icono: "leaf.fill",
                    valor: "\(String(format: "%.1f", homeVM.co2TotalEvitadoKg)) kg",
                    etiqueta: "CO₂ Ahorrado",
                    subetiqueta: "Vehículo: Coche"
                ) {
                    mostrarDialogoCo2 = true
                }
            }
            
            HStack(spacing: 12) {
                TarjetaLogroItem(
                    icono: "clock.fill",
                    valor: "\(Int(homeVM.distanciaTotalKm * 3.5)) min",
                    etiqueta: "Tiempo Activo",
                    subetiqueta: "Beneficios de salud"
                ) {
                    mostrarDialogoTiempo = true
                }
                
                TarjetaLogroItem(
                    icono: "calendar",
                    valor: "\(max(1, Int(homeVM.distanciaTotalKm / 3.0))) días",
                    etiqueta: "Días Activos",
                    subetiqueta: "Constancia en bici"
                ) {
                    mostrarDialogoDias = true
                }
            }
        }
        .padding(.horizontal)
    }
    
    private var huellaPamplona: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Tu Huella Positiva en Pamplona")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color.bidealDarkGreen)
                Text("Beneficios generados al pedalear en lugar de coche:")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            
            let km = homeVM.distanciaTotalKm
            let diasArbol = km * 0.12
            let litrosGasolina = km * 0.075
            let eurosAhorrados = litrosGasolina * 1.62
            let energiaWh = Int(km * 25)
            
            HStack(spacing: 12) {
                TarjetaEquivalenciaItem(
                    icono: "tree.fill",
                    valor: String(format: "%.1f días", diasArbol),
                    titulo: "Árboles",
                    subtitulo: "Absorción de un pino adulto",
                    colorFondo: Color(red: 240/255, green: 253/255, blue: 244/255),
                    colorTexto: Color(red: 22/255, green: 101/255, blue: 52/255)
                )
                
                TarjetaEquivalenciaItem(
                    icono: "fuelpump.fill",
                    valor: String(format: "%.1f L", litrosGasolina),
                    titulo: "Combustible",
                    subtitulo: "Gasolina fósil no quemada",
                    colorFondo: Color(red: 254/255, green: 243/255, blue: 199/255),
                    colorTexto: Color(red: 180/255, green: 83/255, blue: 9/255)
                )
            }
            
            HStack(spacing: 12) {
                TarjetaEquivalenciaItem(
                    icono: "eurosign.circle.fill",
                    valor: String(format: "%.2f €", eurosAhorrados),
                    titulo: "Bolsillo",
                    subtitulo: "Ahorrado en gasolina",
                    colorFondo: Color(red: 236/255, green: 253/255, blue: 245/255),
                    colorTexto: Color(red: 5/255, green: 150/255, blue: 105/255)
                )
                
                TarjetaEquivalenciaItem(
                    icono: "bolt.fill",
                    valor: "\(energiaWh) Wh",
                    titulo: "Energía Limpia",
                    subtitulo: "Generada con tus piernas",
                    colorFondo: Color(red: 239/255, green: 246/255, blue: 255/255),
                    colorTexto: Color(red: 37/255, green: 99/255, blue: 235/255)
                )
            }
        }
        .padding(.horizontal)
    }
}

struct TarjetaLogroItem: View {
    let icono: String
    let valor: String
    let etiqueta: String
    let subetiqueta: String
    let onClick: () -> Void
    
    var body: some View {
        Button(action: onClick) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(BiDealTheme.primaryLight)
                            .frame(width: 36, height: 36)
                        Image(systemName: icono)
                            .font(.system(size: 16))
                            .foregroundColor(BiDealTheme.primary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.secondary)
                }
                
                Text(valor)
                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                    .foregroundColor(Color.bidealDarkGreen)
                
                Text(etiqueta)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color.bidealDarkGreen)
                
                Text(subetiqueta)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.bidealBorder, lineWidth: 1))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TarjetaEquivalenciaItem: View {
    let icono: String
    let valor: String
    let titulo: String
    let subtitulo: String
    let colorFondo: Color
    let colorTexto: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: icono)
                    .font(.system(size: 16))
                    .foregroundColor(colorTexto)
                Text(titulo)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(colorTexto)
            }
            
            Text(valor)
                .font(.system(size: 18, weight: .heavy, design: .rounded))
                .foregroundColor(colorTexto)
            
            Text(subtitulo)
                .font(.system(size: 11))
                .foregroundColor(colorTexto.opacity(0.8))
                .lineLimit(1)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(colorFondo)
        .cornerRadius(16)
    }
}
