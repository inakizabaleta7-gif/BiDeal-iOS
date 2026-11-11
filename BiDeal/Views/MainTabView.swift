import SwiftUI

public struct MainTabView: View {
    @State private var tabSeleccionada: Int = 0
    @EnvironmentObject var homeVM: HomeViewModel
    @EnvironmentObject var estadisticasVM: EstadisticasViewModel
    @EnvironmentObject var comerciosVM: ComerciosViewModel
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var locationManager: LocationManager
    
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
            
            QRScannerView()
                .tabItem {
                    Label("Escanear QR", systemImage: "qrcode.viewfinder")
                }
                .tag(2)
            
            EstadisticasView()
                .tabItem {
                    Label("Estadísticas", systemImage: "chart.bar.fill")
                }
                .tag(3)
        }
        .tint(Color.bidealPrimary)
        .task {
            // Sincronizar datos al arrancar
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
