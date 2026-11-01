import SwiftUI
import MapKit

public struct MapaComerciosView: View {
    @EnvironmentObject var comerciosVM: ComerciosViewModel
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 42.8168, longitude: -1.6432),
        span: MKCoordinateSpan(latitudeDelta: 0.035, longitudeDelta: 0.035)
    )
    @State private var seleccionado: RecompensaUiModel? = nil
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Map(coordinateRegion: $region, annotationItems: comerciosVM.recompensas) { r in
                    MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: r.latitud ?? 42.8168, longitude: r.longitud ?? -1.6432)) {
                        Button(action: {
                            withAnimation(.spring()) {
                                seleccionado = r
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(seleccionado?.id == r.id ? Color(red: 234/255, green: 88/255, blue: 12/255) : BiDealTheme.primary)
                                    .frame(width: 36, height: 36)
                                Image(systemName: "storefront.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                .edgesIgnoringSafeArea(.all)
                
                if let sel = seleccionado {
                    VStack {
                        Spacer()
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(sel.comercioNombre)
                                    .font(.system(size: 15, weight: .bold))
                                Text(sel.titulo)
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text("\(sel.precio) KMC")
                                .font(.system(size: 12, weight: .heavy))
                                .foregroundColor(BiDealTheme.primary)
                        }
                        .padding(14)
                        .background(Color.white)
                        .cornerRadius(14)
                        .shadow(radius: 6)
                        .padding(16)
                    }
                }
            }
            .navigationTitle("Mapa")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
