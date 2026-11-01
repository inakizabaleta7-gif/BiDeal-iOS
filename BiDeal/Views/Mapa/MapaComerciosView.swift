import SwiftUI
import MapKit

public struct MapaComerciosView: View {
    @EnvironmentObject var comerciosVM: ComerciosViewModel
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 42.8168, longitude: -1.6432),
        span: MKCoordinateSpan(latitudeDelta: 0.035, longitudeDelta: 0.035)
    )
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // Mapa Nativo de Apple
                Map(coordinateRegion: $region, annotationItems: comerciosVM.comerciosFiltrados) { comercio in
                    MapAnnotation(coordinate: comercio.coordinate ?? CLLocationCoordinate2D(latitude: 42.8168, longitude: -1.6432)) {
                        BotonPinComercio(comercio: comercio, esSeleccionado: comerciosVM.comercioSeleccionado?.id == comercio.id) {
                            withAnimation(.spring()) {
                                comerciosVM.comercioSeleccionado = comercio
                            }
                        }
                    }
                }
                .edgesIgnoringSafeArea(.all)
                
                // Capas superpuestas: Buscador y Filtros (arriba), Tarjeta de detalle (abajo)
                VStack(spacing: 8) {
                    // Barra de Búsqueda y Filtros de Categorías
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.secondary)
                            TextField("Buscar comercio o barrio (ej. Iturrama)...", text: $comerciosVM.textoBusqueda)
                                .textFieldStyle(PlainTextFieldStyle())
                            if !comerciosVM.textoBusqueda.isEmpty {
                                Button(action: { comerciosVM.textoBusqueda = "" }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(10)
                        .background(Color.bidealSurface)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 2)
                        .padding(.horizontal)
                        
                        // Carrusel de Filtros de Categoría
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                FiltroChip(titulo: "Todos (\(comerciosVM.comercios.count))", clave: "all", seleccionada: $comerciosVM.categoriaSeleccionada)
                                FiltroChip(titulo: "🚲 Deportes y Bicis", clave: "deportes", seleccionada: $comerciosVM.categoriaSeleccionada)
                                FiltroChip(titulo: "☕ Cafeterías y Bares", clave: "restauracion", seleccionada: $comerciosVM.categoriaSeleccionada)
                                FiltroChip(titulo: "📚 Cultura y Libros", clave: "cultura", seleccionada: $comerciosVM.categoriaSeleccionada)
                                FiltroChip(titulo: "🌿 Salud y Bienestar", clave: "salud", seleccionada: $comerciosVM.categoriaSeleccionada)
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top, 10)
                    
                    Spacer()
                    
                    // Tarjeta Flotante de Detalle de Comercio Seleccionado
                    if let comercio = comerciosVM.comercioSeleccionado {
                        TarjetaDetalleComercio(comercio: comercio) {
                            withAnimation {
                                comerciosVM.comercioSeleccionado = nil
                            }
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Comercios en Pamplona")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct BotonPinComercio: View {
    let comercio: Comercio
    let esSeleccionado: Bool
    let accion: () -> Void
    
    var body: some View {
        Button(action: accion) {
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(esSeleccionado ? BiDealTheme.primaryDark : BiDealTheme.primary)
                        .frame(width: esSeleccionado ? 44 : 36, height: esSeleccionado ? 44 : 36)
                        .shadow(radius: 4)
                    Text(comercio.emojiCategoria)
                        .font(.system(size: esSeleccionado ? 20 : 16))
                }
                Image(systemName: "triangle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(esSeleccionado ? BiDealTheme.primaryDark : BiDealTheme.primary)
                    .frame(width: 10, height: 8)
                    .rotationEffect(.degrees(180))
                    .offset(y: -2)
            }
        }
    }
}

struct FiltroChip: View {
    let titulo: String
    let clave: String
    @Binding var seleccionada: String
    
    var body: some View {
        Button(action: { seleccionada = clave }) {
            Text(titulo)
                .font(.caption)
                .fontWeight(seleccionada == clave ? .bold : .medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(seleccionada == clave ? BiDealTheme.primary : Color.bidealSurface)
                .foregroundColor(seleccionada == clave ? .white : .primary)
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
        }
    }
}

struct TarjetaDetalleComercio: View {
    let comercio: Comercio
    let onCerrar: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                ZStack {
                    Circle()
                        .fill(BiDealTheme.primaryLight)
                        .frame(width: 44, height: 44)
                    Text(comercio.emojiCategoria)
                        .font(.title3)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(comercio.categoria ?? "Comercio Local")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(BiDealTheme.primary)
                    Text(comercio.nombre)
                        .font(.headline)
                        .fontWeight(.bold)
                    if let dir = comercio.direccion {
                        Text("📍 \(dir)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Button(action: onCerrar) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
            }
            
            // Ofertas canjeables con KmCoins
            if let descuentos = comercio.descuentos, !descuentos.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("OFERTAS DISPONIBLES CON KMCOINS:")
                        .font(.caption2)
                        .fontWeight(.heavy)
                        .foregroundColor(BiDealTheme.accentGold)
                    
                    ForEach(descuentos) { d in
                        HStack {
                            Text("🎁 \(d.titulo)")
                                .font(.caption)
                                .fontWeight(.semibold)
                            Spacer()
                            Text("\(d.precio_kmcoins) KMC")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(BiDealTheme.primary)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding(10)
                .background(Color.bidealBackground)
                .cornerRadius(10)
            }
            
            // Botón Cómo llegar en Bici (Abre Apple Maps)
            if let lat = comercio.latitud, let lon = comercio.longitud {
                Button(action: {
                    let urlStr = "http://maps.apple.com/?daddr=\(lat),\(lon)&dirflg=b"
                    if let url = URL(string: urlStr) {
                        UIApplication.shared.open(url)
                    }
                }) {
                    HStack {
                        Image(systemName: "bicycle")
                        Text("Cómo llegar en bici")
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(BiDealTheme.primary)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            }
        }
        .padding(18)
        .background(Color.bidealSurface)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 4)
    }
}
