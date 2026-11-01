import SwiftUI

public struct TarjetaLigaAmigosView: View {
    @EnvironmentObject var estadisticasVM: EstadisticasViewModel
    @State private var copiado: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Cabecera: Título, Miembros y Bote
            HStack(alignment: .center) {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(BiDealTheme.goldLight)
                            .frame(width: 42, height: 42)
                        Image(systemName: "trophy.fill")
                            .foregroundColor(BiDealTheme.accentGold)
                            .font(.title3)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Text("Liga de Amigos")
                                .font(.headline)
                                .fontWeight(.bold)
                            Text("\(estadisticasVM.numAmigosSimulados) / \(estadisticasVM.maximoGrupo) miembros")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.bidealBackground)
                                .cornerRadius(6)
                        }
                        Text(estadisticasVM.numAmigosSimulados == 2 ? "Compitiendo tú y tu amigo" : "Grupeta ciclista semanal")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Badge de Bote Semanal
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                    Text("+25 KMC")
                        .font(.caption)
                        .fontWeight(.heavy)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(estadisticasVM.premiosDesbloqueados ? BiDealTheme.primaryLight : BiDealTheme.goldLight)
                .foregroundColor(estadisticasVM.premiosDesbloqueados ? BiDealTheme.primaryDark : BiDealTheme.accentGold)
                .cornerRadius(10)
            }
            
            // Estado de Activación de Premios (Mínimo 4)
            if !estadisticasVM.premiosDesbloqueados {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: "lock.fill")
                            .foregroundColor(BiDealTheme.accentGold)
                            .font(.caption)
                        Text("Ranking activo · Premios en espera (\(estadisticasVM.numAmigosSimulados)/\(estadisticasVM.minimoParaPremios))")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(BiDealTheme.accentGold)
                    }
                    Text("Ya podéis ver vuestros km y competir. Faltan \(estadisticasVM.minimoParaPremios - estadisticasVM.numAmigosSimulados) amigos para activar los premios (+25 KMC al 1º y +10 KMC si llegáis a 200 km grupal).")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    ProgressView(value: Double(estadisticasVM.numAmigosSimulados), total: Double(estadisticasVM.minimoParaPremios))
                        .tint(BiDealTheme.accentGold)
                }
                .padding(12)
                .background(BiDealTheme.goldLight.opacity(0.4))
                .cornerRadius(12)
            } else {
                HStack(spacing: 8) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(BiDealTheme.primary)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("🔥 ¡Premios de Liga Desbloqueados!")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(BiDealTheme.primaryDark)
                        Text("• 1º clasificado: +25 KMC el domingo 23:59 · Meta cooperativa: +10 KMC para TODOS si sumáis 200 km.")
                            .font(.caption2)
                            .foregroundColor(BiDealTheme.primaryDark)
                    }
                }
                .padding(10)
                .background(BiDealTheme.primaryLight)
                .cornerRadius(10)
            }
            
            // Meta Cooperativa de Grupeta (200 km en equipo)
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("🤝 Meta de Equipo (200 km)")
                        .font(.caption)
                        .fontWeight(.bold)
                    Spacer()
                    Text(estadisticasVM.metaGrupalAlcanzada ? "¡CONSEGUIDO! +10 KMC c/u" : "+10 KMC para todos")
                        .font(.caption2)
                        .fontWeight(.heavy)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(estadisticasVM.metaGrupalAlcanzada ? BiDealTheme.primaryLight : Color.blue.opacity(0.1))
                        .foregroundColor(estadisticasVM.metaGrupalAlcanzada ? BiDealTheme.primaryDark : Color.blue)
                        .cornerRadius(6)
                }
                
                HStack {
                    Text(String(format: "%.1f / 200 km acumulados", estadisticasVM.kmTotalesGrupeta))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(Int(estadisticasVM.porcentajeMetaGrupal * 100))%")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(BiDealTheme.primary)
                }
                
                ProgressView(value: estadisticasVM.porcentajeMetaGrupal)
                    .tint(estadisticasVM.metaGrupalAlcanzada ? Color.green : BiDealTheme.primary)
            }
            .padding(12)
            .background(Color.bidealBackground)
            .cornerRadius(12)
            
            // Clasificación Semanal en Vivo
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Clasificación Semanal")
                        .font(.subheadline)
                        .fontWeight(.bold)
                    Spacer()
                    Text("Hasta domingo 23:59")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 6) {
                    ForEach(Array(estadisticasVM.miembrosLiga.enumerated()), id: \.offset) { index, miembro in
                        let esLider = index == 0
                        HStack(spacing: 10) {
                            Text(esLider ? "👑" : "\(index + 1).")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(esLider ? BiDealTheme.accentGold : .secondary)
                                .frame(width: 20)
                            
                            Circle()
                                .fill(miembro.esUsuario ? BiDealTheme.primary : Color.gray.opacity(0.3))
                                .frame(width: 28, height: 28)
                                .overlay(
                                    Text(String(miembro.nombre.prefix(1)))
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .foregroundColor(miembro.esUsuario ? .white : .primary)
                                )
                            
                            VStack(alignment: .leading, spacing: 1) {
                                HStack(spacing: 4) {
                                    Text(miembro.nombre)
                                        .font(.caption)
                                        .fontWeight(miembro.esUsuario ? .bold : .medium)
                                    if miembro.esUsuario {
                                        Text("TÚ")
                                            .font(.system(size: 8, weight: .heavy))
                                            .padding(.horizontal, 4)
                                            .padding(.vertical, 1)
                                            .background(BiDealTheme.primaryLight)
                                            .foregroundColor(BiDealTheme.primaryDark)
                                            .cornerRadius(4)
                                    }
                                }
                                if esLider && estadisticasVM.premiosDesbloqueados {
                                    Text("Líder provisional · +25 KMC")
                                        .font(.system(size: 9))
                                        .foregroundColor(BiDealTheme.accentGold)
                                }
                            }
                            
                            Spacer()
                            
                            Text(String(format: "%.1f km", miembro.kmSemana))
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(esLider ? BiDealTheme.primary : .primary)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(miembro.esUsuario ? BiDealTheme.primaryLight.opacity(0.4) : Color.clear)
                        .cornerRadius(8)
                    }
                }
            }
            
            // Código de Grupo y Copiar
            HStack {
                VStack(alignment: .leading, spacing: 1) {
                    Text("Tu código de grupo:")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(estadisticasVM.codigoGrupo)
                        .font(.headline)
                        .fontWeight(.heavy)
                        .fontDesign(.monospaced)
                        .foregroundColor(BiDealTheme.primary)
                }
                Spacer()
                Button(action: {
                    UIPasteboard.general.string = estadisticasVM.codigoGrupo
                    copiado = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        copiado = false
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: copiado ? "checkmark" : "doc.on.doc")
                        Text(copiado ? "¡Copiado!" : "Copiar")
                    }
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.bidealBackground)
                    .cornerRadius(8)
                }
            }
            .padding(12)
            .background(Color.bidealBackground.opacity(0.6))
            .cornerRadius(12)
            
            // Botón Compartir por WhatsApp
            Button(action: compartirGrupeta) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Invitar Amigos por WhatsApp")
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(BiDealTheme.primary)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            
            // Selector de Prueba (Simulador 2, 3, 5 y 8 miembros)
            HStack(spacing: 6) {
                Text("Probar vista:")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                ForEach([2, 3, 5, 8], id: \.self) { cant in
                    Button(action: { estadisticasVM.numAmigosSimulados = cant }) {
                        Text(cant == 2 ? "2 (Tú + amigo)" : "\(cant) amigos")
                            .font(.system(size: 10, weight: estadisticasVM.numAmigosSimulados == cant ? .bold : .regular))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 4)
                            .background(estadisticasVM.numAmigosSimulados == cant ? BiDealTheme.primary : Color.bidealBackground)
                            .foregroundColor(estadisticasVM.numAmigosSimulados == cant ? .white : .primary)
                            .cornerRadius(6)
                    }
                }
            }
        }
        .padding(18)
        .background(Color.bidealSurface)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.bidealBorder, lineWidth: 1)
        )
    }
    
    private func compartirGrupeta() {
        let texto = "¡Únete a mi grupeta ciclista en BiDeal! 🚲💨 Pedaleamos por Pamplona, comparamos nuestros kilómetros semanales y si somos al menos 4 y sumamos 200 km entre todos, ¡ganamos KmCoins juntos para canjear en comercios locales! Descarga la app en https://www.bideal.org y únete con mi código: \(estadisticasVM.codigoGrupo)"
        let av = UIActivityViewController(activityItems: [texto], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(av, animated: true, completion: nil)
        }
    }
}
