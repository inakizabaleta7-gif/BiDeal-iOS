import Foundation

public struct CO2Calculator {
    // Parámetros de movilidad urbana sostenible en Pamplona
    public static let co2PorKmCocheKg: Double = 0.130 // 130g CO2/km medio en trayecto urbano
    public static let consumoLitrosPor100Km: Double = 7.5
    public static let precioLitroGasolinaEuros: Double = 1.65
    public static let absorcionDiariaArbolKg: Double = 0.055 // ~20 kg CO2 / año
    
    public static func calcularCo2EvitadoKg(distanciaKm: Double) -> Double {
        return distanciaKm * co2PorKmCocheKg
    }
    
    public static func calcularDiasArbol(co2Kg: Double) -> Double {
        return co2Kg / absorcionDiariaArbolKg
    }
    
    public static func calcularLitrosGasolinaAhorrados(distanciaKm: Double) -> Double {
        return (distanciaKm * consumoLitrosPor100Km) / 100.0
    }
    
    public static func calcularEurosAhorrados(distanciaKm: Double) -> Double {
        return calcularLitrosGasolinaAhorrados(distanciaKm: distanciaKm) * precioLitroGasolinaEuros
    }
    
    public static func formatearCo2(co2Kg: Double) -> String {
        if co2Kg < 1.0 {
            let gramos = Int(co2Kg * 1000)
            return "\(gramos) g"
        } else {
            return String(format: "%.2f kg", co2Kg)
        }
    }
}
