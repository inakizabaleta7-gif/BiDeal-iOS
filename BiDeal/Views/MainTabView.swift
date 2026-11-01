import SwiftUI

public struct MainTabView: View {
    @State private var tabSeleccionada: Int = 0
    @EnvironmentObject var homeVM: HomeViewModel
    @EnvironmentObject var estadisticasVM: EstadisticasViewModel
    
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
                    Label("Premios", systemImage: "gift.fill")
                }
                .tag(3)
            
            AjustesView()
                .tabItem {
                    Label("Ajustes", systemImage: "gearshape.fill")
                }
                .tag(4)
        }
        .tint(BiDealTheme.primary)
        .task {
            // Cargar datos en vivo al arrancar la app
            await homeVM.cargarDatosSupabase()
            await estadisticasVM.cargarGrupo(userId: homeVM.usuario.id)
        }
    }
}
