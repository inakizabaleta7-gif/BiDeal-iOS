import SwiftUI

public struct HitoModel: Identifiable {
    public let id: String
    public let kmObjetivo: Double
    public let titulo: String
    public let bicoinsRecompensa: Int
    public let tipoMedalla: TipoMedalla
    
    public enum TipoMedalla {
        case ninguna, plata, oro, platino
    }
}

public struct HitosView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var homeVM: HomeViewModel
    
    @State private var tabSeleccionado: Int = 0 // 0: Diarias, 1: Semanales
    
    let hitosDiarios = [
        HitoModel(id: "diaria_2km", kmObjetivo: 2.0, titulo: "Paseo (2 km)", bicoinsRecompensa: 5, tipoMedalla: .ninguna),
        HitoModel(id: "diaria_5km", kmObjetivo: 5.0, titulo: "Urbano (5 km)", bicoinsRecompensa: 5, tipoMedalla: .ninguna),
        HitoModel(id: "diaria_7_5km", kmObjetivo: 7.5, titulo: "Activo (7.5 km)", bicoinsRecompensa: 10, tipoMedalla: .ninguna),
        HitoModel(id: "diaria_10km", kmObjetivo: 10.0, titulo: "Ruta (10 km)", bicoinsRecompensa: 15, tipoMedalla: .ninguna),
        HitoModel(id: "diaria_15km", kmObjetivo: 15.0, titulo: "Pro (15 km)", bicoinsRecompensa: 10, tipoMedalla: .ninguna)
    ]
    
    let hitosSemanales = [
        HitoModel(id: "semanal_20km", kmObjetivo: 20.0, titulo: "Medalla de Plata (20 km)", bicoinsRecompensa: 75, tipoMedalla: .plata),
        HitoModel(id: "semanal_50km", kmObjetivo: 50.0, titulo: "Medalla de Oro (50 km)", bicoinsRecompensa: 100, tipoMedalla: .oro),
        HitoModel(id: "semanal_100km", kmObjetivo: 100.0, titulo: "Medalla de Platino (100 km)", bicoinsRecompensa: 50, tipoMedalla: .platino)
    ]
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color.bidealBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Tarjeta Resumen Superior en Verde Bosque (#14532D)
                        tarjetaResumenSuperior
                        
                        // Selector de pestañas
                        selectorPestanas
                        
                        // Lista de Hitos
                        VStack(spacing: 12) {
                            if tabSeleccionado == 0 {
                                ForEach(hitosDiarios) { hito in
                                    tarjetaHito(hito: hito, kmActuales: homeVM.kmHoy)
                                }
                            } else {
                                ForEach(hitosSemanales) { hito in
                                    tarjetaHito(hito: hito, kmActuales: homeVM.distanciaTotalKm)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer().frame(height: 30)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Camino de Misiones")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color.bidealDarkGreen)
                    }
                }
            }
        }
    }
    
    // Resumen Superior (Estilo Forest #14532D)
    private var tarjetaResumenSuperior: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(tabSeleccionado == 0 ? "DISTANCIA DE HOY" : "DISTANCIA TOTAL")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color.bidealLime)
                    
                    Text(String(format: "%.1f km", tabSeleccionado == 0 ? homeVM.kmHoy : homeVM.distanciaTotalKm))
                        .font(.system(size: 36, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Chip Saldo KMC
                VStack(alignment: .trailing, spacing: 4) {
                    Text("TU SALDO")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color.bidealLime)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "circle.circle.fill")
                            .foregroundColor(Color(red: 251/255, green: 191/255, blue: 36/255))
                            .font(.system(size: 16))
                        Text("\(authVM.kmcoinsBalance) KMC")
                            .font(.system(size: 20, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
            }
            
            Text(tabSeleccionado == 0
                 ? "Pedalea cada día por Pamplona para desbloquear premios en comercios de tu barrio."
                 : "Mantén la constancia semana a semana para conseguir las prestigiosas medallas de Navarra.")
                .font(.system(size: 12))
                .foregroundColor(Color.white.opacity(0.85))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(18)
        .background(Color.bidealForest)
        .cornerRadius(22)
        .padding(.horizontal)
        .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
    }
    
    // Selector de Pestañas
    private var selectorPestanas: some View {
        HStack(spacing: 8) {
            Button(action: { tabSeleccionado = 0 }) {
                Text("Misiones Diarias")
                    .font(.system(size: 14, weight: tabSeleccionado == 0 ? .bold : .medium))
                    .foregroundColor(tabSeleccionado == 0 ? .white : Color.bidealDarkGreen)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(tabSeleccionado == 0 ? BiDealTheme.primary : Color.bidealSurface)
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(tabSeleccionado == 0 ? BiDealTheme.primary : Color.bidealBorder, lineWidth: 1)
                    )
            }
            
            Button(action: { tabSeleccionado = 1 }) {
                Text("Misiones Semanales")
                    .font(.system(size: 14, weight: tabSeleccionado == 1 ? .bold : .medium))
                    .foregroundColor(tabSeleccionado == 1 ? .white : Color.bidealDarkGreen)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(tabSeleccionado == 1 ? BiDealTheme.primary : Color.bidealSurface)
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(tabSeleccionado == 1 ? BiDealTheme.primary : Color.bidealBorder, lineWidth: 1)
                    )
            }
        }
        .padding(.horizontal)
    }
    
    // Fila de Cada Hito / Misión
    @ViewBuilder
    private func tarjetaHito(hito: HitoModel, kmActuales: Double) -> some View {
        let completada = kmActuales >= hito.kmObjetivo
        let progreso = min(1.0, max(0.0, kmActuales / hito.kmObjetivo))
        
        HStack(spacing: 14) {
            // Icono / Medalla
            ZStack {
                Circle()
                    .fill(completada ? BiDealTheme.primaryLight : Color.gray.opacity(0.1))
                    .frame(width: 46, height: 46)
                
                if completada {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(BiDealTheme.primary)
                        .font(.system(size: 24))
                } else {
                    switch hito.tipoMedalla {
                    case .ninguna:
                        Image(systemName: "figure.outdoor.cycle")
                            .foregroundColor(BiDealTheme.primaryDark)
                            .font(.system(size: 20))
                    case .plata:
                        Image(systemName: "medal.fill")
                            .foregroundColor(Color(white: 0.7))
                            .font(.system(size: 22))
                    case .oro:
                        Image(systemName: "medal.fill")
                            .foregroundColor(Color(red: 234/255, green: 179/255, blue: 8/255))
                            .font(.system(size: 22))
                    case .platino:
                        Image(systemName: "sparkles")
                            .foregroundColor(Color(red: 168/255, green: 85/255, blue: 247/255))
                            .font(.system(size: 22))
                    }
                }
            }
            
            // Textos y Barra
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(hito.titulo)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color.bidealDarkGreen)
                    
                    Spacer()
                    
                    // Recompensa KMC
                    HStack(spacing: 3) {
                        Text("+\(hito.bicoinsRecompensa)")
                            .font(.system(size: 14, weight: .heavy, design: .rounded))
                        Text("KMC")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundColor(Color(red: 180/255, green: 83/255, blue: 9/255))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color(red: 254/255, green: 243/255, blue: 199/255))
                    .cornerRadius(8)
                }
                
                HStack {
                    Text(String(format: "%.1f / %.1f km", min(kmActuales, hito.kmObjetivo), hito.kmObjetivo))
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if completada {
                        Text("¡Completada!")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(BiDealTheme.primary)
                    } else {
                        Text("\(Int(progreso * 100))%")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                }
                
                // Barra de progreso
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.gray.opacity(0.18))
                            .frame(height: 7)
                        
                        Capsule()
                            .fill(completada ? BiDealTheme.primary : Color.bidealForest)
                            .frame(width: geo.size.width * CGFloat(progreso), height: 7)
                    }
                }
                .frame(height: 7)
            }
        }
        .padding(14)
        .background(Color.bidealSurface)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(completada ? BiDealTheme.primary.opacity(0.4) : Color.bidealBorder, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
    }
}
