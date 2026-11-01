import SwiftUI
import MapKit

public struct HomeView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var homeVM: HomeViewModel
    @EnvironmentObject var comerciosVM: ComerciosViewModel
    
    @State private var mostrarAjustes: Bool = false
    @State private var mostrarHitos: Bool = false
    @State private var mostrarMapaPantallaCompleta: Bool = false
    
    // Coordenadas oficiales de Pamplona
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 42.8168, longitude: -1.6432),
        span: MKCoordinateSpan(latitudeDelta: 0.035, longitudeDelta: 0.035)
    )
    
    @State private var comercioSeleccionadoEnMapa: RecompensaUiModel? = nil
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color.bidealBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Cabecera Oficial Idéntica a Android
                    HStack(spacing: 6) {
                        // Logo + BiDeal en cursiva
                        HStack(spacing: 6) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(BiDealTheme.primary)
                                    .frame(width: 38, height: 38)
                                Image(systemName: "bicycle")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            Text("BiDeal")
                                .font(.system(size: 26, weight: .heavy, design: .rounded))
                                .italic()
                                .foregroundColor(BiDealTheme.primary)
                        }
                        
                        Spacer()
                        
                        // Chip Racha Semanal (Fuego + Número)
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .foregroundColor(Color(red: 234/255, green: 88/255, blue: 12/255))
                                .font(.system(size: 14))
                            Text("\(homeVM.rachaSemanas)")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(Color(red: 234/255, green: 88/255, blue: 12/255))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(Color(red: 255/255, green: 237/255, blue: 213/255))
                        .cornerRadius(14)
                        
                        // Chip KmCoins (KMC)
                        HStack(spacing: 5) {
                            ZStack {
                                Circle()
                                    .fill(Color(red: 251/255, green: 191/255, blue: 36/255))
                                    .frame(width: 18, height: 18)
                                Text("KM")
                                    .font(.system(size: 8, weight: .heavy))
                                    .foregroundColor(Color(red: 146/255, green: 64/255, blue: 14/255))
                            }
                            Text("\(authVM.kmcoinsBalance)")
                                .font(.system(size: 14, weight: .heavy))
                                .foregroundColor(Color(red: 146/255, green: 64/255, blue: 14/255))
                            Text("KMC")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(Color(red: 146/255, green: 64/255, blue: 14/255))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color(red: 254/255, green: 243/255, blue: 199/255))
                        .cornerRadius(14)
                        
                        // Botón Engranaje (Ajustes)
                        Button(action: { mostrarAjustes = true }) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 20))
                                .foregroundColor(Color.bidealDarkGreen)
                                .frame(width: 36, height: 36)
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 8)
                    .background(Color.bidealBackground)
                    
                    // Contenido Scrolleable
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            // Saludo al ciclista
                            VStack(alignment: .leading, spacing: 2) {
                                Text("¡Hola, \(authVM.currentUser?.nombre ?? "Ciclista")!")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(Color.bidealDarkGreen)
                                Text("Hoy es un buen día para rodar.")
                                    .font(.system(size: 16))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.top, 4)
                            
                            // Tarjeta de Mapa Real de Comercios de Pamplona
                            TarjetaMapaHome(
                                region: $region,
                                comercios: comerciosVM.recompensas,
                                seleccionado: $comercioSeleccionadoEnMapa,
                                onExpandir: { mostrarMapaPantallaCompleta = true }
                            )
                            
                            // Tarjeta de Progreso Automático (Verde Bosque #14532D)
                            TarjetaProgresoAutomaticoView(
                                kmHoy: homeVM.kmHoy,
                                siguienteMision: homeVM.siguienteMision,
                                onVerMisiones: { mostrarHitos = true }
                            )
                            
                            // Sección de Impacto Ambiental (MITECO)
                            SeccionImpactoAmbientalView(distanciaTotal: homeVM.distanciaTotal)
                            
                            Spacer().frame(height: 30)
                        }
                        .padding(.horizontal, 18)
                    }
                }
            }
            .sheet(isPresented: $mostrarAjustes) {
                AjustesView()
            }
            .sheet(isPresented: $mostrarHitos) {
                CaminoDeMisionesModal(misiones: homeVM.misionesDiarias)
            }
            .fullScreenCover(isPresented: $mostrarMapaPantallaCompleta) {
                MapaPantallaCompletaView(
                    region: $region,
                    comercios: comerciosVM.recompensas,
                    seleccionado: $comercioSeleccionadoEnMapa,
                    onCerrar: { mostrarMapaPantallaCompleta = false }
                )
            }
            .onAppear {
                homeVM.sincronizarHealthKitAutomatico()
                if let u = authVM.currentUser {
                    homeVM.actualizarConUsuario(u)
                }
            }
            .onChange(of: authVM.currentUser?.id) { _ in
                if let u = authVM.currentUser {
                    homeVM.actualizarConUsuario(u)
                }
            }
        }
    }
}

// ==========================================
// COMPONENTE: TARJETA DE MAPA DE COMERCIOS
// ==========================================
struct TarjetaMapaHome: View {
    @Binding var region: MKCoordinateRegion
    let comercios: [RecompensaUiModel]
    @Binding var seleccionado: RecompensaUiModel?
    let onExpandir: () -> Void
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Map(coordinateRegion: $region, annotationItems: comercios) { r in
                MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: r.latitud ?? 42.8168, longitude: r.longitud ?? -1.6432)) {
                    Button(action: {
                        withAnimation(.spring()) {
                            seleccionado = r
                        }
                    }) {
                        VStack(spacing: 0) {
                            ZStack {
                                Circle()
                                    .fill(seleccionado?.id == r.id ? Color.orange : BiDealTheme.primary)
                                    .frame(width: 34, height: 34)
                                    .shadow(radius: 4)
                                Image(systemName: "storefront.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                            }
                            Image(systemName: "triangle.fill")
                                .font(.system(size: 8))
                                .foregroundColor(seleccionado?.id == r.id ? Color.orange : BiDealTheme.primary)
                                .rotationEffect(.degrees(180))
                                .offset(y: -2)
                        }
                    }
                }
            }
            .frame(height: 175)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.bidealBorder, lineWidth: 1)
            )
            
            // Botones flotantes (Pantalla completa y centrar)
            HStack {
                Spacer()
                VStack(spacing: 8) {
                    Button(action: onExpandir) {
                        Image(systemName: "viewfinder")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(BiDealTheme.primary)
                            .frame(width: 36, height: 36)
                            .background(Color.white.opacity(0.95))
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.1), radius: 4)
                    }
                    
                    Button(action: {
                        withAnimation {
                            region.center = CLLocationCoordinate2D(latitude: 42.8168, longitude: -1.6432)
                        }
                    }) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(BiDealTheme.primary)
                            .frame(width: 36, height: 36)
                            .background(Color.white.opacity(0.95))
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.1), radius: 4)
                    }
                }
                .padding(10)
            }
            .frame(height: 175, alignment: .topTrailing)
            
            // Drawer emergente al pulsar un pin
            if let sel = seleccionado {
                HStack(alignment: .center, spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text(sel.comercioNombre)
                                .font(.subheadline)
                                .fontWeight(.heavy)
                                .foregroundColor(Color.bidealDarkGreen)
                            
                            Text(sel.categoria)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(BiDealTheme.primary)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(BiDealTheme.primaryLight)
                                .cornerRadius(6)
                        }
                        
                        Text(sel.titulo)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    Text("\(sel.precio) KMC")
                        .font(.caption)
                        .fontWeight(.heavy)
                        .foregroundColor(BiDealTheme.accentGold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(BiDealTheme.goldLight)
                        .cornerRadius(8)
                    
                    Button(action: { seleccionado = nil }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
                .padding(10)
                .background(Color.bidealSurface.opacity(0.96))
                .cornerRadius(14)
                .shadow(radius: 6)
                .padding(8)
            }
        }
    }
}

// ==========================================
// COMPONENTE: TARJETA PROGRESO AUTOMÁTICO
// (Verde Bosque #14532D - IDÉNTICA A ANDROID)
// ==========================================
struct TarjetaProgresoAutomaticoView: View {
    let kmHoy: Double
    let siguienteMision: (meta: Double, faltan: Double, progreso: Double, completadoTodo: Bool)
    let onVerMisiones: () -> Void
    
    var body: some View {
        VStack(spacing: 14) {
            // Chip Superior: Camino de Misiones
            Button(action: onVerMisiones) {
                HStack(spacing: 6) {
                    Image(systemName: "hand.tap.fill")
                        .font(.system(size: 13))
                        .foregroundColor(Color(red: 134/255, green: 239/255, blue: 172/255))
                    Text("Camino de Misiones")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(red: 134/255, green: 239/255, blue: 172/255))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color(red: 134/255, green: 239/255, blue: 172/255))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.15))
                .clipShape(Capsule())
            }
            
            // Icono de Bicicleta Blanco Gigante
            Image(systemName: "bicycle")
                .resizable()
                .scaledToFit()
                .frame(width: 56, height: 56)
                .foregroundColor(.white)
            
            // Kilómetros Registrados Hoy (56sp ExtraBold)
            VStack(spacing: 2) {
                Text(String(format: "%.1f km", kmHoy))
                    .font(.system(size: 54, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Registrados hoy")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.75))
            }
            
            // Barra de Progreso a la siguiente misión
            VStack(spacing: 6) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.2))
                            .frame(height: 10)
                        
                        Capsule()
                            .fill(Color(red: 134/255, green: 239/255, blue: 172/255))
                            .frame(width: geo.size.width * CGFloat(siguienteMision.progreso), height: 10)
                    }
                }
                .frame(height: 10)
                
                Text(siguienteMision.completadoTodo ?
                     "¡Has completado todas las misiones de hoy (15 km)!" :
                     "¡Estás a \(String(format: "%.1f", siguienteMision.faltan)) km de tu siguiente misión (\(Int(siguienteMision.meta)) km)!"
                )
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color(red: 134/255, green: 239/255, blue: 172/255))
            }
            .padding(.top, 4)
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
        .background(Color(red: 20/255, green: 83/255, blue: 45/255)) // #14532D (BiDealForest)
        .cornerRadius(28)
        .shadow(color: Color(red: 20/255, green: 83/255, blue: 45/255).opacity(0.35), radius: 12, x: 0, y: 6)
    }
}

// ==========================================
// COMPONENTE: IMPACTO AMBIENTAL (MITECO)
// ==========================================
struct SeccionImpactoAmbientalView: View {
    let distanciaTotal: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Tu Huella Positiva en Pamplona")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(Color.bidealDarkGreen)
            
            HStack(spacing: 10) {
                // CO2 Evitado
                TarjetaImpactoMini(
                    icono: "leaf.fill",
                    colorIcono: BiDealTheme.primary,
                    valor: String(format: "%.1f kg", distanciaTotal * 0.142),
                    etiqueta: "CO₂ Evitado",
                    subetiqueta: "Estándar MITECO"
                )
                
                // Energía Limpia
                TarjetaImpactoMini(
                    icono: "bolt.fill",
                    colorIcono: Color(red: 234/255, green: 88/255, blue: 12/255),
                    valor: "\(Int(distanciaTotal * 40)) Wh",
                    etiqueta: "Energía Limpia",
                    subetiqueta: "Generada en bici"
                )
                
                // Tiempo Pedaleado
                TarjetaImpactoMini(
                    icono: "clock.fill",
                    colorIcono: Color(red: 14/255, green: 165/255, blue: 233/255),
                    valor: "\(Int(distanciaTotal * 3.5)) min",
                    etiqueta: "Movilidad Activa",
                    subetiqueta: "Tiempo en ruta"
                )
            }
            
            Text("ℹ️ Metodología Oficial: Calculado según el estándar MITECO (Ministerio para la Transición Ecológica) estimando la sustitución media de un turismo urbano de combustión (142 g CO2/km).")
                .font(.system(size: 10))
                .foregroundColor(.secondary)
                .italic()
                .padding(.top, 4)
        }
    }
}

struct TarjetaImpactoMini: View {
    let icono: String
    let colorIcono: Color
    let valor: String
    let etiqueta: String
    let subetiqueta: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack {
                Circle()
                    .fill(colorIcono.opacity(0.12))
                    .frame(width: 30, height: 30)
                Image(systemName: icono)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(colorIcono)
            }
            
            Text(valor)
                .font(.system(size: 16, weight: .heavy))
                .foregroundColor(Color.bidealDarkGreen)
            
            VStack(alignment: .leading, spacing: 1) {
                Text(etiqueta)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.primary)
                Text(subetiqueta)
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.bidealSurface)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.bidealBorder, lineWidth: 1))
    }
}

// Modal Camino de Misiones
struct CaminoDeMisionesModal: View {
    @Environment(\.dismiss) var dismiss
    let misiones: [MisionUiModel]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    ForEach(misiones) { m in
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(m.completada ? BiDealTheme.primaryLight : Color.gray.opacity(0.1))
                                    .frame(width: 44, height: 44)
                                Image(systemName: m.completada ? "checkmark.circle.fill" : "star.fill")
                                    .foregroundColor(m.completada ? BiDealTheme.primary : .gray)
                                    .font(.title3)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(m.titulo)
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                
                                HStack {
                                    Text("\(String(format: "%.1f", m.kmActuales)) / \(Int(m.kmObjetivo)) km")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("+\(m.recompensaCoins) KMC")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(BiDealTheme.accentGold)
                                }
                                
                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        Capsule().fill(Color.gray.opacity(0.2)).frame(height: 6)
                                        Capsule().fill(BiDealTheme.primary).frame(width: geo.size.width * CGFloat(m.progreso), height: 6)
                                    }
                                }
                                .frame(height: 6)
                            }
                        }
                        .padding(14)
                        .background(Color.bidealSurface)
                        .cornerRadius(16)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.bidealBorder, lineWidth: 1))
                    }
                }
                .padding()
            }
            .navigationTitle("Camino de Misiones")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") { dismiss() }
                }
            }
        }
    }
}

// Modal Mapa Pantalla Completa
struct MapaPantallaCompletaView: View {
    @Binding var region: MKCoordinateRegion
    let comercios: [RecompensaUiModel]
    @Binding var seleccionado: RecompensaUiModel?
    let onCerrar: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Map(coordinateRegion: $region, annotationItems: comercios) { r in
                MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: r.latitud ?? 42.8168, longitude: r.longitud ?? -1.6432)) {
                    Button(action: { seleccionado = r }) {
                        ZStack {
                            Circle().fill(BiDealTheme.primary).frame(width: 38, height: 38)
                            Image(systemName: "storefront.fill").foregroundColor(.white)
                        }
                    }
                }
            }
            .ignoresSafeArea()
            
            Button(action: onCerrar) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.white)
                    .background(Color.black.opacity(0.4))
                    .clipShape(Circle())
                    .padding()
            }
        }
    }
}
