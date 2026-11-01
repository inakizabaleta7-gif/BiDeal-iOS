import SwiftUI

public struct EstadisticasView: View {
    @EnvironmentObject var estadisticasVM: EstadisticasViewModel
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Gráfico de Actividad Semanal
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Actividad Semanal")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                Text("Media: \(String(format: "%.1f", estadisticasVM.kmTotalSemana / 5.0)) km/día")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text("\(String(format: "%.1f", estadisticasVM.kmTotalSemana)) km")
                                .font(.headline)
                                .fontWeight(.heavy)
                                .foregroundColor(BiDealTheme.primary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(BiDealTheme.primaryLight)
                                .cornerRadius(10)
                        }
                        
                        // Barras semanales
                        HStack(alignment: .bottom, spacing: 12) {
                            ForEach(estadisticasVM.diasSemana) { dia in
                                VStack(spacing: 6) {
                                    Text(dia.km > 0 ? String(format: "%.1f", dia.km) : "")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundColor(.secondary)
                                    
                                    ZStack(alignment: .bottom) {
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(Color.bidealBackground)
                                            .frame(width: 32, height: 110)
                                        
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(dia.esHoy ? BiDealTheme.accentGold : BiDealTheme.primary)
                                            .frame(width: 32, height: max(CGFloat(dia.km / 10.0) * 110.0, dia.km > 0 ? 10 : 0))
                                    }
                                    
                                    Text(dia.letra)
                                        .font(.caption)
                                        .fontWeight(dia.esHoy ? .heavy : .medium)
                                        .foregroundColor(dia.esHoy ? BiDealTheme.accentGold : .primary)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }
                    .padding(18)
                    .background(Color.bidealSurface)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.bidealBorder, lineWidth: 1)
                    )
                    .padding(.horizontal)
                    
                    // Componente Liga de Amigos
                    TarjetaLigaAmigosView()
                        .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(Color.bidealBackground)
            .navigationTitle("Estadísticas")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
