import SwiftUI

public struct MainTabView: View {
    @State private var tabSeleccionada: Int = 0
    @EnvironmentObject var homeVM: HomeViewModel
    @EnvironmentObject var estadisticasVM: EstadisticasViewModel
    @EnvironmentObject var comerciosVM: ComerciosViewModel
    @EnvironmentObject var authVM: AuthViewModel
    
    public init() {}
    
    public var body: some View {
        TabView(selection: $tabSeleccionada) {
            HomeView()
                .tabItem {
                    Label("Inicio", systemImage: "house.fill")
                }
                .tag(0)
            
            RecompensasView()
                .tabItem {
                    Label("Recompensas", systemImage: "gift.fill")
                }
                .tag(1)
            
            EstadisticasView()
                .tabItem {
                    Label("Estadísticas", systemImage: "chart.bar.fill")
                }
                .tag(2)
        }
        .tint(BiDealTheme.primary)
        .task {
            // Sincronizar y cargar datos en vivo de Supabase al arrancar la app
            if let user = authVM.currentUser {
                homeVM.actualizarConUsuario(user)
                await estadisticasVM.cargarGrupo(userId: user.id)
            } else {
                await homeVM.cargarDatosSupabase()
            }
            await comerciosVM.cargarComerciosYDescuentos()
            await authVM.cargarSaldoKmCoins()
        }
        .onChange(of: authVM.currentUser?.id) { _ in
            if let user = authVM.currentUser {
                homeVM.actualizarConUsuario(user)
                Task {
                    await estadisticasVM.cargarGrupo(userId: user.id)
                }
            }
        }
    }
}
