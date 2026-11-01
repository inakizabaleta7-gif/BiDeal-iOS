import SwiftUI
import MapKit

public struct HomeView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var homeVM: HomeViewModel
    @EnvironmentObject var comerciosVM: ComerciosViewModel
    
    @State private var mostrarAjustes: Bool = false
    @State private var mostrarHitos: Bool = false
    @State private var mostrarMapaPantallaCompleta: Bool = false
    @State private var mostrarDialogoRacha: Bool = false
    @State private var recompensaParaDetalle: RecompensaUiModel? = nil
    
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
                        // Logo Oficial BiDeal + BiDeal en cursiva
                        HStack(spacing: 8) {
                            BiDealLogoView(size: 42, cornerRadius: 8)
                            
                            Text("BiDeal")
                                .font(.system(size: 26, weight: .heavy, design: .rounded))
                                .italic()
                                .foregroundColor(BiDealTheme.primary)
                        }
                        
                        Spacer()
                        
                        // Chip Racha Semanal (Fuego + Número)
                        Button(action: { mostrarDialogoRacha = true }) {
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
                        }
                        
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
                            
                            // Tarjeta de Caducidad de KmCoins (si aplica)
                            if let cad = homeVM.caducidadCoins, cad.cantidad > 0 {
                                TarjetaCaducidadCoinsView(cantidad: cad.cantidad, diasRestantes: cad.dias)
                            }
                            
                            // Tarjeta de Mapa Real de Comercios de Pamplona
                            TarjetaMapaHome(
                                region: $region,
                                comercios: comerciosVM.recompensas,
                                seleccionado: $comercioSeleccionadoEnMapa,
                                onExpandir: { mostrarMapaPantallaCompleta = true },
                                onVerDetalle: { r in recompensaParaDetalle = r }
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
                HitosView()
            }
            .sheet(item: $recompensaParaDetalle) { recompensa in
                DetalleComercioView(recompensa: recompensa)
            }
            .fullScreenCover(isPresented: $mostrarMapaPantallaCompleta) {
                MapaPantallaCompletaView(
                    region: $region,
                    comercios: comerciosVM.recompensas,
                    seleccionado: $comercioSeleccionadoEnMapa,
                    onCerrar: { mostrarMapaPantallaCompleta = false }
                )
            }
            .alert("🔥 Racha Semanal", isPresented: $mostrarDialogoRacha) {
                Button("Entendido", role: .cancel) { }
            } message: {
                Text("Llevas \(homeVM.rachaSemanas) \(homeVM.rachaSemanas == 1 ? "semana consecutiva" : "semanas consecutivas") pedaleando en BiDeal.\n\nCompleta al menos 20 km cada semana para mantener encendida tu llama y desbloquear la Medalla de Oro de Navarra.")
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
    var onVerDetalle: (RecompensaUiModel) -> Void = { _ in }
    
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
                                    .fill(seleccionado?.id == r.id ? Color(red: 234/255, green: 88/255, blue: 12/255) : BiDealTheme.primary)
                                    .frame(width: 34, height: 34)
                                    .shadow(radius: 4)
                                Image(systemName: "storefront.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                            }
                            Image(systemName: "triangle.fill")
                                .font(.system(size: 8))
                                .foregroundColor(seleccionado?.id == r.id ? Color(red: 234/255, green: 88/255, blue: 12/255) : BiDealTheme.primary)
                                .rotationEffect(.degrees(180))
                                .offset(y: -2)
                        }
                    }
                }
            }
            .frame(height: 180)
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
            .frame(height: 180, alignment: .topTrailing)
            
            // Drawer emergente al pulsar un pin (Idéntico a Android)
            if let sel = seleccionado {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .center, spacing: 8) {
                        Text(sel.comercioNombre)
                            .font(.system(size: 15, weight: .heavy))
                            .foregroundColor(Color.bidealDarkGreen)
                        
                        Text(sel.categoria)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(BiDealTheme.primary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(BiDealTheme.primaryLight)
                            .cornerRadius(6)
                        
                        Spacer()
                        
                        Button(action: { seleccionado = nil }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                                .font(.system(size: 18))
                        }
                    }
                    
                    Text(sel.titulo)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text("📍 \(sel.direccion)")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    // Distancia y tiempo en bici
                    Text("🚲 1.2 km (~5 min en bici)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(BiDealTheme.primary)
                    
                    // Botones de Acción
                    HStack(spacing: 8) {
                        // Botón Ruta en bici
                        Button(action: {
                            let lat = sel.latitud ?? 42.8168
                            let lon = sel.longitud ?? -1.6432
                            if let url = URL(string: "maps://?daddr=\(lat),\(lon)&dirflg=b") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "bicycle")
                                Text("Ruta en bici")
                            }
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color.bidealDarkGreen)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color.secondary.opacity(0.12))
                            .cornerRadius(10)
                        }
                        
                        // Botón Ver Recompensa
                        Button(action: {
                            onVerDetalle(sel)
                        }) {
                            HStack(spacing: 4) {
                                Text("Ver (\(sel.precio) KMC)")
                            }
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(BiDealTheme.primary)
                            .cornerRadius(10)
                        }
                    }
                }
                .padding(12)
                .background(Color.bidealSurface)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 3)
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
                
                if siguienteMision.completadoTodo {
                    Text("¡Has completado todas las misiones diarias de hoy (15 km)!")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(red: 134/255, green: 239/255, blue: 172/255))
                } else {
                    Text("¡Estás a \(String(format: "%.1f", siguienteMision.faltan)) km de tu siguiente misión (\(String(format: "%.1f", siguienteMision.meta)) km)!")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(red: 134/255, green: 239/255, blue: 172/255))
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color.bidealForest)
        .cornerRadius(28)
        .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 5)
        .onTapGesture {
            onVerMisiones()
        }
    }
}

// ==========================================
// SECCIÓN DE IMPACTO AMBIENTAL (MITECO)
// ==========================================
struct SeccionImpactoAmbientalView: View {
    let distanciaTotal: Double
    
    var co2EvitadoKg: Double {
        distanciaTotal * 0.160
    }
    
    var arbolesEquivalentes: Double {
        co2EvitadoKg / 20.0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Tu Huella Verde en Pamplona")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(Color.bidealDarkGreen)
            
            HStack(spacing: 12) {
                TarjetaMetricaImpacto(
                    icono: "leaf.fill",
                    colorIcono: BiDealTheme.primary,
                    valor: String(format: "%.1f kg", co2EvitadoKg),
                    etiqueta: "CO₂ Ahorrado",
                    subetiqueta: "vs transporte motor"
                )
                
                TarjetaMetricaImpacto(
                    icono: "tree.fill",
                    colorIcono: Color(red: 34/255, green: 197/255, blue: 94/255),
                    valor: String(format: "%.2f", arbolesEquivalentes),
                    etiqueta: "Árboles",
                    subetiqueta: "oxígeno equivalente"
                )
            }
        }
    }
}

struct TarjetaMetricaImpacto: View {
    let icono: String
    let colorIcono: Color
    let valor: String
    let etiqueta: String
    let subetiqueta: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                ZStack {
                    Circle()
                        .fill(colorIcono.opacity(0.15))
                        .frame(width: 36, height: 36)
                    Image(systemName: icono)
                        .font(.system(size: 16))
                        .foregroundColor(colorIcono)
                }
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(valor)
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .foregroundColor(Color.bidealDarkGreen)
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

// Tarjeta de Aviso de Caducidad de Monedas (Idéntica a Android)
struct TarjetaCaducidadCoinsView: View {
    let cantidad: Int
    let diasRestantes: Int
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(red: 254/255, green: 226/255, blue: 226/255))
                    .frame(width: 40, height: 40)
                Image(systemName: "calendar.badge.exclamationmark")
                    .foregroundColor(Color(red: 220/255, green: 38/255, blue: 38/255))
                    .font(.system(size: 18))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("¡\(cantidad) KMC caducan en menos de \(diasRestantes) días!")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(red: 153/255, green: 27/255, blue: 27/255))
                Text("Úsalas en comercios asociados de Pamplona para no perderlas.")
                    .font(.system(size: 12))
                    .foregroundColor(Color(red: 185/255, green: 28/255, blue: 28/255))
            }
            
            Spacer()
        }
        .padding(14)
        .background(Color(red: 254/255, green: 242/255, blue: 242/255))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(red: 248/255, green: 113/255, blue: 113/255).opacity(0.3), lineWidth: 1)
        )
    }
}
