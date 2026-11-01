import SwiftUI

@main
struct BiDealApp: App {
    @StateObject private var authVM = AuthViewModel()
    @StateObject private var locationManager = LocationManager.shared
    @StateObject private var homeVM = HomeViewModel()
    @StateObject private var estadisticasVM = EstadisticasViewModel()
    @StateObject private var comerciosVM = ComerciosViewModel()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authVM.isLoggedIn {
                    MainTabView()
                } else {
                    LoginView()
                }
            }
            .environmentObject(authVM)
            .environmentObject(locationManager)
            .environmentObject(homeVM)
            .environmentObject(estadisticasVM)
            .environmentObject(comerciosVM)
            .tint(BiDealTheme.primary)
            .onOpenURL { url in
                procesarDeepLink(url)
            }
        }
    }
    
    private func procesarDeepLink(_ url: URL) {
        print("🔗 Deep Link recibido en iOS: \(url.absoluteString)")
        
        let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        let host = url.host ?? ""
        let path = url.path
        
        let esGrupo = host == "grupo" || host == "liga" || path.contains("/grupo") || path.contains("/liga")
        
        if esGrupo {
            let codigoQuery = components?.queryItems?.first(where: { $0.name == "codigo" || $0.name == "code" })?.value
            let codigoPath = url.lastPathComponent != "grupo" && url.lastPathComponent != "liga" ? url.lastPathComponent : nil
            
            if let codigoLimpio = (codigoQuery ?? codigoPath)?.trimmingCharacters(in: .whitespacesAndNewlines).uppercased(),
               !codigoLimpio.isEmpty {
                Task {
                    let userId = authVM.currentUser?.id ?? homeVM.usuario.id
                    let _ = await estadisticasVM.unirseAGrupo(userId: userId, codigo: codigoLimpio)
                }
            }
        }
    }
}
