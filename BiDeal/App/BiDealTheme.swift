import SwiftUI
import UIKit

public struct BiDealTheme {
    // MARK: - Paleta Oficial BiDeal Pamplona (Paridad 1:1 con Android)
    
    // Verde Primario
    public static let primaryLight = Color(hex: "#16A34A") // Emerald 600
    public static let primaryDark = Color(hex: "#22C55E")  // Emerald 500 (más luminoso en modo noche)
    
    // Verde Bosque
    public static let forestLight = Color(hex: "#14532D")  // Forest 900
    public static let forestDark = Color(hex: "#4ADE80")   // Green 400
    
    // Lima / Acento
    public static let lime = Color(hex: "#86EFAC")
    public static let accentGold = Color(hex: "#D97706")   // Amber 600
    public static let goldLight = Color(hex: "#FEF3C7")    // Amber 100
    
    // Fondos Semánticos
    public static let bgLight = Color(hex: "#F8FAFC")      // Slate 50
    public static let bgDark = Color(hex: "#111215")       // OLED Deep Charcoal neutral
    
    // Superficies (Tarjetas)
    public static let surfaceLight = Color(hex: "#FFFFFF") // Blanco puro
    public static let surfaceDark = Color(hex: "#1C1E23")  // Tarjetas elevadas
    
    // Variantes de Superficie (Chips, Píldoras, Searchbars)
    public static let surfaceVarLight = Color(hex: "#F1F5F9") // Slate 100
    public static let surfaceVarDark = Color(hex: "#262930")  // Chips modo noche
    
    // Bordes / Outlines
    public static let outlineLight = Color(hex: "#E2E8F0") // Slate 200
    public static let outlineDark = Color(hex: "#2E3238")  // Zinc Outline
    
    // Textos
    public static let textPrimaryLight = Color(hex: "#0F172A") // Slate 900
    public static let textPrimaryDark = Color(hex: "#FFFFFF")  // Blanco puro
    
    public static let textSecondaryLight = Color(hex: "#64748B") // Slate 500
    public static let textSecondaryDark = Color(hex: "#A1A1AA")  // Zinc 400
    
    public static let textGreenLight = Color(hex: "#064E3B") // Verde oscuro corporativo
    
    // Atajos compatibles
    public static var primary: Color { bidealPrimary }
    public static var forest: Color { bidealForest }
    public static var backgroundLight: Color { bgLight }
    public static var backgroundDark: Color { bgDark }
}

// MARK: - Extensiones Dinámicas Adaptativas Claro / Oscuro
extension Color {
    public static var bidealPrimary: Color {
        Color(uiColor: UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(BiDealTheme.primaryDark) : UIColor(BiDealTheme.primaryLight)
        })
    }
    
    public static var bidealForest: Color {
        Color(uiColor: UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(BiDealTheme.forestDark) : UIColor(BiDealTheme.forestLight)
        })
    }
    
    public static var bidealBackground: Color {
        Color(uiColor: UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(BiDealTheme.bgDark) : UIColor(BiDealTheme.bgLight)
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
    
    public static var bidealOutline: Color {
        Color(uiColor: UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(BiDealTheme.outlineDark) : UIColor(BiDealTheme.outlineLight)
        })
    }
    
    public static var bidealBorder: Color { bidealOutline }
    
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
    
    public static var bidealLime: Color { BiDealTheme.lime }
    public static var bidealAccentGold: Color { BiDealTheme.accentGold }
    public static var bidealGoldLight: Color { BiDealTheme.goldLight }
    
    // Helper Hex
    public init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
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

// MARK: - Logo Reutilizable BiDeal
public struct BiDealLogoView: View {
    let size: CGFloat
    let cornerRadius: CGFloat
    
    public init(size: CGFloat = 40, cornerRadius: CGFloat = 8) {
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
