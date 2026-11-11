import SwiftUI
import UIKit

public struct BiDealTheme {
    // MARK: - Colores Oficiales BiDeal Pamplona (Paridad 1:1 con Android Compose)
    
    // Verde BiDeal
    public static let primary = Color(red: 0.086, green: 0.639, blue: 0.290) // #16A34A (Emerald 600)
    public static let primaryDark = Color(red: 0.133, green: 0.773, blue: 0.369) // #22C55E (Emerald 500 para OLED)
    public static let primaryLight = Color(red: 0.863, green: 0.988, blue: 0.906) // #DCFCE7 (Pastel para chips)
    
    // Verde Bosque
    public static let forest = Color(red: 0.078, green: 0.325, blue: 0.176) // #14532D (Forest 900)
    public static let forestLight = Color(red: 0.078, green: 0.325, blue: 0.176)
    public static let forestDark = Color(red: 0.290, green: 0.871, blue: 0.502) // #4ADE80 (Green 400)
    
    // Lima y Acentos Oro
    public static let lime = Color(red: 0.525, green: 0.937, blue: 0.675) // #86EFAC
    public static let accentGold = Color(red: 0.851, green: 0.467, blue: 0.024) // #D97706
    public static let goldLight = Color(red: 0.996, green: 0.953, blue: 0.780) // #FEF3C7
    
    // Fondos Semánticos
    public static let backgroundLight = Color(red: 0.973, green: 0.980, blue: 0.988) // #F8FAFC (Slate 50)
    public static let backgroundDark = Color(red: 0.067, green: 0.071, blue: 0.082) // #111215 (OLED Deep Charcoal)
    
    // Superficies (Tarjetas)
    public static let surfaceLight = Color.white
    public static let surfaceDark = Color(red: 0.110, green: 0.118, blue: 0.137) // #1C1E23 (Tarjetas elevadas)
    
    // Variantes de Superficie (Chips y Píldoras)
    public static let surfaceVarLight = Color(red: 0.945, green: 0.961, blue: 0.976) // #F1F5F9 (Slate 100)
    public static let surfaceVarDark = Color(red: 0.149, green: 0.161, blue: 0.188) // #262930 (Zinc chips)
    
    // Bordes / Delimitadores
    public static let borderLight = Color(red: 0.886, green: 0.910, blue: 0.941) // #E2E8F0 (Slate 200)
    public static let borderDark = Color(red: 0.180, green: 0.196, blue: 0.220) // #2E3238 (Dark outline)
    
    // Textos
    public static let textDark = Color(red: 0.059, green: 0.090, blue: 0.165) // #0F172A
    public static let textSubtle = Color(red: 0.392, green: 0.455, blue: 0.545) // #64748B
    public static let textPrimaryLight = Color(red: 0.059, green: 0.090, blue: 0.165)
    public static let textPrimaryDark = Color.white
    public static let textSecondaryLight = Color(red: 0.392, green: 0.455, blue: 0.545)
    public static let textSecondaryDark = Color(red: 0.631, green: 0.631, blue: 0.667) // #A1A1AA
}

// MARK: - Extensiones de Color Dinámicas
extension Color {
    public static var bidealPrimary: Color {
        Color(uiColor: UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(BiDealTheme.primaryDark) : UIColor(BiDealTheme.primary)
        })
    }
    
    public static var bidealDarkGreen: Color {
        Color(uiColor: UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(BiDealTheme.forestDark) : UIColor(BiDealTheme.forest)
        })
    }
    
    public static var bidealLightGreen: Color { BiDealTheme.primaryLight }
    
    public static var bidealForest: Color {
        Color(uiColor: UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(BiDealTheme.forestDark) : UIColor(BiDealTheme.forestLight)
        })
    }
    
    public static var bidealLime: Color { BiDealTheme.lime }
    public static var bidealAccentGold: Color { BiDealTheme.accentGold }
    public static var bidealGoldLight: Color { BiDealTheme.goldLight }
    
    public static var bidealBackground: Color {
        Color(uiColor: UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(BiDealTheme.backgroundDark) : UIColor(BiDealTheme.backgroundLight)
        })
    }
    
    public static var bidealSurface: Color {
        Color(uiColor: UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(BiDealTheme.surfaceDark) : UIColor(BiDealTheme.surfaceLight)
        })
    }
    
    public static var bidealSurfaceVariant: Color {
        Color(uiColor: UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(BiDealTheme.surfaceVarDark) : UIColor(BiDealTheme.surfaceVarLight)
        })
    }
    
    public static var bidealBorder: Color {
        Color(uiColor: UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(BiDealTheme.borderDark) : UIColor(BiDealTheme.borderLight)
        })
    }
    
    public static var bidealOutline: Color { bidealBorder }
    
    public static var bidealTextPrimary: Color {
        Color(uiColor: UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(BiDealTheme.textPrimaryDark) : UIColor(BiDealTheme.textPrimaryLight)
        })
    }
    
    public static var bidealTextSecondary: Color {
        Color(uiColor: UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(BiDealTheme.textSecondaryDark) : UIColor(BiDealTheme.textSecondaryLight)
        })
    }
    
    public init(hex: String) {
        let cleanHex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: cleanHex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch cleanHex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Logo Oficial BiDeal
public struct BiDealLogoView: View {
    let size: CGFloat
    let cornerRadius: CGFloat
    
    public init(size: CGFloat = 42, cornerRadius: CGFloat = 8) {
        self.size = size
        self.cornerRadius = cornerRadius
    }
    
    public var body: some View {
        if let uiImg = UIImage(named: "logo_bideal") ?? UIImage(contentsOfFile: Bundle.main.path(forResource: "logo_bideal", ofType: "jpeg") ?? "") {
            Image(uiImage: uiImg)
                .resizable()
                .scaledToFill()
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        } else {
            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.bidealPrimary)
                    .frame(width: size, height: size)
                Image(systemName: "bicycle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: size * 0.6, height: size * 0.6)
                    .foregroundColor(.white)
            }
        }
    }
}
