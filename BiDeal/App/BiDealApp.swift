import SwiftUI

@main
struct BiDealApp: App {
    @StateObject private var locationManager = LocationManager.shared
    @StateObject private var homeVM = HomeViewModel()
    @StateObject private var estadisticasVM = EstadisticasViewModel()
    @StateObject private var comerciosVM = ComerciosViewModel()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(locationManager)
                .environmentObject(homeVM)
                .environmentObject(estadisticasVM)
                .environmentObject(comerciosVM)
                .tint(BiDealTheme.primary)
        }
    }
}
