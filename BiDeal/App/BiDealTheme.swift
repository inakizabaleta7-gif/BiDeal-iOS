import SwiftUI

public struct BiDealTheme {
    // Colores Oficiales de BiDeal Pamplona
    public static let primary = Color(red: 0.086, green: 0.639, blue: 0.290) // #16A34A (Verde BiDeal)
    public static let primaryDark = Color(red: 0.082, green: 0.502, blue: 0.239) // #15803D
    public static let primaryLight = Color(red: 0.863, green: 0.988, blue: 0.906) // #DCFCE7
    
    public static let accentGold = Color(red: 0.851, green: 0.467, blue: 0.024) // #D97706
    public static let goldLight = Color(red: 0.996, green: 0.953, blue: 0.780) // #FEF3C7
    
    public static let backgroundLight = Color(red: 0.973, green: 0.980, blue: 0.988) // #F8FAFC
    public static let backgroundDark = Color(red: 0.059, green: 0.090, blue: 0.165) // #0F172A
    
    public static let surfaceLight = Color.white
    public static let surfaceDark = Color(red: 0.118, green: 0.161, blue: 0.231) // #1E293B
    
    public static let borderLight = Color(red: 0.886, green: 0.910, blue: 0.941) // #E2E8F0
    public static let borderDark = Color(red: 0.200, green: 0.255, blue: 0.333) // #334155
    
    public static let textDark = Color(red: 0.059, green: 0.090, blue: 0.165)
    public static let textSubtle = Color(red: 0.392, green: 0.455, blue: 0.545)
}

extension Color {
    static var bidealPrimary: Color { BiDealTheme.primary }
    static var bidealDarkGreen: Color { BiDealTheme.primaryDark }
    static var bidealLightGreen: Color { BiDealTheme.primaryLight }
    
    static var bidealBackground: Color {
        Color(uiColor: UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(BiDealTheme.backgroundDark) : UIColor(BiDealTheme.backgroundLight)
        })
    }
    
    static var bidealSurface: Color {
        Color(uiColor: UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(BiDealTheme.surfaceDark) : UIColor(BiDealTheme.surfaceLight)
        })
    }
    
    static var bidealBorder: Color {
        Color(uiColor: UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(BiDealTheme.borderDark) : UIColor(BiDealTheme.borderLight)
        })
    }
}
