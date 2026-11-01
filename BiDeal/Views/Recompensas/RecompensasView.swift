import SwiftUI
import MapKit

public struct RecompensasView: View {
    @EnvironmentObject var comerciosVM: ComerciosViewModel
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var homeVM: HomeViewModel
    
    @State private var searchQuery: String = ""
    @State private var selectedCategory: String = "Todos"
    @State private var isMapView: Bool = false
    @State private var recompensaSeleccionada: RecompensaUiModel? = nil
    @State private var mostrarDetalle: Bool = false
    @State private var mostrarScanner: Bool = false
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 42.8168, longitude: -1.6432),
        span: MKCoordinateSpan(latitudeDelta: 0.035, longitudeDelta: 0.035)
    )
    
    let categorias = ["Todos", "Restauración", "Deportes", "Cultura", "Moda"]
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color.bidealBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // TopAppBar Oficial Idéntica a Android
                    HStack {
                        Text("Recompensas")
                            .font(.system(size: 26, weight: .heavy, design: .rounded))
                            .foregroundColor(BiDealTheme.primary)
                        
                        Spacer()
                        
                        // Chip KmCoins (KMC)
                        HStack(spacing: 5) {
                            ZStack {
                                Circle()
                                    .fill(Color(red: 251/255, green: 191/255, blue: 36/255))
                                    .frame(width: 20, height: 20)
                                Text("KM")
                                    .font(.system(size: 8, weight: .heavy))
                                    .foregroundColor(Color(red: 146/255, green: 64/255, blue: 14/255))
                            }
                            Text("\(authVM.kmcoinsBalance)")
                                .font(.system(size: 15, weight: .heavy))
                                .foregroundColor(Color(red: 146/255, green: 64/255, blue: 14/255))
                            Text("KMC")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(Color(red: 146/255, green: 64/255, blue: 14/255))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(red: 254/255, green: 243/255, blue: 199/255))
                        .cornerRadius(16)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 12)
                    .background(Color.bidealBackground)
                    
                    if isMapView {
                        // ==========================================
                        // MODO MAPA INTERACTIVO PANTALLA COMPLETA
                        // ==========================================
                        ZStack(alignment: .top) {
                            Map(coordinateRegion: $region, annotationItems: recompensasFiltradas) { r in
                                MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: r.latitud ?? 42.8168, longitude: r.longitud ?? -1.6432)) {
                                    Button(action: {
                                        withAnimation(.spring()) {
                                            recompensaSeleccionada = r
                                        }
                                    }) {
                                        VStack(spacing: 0) {
                                            ZStack {
                                                Circle()
                                                    .fill(recompensaSeleccionada?.id == r.id ? Color(red: 234/255, green: 88/255, blue: 12/255) : BiDealTheme.primary)
                                                    .frame(width: 36, height: 36)
                                                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                                                Image(systemName: "storefront.fill")
                                                    .font(.system(size: 16))
                                                    .foregroundColor(.white)
                                            }
                                            
                                            // Flecha del pin
                                            Image(systemName: "triangle.fill")
                                                .font(.system(size: 8))
                                                .foregroundColor(recompensaSeleccionada?.id == r.id ? Color(red: 234/255, green: 88/255, blue: 12/255) : BiDealTheme.primary)
                                                .rotationEffect(.degrees(180))
                                                .offset(y: -2)
                                        }
                                    }
                                }
                            }
                            .ignoresSafeArea(edges: .bottom)
                            
                            // Controles flotantes superiores
                            VStack(spacing: 10) {
                                HStack {
                                    // Contador de locales
                                    Text("📍 \(recompensasFiltradas.count) locales")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(Color.bidealDarkGreen)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(Color.white.opacity(0.95))
                                        .cornerRadius(12)
                                        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                                    
                                    Spacer()
                                    
                                    // Botón para volver a Lista
                                    Button(action: { isMapView = false }) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "list.bullet")
                                                .font(.system(size: 12, weight: .bold))
                                            Text("Ver Lista")
                                                .font(.system(size: 12, weight: .bold))
                                        }
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(BiDealTheme.primary)
                                        .cornerRadius(12)
                                        .shadow(color: BiDealTheme.primary.opacity(0.3), radius: 4, x: 0, y: 2)
                                    }
                                }
                                
                                // Chips de categorías horizontales sobre el mapa
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(categorias, id: \.self) { cat in
                                            let isSelected = selectedCategory == cat
                                            Button(action: { selectedCategory = cat }) {
                                                Text(cat)
                                                    .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                                                    .foregroundColor(isSelected ? .white : Color.bidealDarkGreen)
                                                    .padding(.horizontal, 14)
                                                    .padding(.vertical, 7)
                                                    .background(isSelected ? BiDealTheme.primary : Color.white.opacity(0.95))
                                                    .cornerRadius(20)
                                                    .shadow(color: Color.black.opacity(0.06), radius: 3, x: 0, y: 1)
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 2)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 10)
                            
                            // Drawer inferior flotante si hay pin seleccionado
                            if let sel = recompensaSeleccionada {
                                VStack {
                                    Spacer()
                                    HStack(spacing: 12) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(BiDealTheme.primaryLight)
                                                .frame(width: 48, height: 48)
                                            Image(systemName: "storefront.fill")
                                                .font(.system(size: 20))
                                                .foregroundColor(BiDealTheme.primary)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(sel.comercioNombre)
                                                .font(.system(size: 15, weight: .bold))
                                                .foregroundColor(Color.bidealDarkGreen)
                                            Text(sel.titulo)
                                                .font(.system(size: 13))
                                                .foregroundColor(.secondary)
                                                .lineLimit(1)
                                        }
                                        
                                        Spacer()
                                        
                                        Button(action: {
                                            mostrarDetalle = true
                                        }) {
                                            HStack(spacing: 4) {
                                                Text("Ver")
                                                    .font(.system(size: 12, weight: .bold))
                                                Text("\(sel.precio) KMC")
                                                    .font(.system(size: 11, weight: .heavy))
                                            }
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(BiDealTheme.primary)
                                            .cornerRadius(10)
                                        }
                                    }
                                    .padding(14)
                                    .background(Color.white)
                                    .cornerRadius(16)
                                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 4)
                                    .padding(.horizontal, 16)
                                    .padding(.bottom, 20)
                                }
                            }
                        }
                    } else {
                        // ==========================================
                        // MODO LISTA IDÉNTICO A ANDROID
                        // ==========================================
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                // Cabecera "Escaparate Local" + Botón Mapa
                                HStack(alignment: .top) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Escaparate Local")
                                            .font(.system(size: 22, weight: .bold))
                                            .foregroundColor(Color.bidealDarkGreen)
                                        Text("Descubre los comercios de Pamplona unidos a BiDeal.")
                                            .font(.system(size: 13))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    // Botón Mapa
                                    Button(action: { isMapView = true }) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "map.fill")
                                                .font(.system(size: 13, weight: .bold))
                                            Text("Mapa")
                                                .font(.system(size: 13, weight: .bold))
                                        }
                                        .foregroundColor(Color.bidealDarkGreen)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 7)
                                        .background(BiDealTheme.primaryLight)
                                        .cornerRadius(12)
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.top, 4)
                                
                                // Buscador de comercios
                                HStack(spacing: 10) {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundColor(BiDealTheme.primary)
                                        .font(.system(size: 16))
                                    
                                    TextField("Buscar comercios o descuentos...", text: $searchQuery)
                                        .font(.system(size: 14))
                                    
                                    if !searchQuery.isEmpty {
                                        Button(action: { searchQuery = "" }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                                .background(Color.white)
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.bidealBorder, lineWidth: 1)
                                )
                                .padding(.horizontal, 20)
                                
                                // Botón Escanear QR
                                Button(action: { mostrarScanner = true }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "qrcode.viewfinder")
                                            .font(.system(size: 18, weight: .bold))
                                        Text("Escanear código QR")
                                            .font(.system(size: 15, weight: .bold))
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 13)
                                    .background(BiDealTheme.primary)
                                    .cornerRadius(16)
                                    .shadow(color: BiDealTheme.primary.opacity(0.25), radius: 4, x: 0, y: 2)
                                }
                                .padding(.horizontal, 20)
                                
                                // Chips de Categorías
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(categorias, id: \.self) { cat in
                                            let isSelected = selectedCategory == cat
                                            Button(action: { selectedCategory = cat }) {
                                                Text(cat)
                                                    .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                                                    .foregroundColor(isSelected ? .white : Color.bidealDarkGreen)
                                                    .padding(.horizontal, 14)
                                                    .padding(.vertical, 7)
                                                    .background(isSelected ? BiDealTheme.primary : Color.white)
                                                    .cornerRadius(18)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 18)
                                                            .stroke(isSelected ? BiDealTheme.primary : Color.bidealBorder, lineWidth: 1)
                                                    )
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                }
                                
                                // Contador de resultados
                                HStack {
                                    Text(selectedCategory == "Todos" ? "Todas las promociones" : "Categoría: \(selectedCategory)")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(Color.bidealDarkGreen)
                                    Spacer()
                                    Text("\(recompensasFiltradas.count) \(recompensasFiltradas.count == 1 ? "resultado" : "resultados")")
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 20)
                                .padding(.top, 4)
                                
                                // Listado de Tarjetas Grandes de Recompensa
                                if recompensasFiltradas.isEmpty {
                                    VStack(spacing: 12) {
                                        ZStack {
                                            Circle()
                                                .fill(BiDealTheme.primaryLight)
                                                .frame(width: 64, height: 64)
                                            Image(systemName: "magnifyingglass")
                                                .font(.system(size: 28))
                                                .foregroundColor(BiDealTheme.primary)
                                        }
                                        Text("Sin resultados disponibles")
                                            .font(.system(size: 17, weight: .bold))
                                            .foregroundColor(Color.bidealDarkGreen)
                                        Text("No encontramos promociones para \"\(searchQuery)\" en la categoría \"\(selectedCategory)\".")
                                            .font(.system(size: 13))
                                            .foregroundColor(.secondary)
                                            .multilineTextAlignment(.center)
                                        
                                        Button(action: {
                                            searchQuery = ""
                                            selectedCategory = "Todos"
                                        }) {
                                            Text("Restablecer Filtros")
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 9)
                                                .background(BiDealTheme.primary)
                                                .cornerRadius(12)
                                        }
                                        .padding(.top, 4)
                                    }
                                    .padding(32)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.white)
                                    .cornerRadius(20)
                                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.bidealBorder, lineWidth: 1))
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 16)
                                } else {
                                    ForEach(recompensasFiltradas) { recompensa in
                                        TarjetaRecompensaGrandeView(recompensa: recompensa) {
                                            recompensaSeleccionada = recompensa
                                            mostrarDetalle = true
                                        }
                                        .padding(.horizontal, 20)
                                    }
                                }
                                
                                Spacer().frame(height: 30)
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
            }
            .sheet(isPresented: $mostrarDetalle) {
                if let r = recompensaSeleccionada {
                    DetalleComercioView(recompensa: r)
                }
            }
            .sheet(isPresented: $mostrarScanner) {
                ScannerQRView()
            }
            .task {
                await comerciosVM.cargarComerciosYDescuentos()
                await authVM.cargarSaldoKmCoins()
            }
        }
    }
    
    private var recompensasFiltradas: [RecompensaUiModel] {
        comerciosVM.recompensas.filter { r in
            let q = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            let coincideBusqueda = q.isEmpty ||
                r.comercioNombre.lowercased().contains(q) ||
                r.titulo.lowercased().contains(q) ||
                r.descripcion.lowercased().contains(q) ||
                r.direccion.lowercased().contains(q)
            
            let coincideCategoria = selectedCategory == "Todos" ||
                r.categoria.lowercased() == selectedCategory.lowercased()
            
            return coincideBusqueda && coincideCategoria
        }
    }
}

// ==========================================
// TARJETA DE RECOMPENSA GRANDE (IDÉNTICA A ANDROID)
// ==========================================
struct TarjetaRecompensaGrandeView: View {
    let recompensa: RecompensaUiModel
    let onClick: () -> Void
    
    var body: some View {
        Button(action: onClick) {
            VStack(alignment: .leading, spacing: 0) {
                // Imagen con badges superpuestos
                ZStack(alignment: .topLeading) {
                    if let urlStr = recompensa.imagenUrl, let url = URL(string: urlStr) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                placeholderFondo
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                            case .failure:
                                placeholderFondo
                            @unknown default:
                                placeholderFondo
                            }
                        }
                        .frame(height: 175)
                        .clipped()
                    } else {
                        placeholderFondo
                            .frame(height: 175)
                    }
                    
                    // Chip Categoría arriba a la izquierda
                    Text(recompensa.categoria)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.65))
                        .cornerRadius(8)
                        .padding(14)
                    
                    // Chip KMC arriba a la derecha
                    HStack {
                        Spacer()
                        HStack(spacing: 4) {
                            ZStack {
                                Circle()
                                    .fill(Color(red: 251/255, green: 191/255, blue: 36/255))
                                    .frame(width: 16, height: 16)
                                Text("KM")
                                    .font(.system(size: 7, weight: .heavy))
                                    .foregroundColor(Color(red: 146/255, green: 64/255, blue: 14/255))
                            }
                            Text("\(recompensa.precio)")
                                .font(.system(size: 13, weight: .heavy))
                                .foregroundColor(Color(red: 146/255, green: 64/255, blue: 14/255))
                            Text("KMC")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(Color(red: 146/255, green: 64/255, blue: 14/255))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(red: 254/255, green: 243/255, blue: 199/255))
                        .cornerRadius(12)
                        .padding(14)
                    }
                }
                
                // Contenido textual inferior
                VStack(alignment: .leading, spacing: 8) {
                    Text(recompensa.titulo)
                        .font(.system(size: 19, weight: .heavy, design: .rounded))
                        .foregroundColor(BiDealTheme.primary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                    
                    HStack(spacing: 6) {
                        Image(systemName: "storefront.fill")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                        Text(recompensa.comercioNombre)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color.bidealDarkGreen)
                    }
                    
                    HStack(spacing: 6) {
                        Image(systemName: "mappin.and.ellipse")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        Text(recompensa.direccion)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    Text(recompensa.descripcion)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .padding(.top, 2)
                    
                    Divider()
                        .padding(.vertical, 4)
                    
                    HStack {
                        Text("Ver recompensa")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(BiDealTheme.primary)
                        Spacer()
                        Image(systemName: "arrow.right")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(BiDealTheme.primary)
                    }
                }
                .padding(18)
                .background(Color.white)
            }
            .background(Color.white)
            .cornerRadius(22)
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(Color.bidealBorder, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var placeholderFondo: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [BiDealTheme.primary.opacity(0.6), Color.bidealDarkGreen.opacity(0.85)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Image(systemName: "storefront.fill")
                .font(.system(size: 54))
                .foregroundColor(.white.opacity(0.35))
        }
    }
}

// ==========================================
// SCANNER QR NATIVO MODAL
// ==========================================
struct ScannerQRView: View {
    @Environment(\.dismiss) var dismiss
    @State private var codigoManual: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black.opacity(0.9))
                        .frame(height: 300)
                        .overlay(
                            VStack(spacing: 16) {
                                Image(systemName: "qrcode.viewfinder")
                                    .font(.system(size: 80))
                                    .foregroundColor(BiDealTheme.primary)
                                Text("Apunta al código QR del comercio de Pamplona")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.8))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 30)
                            }
                        )
                }
                .padding(20)
                
                VStack(spacing: 12) {
                    Text("¿Problemas con la cámara?")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.secondary)
                    
                    HStack {
                        TextField("Código de comercio (ej. BD-1001)", text: $codigoManual)
                            .font(.system(size: 14))
                            .textInputAutocapitalization(.characters)
                            .padding(12)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.bidealBorder, lineWidth: 1))
                        
                        Button("Validar") {
                            dismiss()
                        }
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(BiDealTheme.primary)
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .navigationTitle("Escanear QR")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") { dismiss() }
                }
            }
        }
    }
}
