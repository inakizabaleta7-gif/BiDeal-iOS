import SwiftUI

public struct MainTabView: View {
    @State private var tabSeleccionada: Int = 0
    
    public init() {}
    
    public var body: some View {
        TabView(selection: $tabSeleccionada) {
            HomeView()
                .tabItem {
                    Label("Inicio", systemImage: "bicycle")
                }
                .tag(0)
            
            MapaComerciosView()
                .tabItem {
                    Label("Mapa", systemImage: "map.fill")
                }
                .tag(1)
            
            EstadisticasView()
                .tabItem {
                    Label("Estadísticas", systemImage: "chart.bar.fill")
                }
                .tag(2)
            
            RecompensasView()
                .tabItem {
                    Label("Recompensas", systemImage: "gift.fill")
                }
                .tag(3)
        }
        .tint(BiDealTheme.primary)
    }
}
