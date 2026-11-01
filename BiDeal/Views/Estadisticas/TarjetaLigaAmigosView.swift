import SwiftUI

public struct TarjetaLigaAmigosView: View {
    @EnvironmentObject var estadisticasVM: EstadisticasViewModel
    @EnvironmentObject var homeVM: HomeViewModel
    
    @State private var copiadoEnlace: Bool = false
    @State private var copiadoCodigo: Bool = false
    @State private var mostrarModalCanje: Bool = false
    @State private var inputCodigoCanje: String = ""
    @State private var uniendoAGrupo: Bool = false
    
    public init() {}
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            cabeceraGrupo
            estadoPremios
            metaEquipo
            clasificacionSemanal
            enlacesYCompartir
            botonInvitar
            botonCanjear
        }
        .padding(18)
        .background(Color.bidealSurface)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.bidealBorder, lineWidth: 1)
        )
        .sheet(isPresented: $mostrarModalCanje) {
            ModalCanjeCodigoGrupo(
                inputCodigo: $inputCodigoCanje,
                uniendo: $uniendoAGrupo,
                onUnirse: {
                    Task {
                        uniendoAGrupo = true
                        let _ = await estadisticasVM.unirseAGrupo(userId: homeVM.usuario.id, codigo: inputCodigoCanje)
                        uniendoAGrupo = false
                        mostrarModalCanje = false
                    }
                }
            )
        }
    }
    
    private var cabeceraGrupo: some View {
        HStack(alignment: .center) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(BiDealTheme.goldLight)
                        .frame(width: 44, height: 44)
                    Text("🏆")
                        .font(.title2)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(estadisticasVM.nombreGrupo)
                        .font(.headline)
                        .fontWeight(.heavy)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 6) {
                        Text("\(estadisticasVM.totalMiembros) / \(estadisticasVM.maximoGrupo) ciclistas")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.bidealBackground)
                            .cornerRadius(6)
                        
                        Text(estadisticasVM.totalMiembros > 1 ? "Compitiendo esta semana" : "Grupo en formación")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            HStack(spacing: 4) {
                Text("⭐")
                    .font(.caption2)
                Text("+\(estadisticasVM.boteKmCoins) KMC")
                    .font(.caption)
                    .fontWeight(.heavy)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(estadisticasVM.premiosDesbloqueados ? BiDealTheme.primaryLight : BiDealTheme.goldLight)
            .foregroundColor(estadisticasVM.premiosDesbloqueados ? BiDealTheme.primaryDark : BiDealTheme.accentGold)
            .cornerRadius(10)
        }
    }
    
    @ViewBuilder
    private var estadoPremios: some View {
        if !estadisticasVM.premiosDesbloqueados {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "lock.fill")
                        .foregroundColor(BiDealTheme.accentGold)
                        .font(.caption)
                    Text("Ranking activo · Premios en espera (\(estadisticasVM.totalMiembros)/\(estadisticasVM.minimoParaPremios) miembros)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(BiDealTheme.accentGold)
                }
                Text(estadisticasVM.totalMiembros == 1 ?
                     "¡Ya sumas tus km! Invita a 3 amigos ciclistas con tu enlace para desbloquear el reparto de premios dominical: +\(estadisticasVM.boteKmCoins) KMC al #1 y +\(estadisticasVM.premioMetaKmCoins) KMC para todos si superáis los \(Int(estadisticasVM.metaKmGrupal)) km." :
                     "Ya sois \(estadisticasVM.totalMiembros) en el grupo. ¡Faltan \(estadisticasVM.minimoParaPremios - estadisticasVM.totalMiembros) ciclistas para activar el bote del domingo!")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                ProgressView(value: Double(estadisticasVM.totalMiembros), total: Double(estadisticasVM.minimoParaPremios))
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
                    Text("🔥 ¡Premios de Liga Activados!")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(BiDealTheme.primaryDark)
                    Text("• Ganador semanal (#1): +\(estadisticasVM.boteKmCoins) KmCoins el domingo 23:59.\n• Meta de grupo: +\(estadisticasVM.premioMetaKmCoins) KmCoins para TODOS si sumáis \(Int(estadisticasVM.metaKmGrupal)) km.")
                        .font(.caption2)
                        .foregroundColor(BiDealTheme.primaryDark)
                }
            }
            .padding(10)
            .background(BiDealTheme.primaryLight)
            .cornerRadius(10)
        }
    }
    
    private var metaEquipo: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("🤝 Meta de Equipo (\(Int(estadisticasVM.metaKmGrupal)) km)")
                    .font(.caption)
                    .fontWeight(.bold)
                Spacer()
                Text(estadisticasVM.metaGrupalAlcanzada ? "¡CONSEGUIDO! +\(estadisticasVM.premioMetaKmCoins) KMC c/u" : "+\(estadisticasVM.premioMetaKmCoins) KMC para todos")
                    .font(.caption2)
                    .fontWeight(.heavy)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(estadisticasVM.metaGrupalAlcanzada ? BiDealTheme.primaryLight : Color.blue.opacity(0.1))
                    .foregroundColor(estadisticasVM.metaGrupalAlcanzada ? BiDealTheme.primaryDark : Color.blue)
                    .cornerRadius(6)
            }
            
            HStack {
                Text(String(format: "%.1f / %.0f km acumulados", estadisticasVM.kmTotalesGrupo, estadisticasVM.metaKmGrupal))
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
            
            Text(estadisticasVM.metaGrupalAlcanzada ?
                 "¡Meta superada! Todo el grupo sumará +\(estadisticasVM.premioMetaKmCoins) KmCoins este domingo por pedalear más de \(Int(estadisticasVM.metaKmGrupal)) km." :
                 "Cada kilómetro que pedalees tú o tus compañeros de grupo suma para el reto común de \(Int(estadisticasVM.metaKmGrupal)) km.")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(Color.bidealBackground)
        .cornerRadius(12)
    }
    
    private var clasificacionSemanal: some View {
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
            
            if estadisticasVM.miembrosGrupo.isEmpty {
                HStack(spacing: 10) {
                    Text("👑")
                        .font(.headline)
                    Circle()
                        .fill(BiDealTheme.primary)
                        .frame(width: 32, height: 32)
                        .overlay(Text("T").font(.caption).bold().foregroundColor(.white))
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Tú (\(homeVM.usuario.nombre ?? "Ciclista"))")
                            .font(.caption)
                            .fontWeight(.bold)
                        Text("¡Encabezas tu grupo! Invita amigos para competir.")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Text(String(format: "%.1f km", homeVM.usuario.km_semana))
                        .font(.caption)
                        .bold()
                        .foregroundColor(BiDealTheme.primary)
                }
                .padding(10)
                .background(BiDealTheme.primaryLight.opacity(0.4))
                .cornerRadius(10)
            } else {
                VStack(spacing: 6) {
                    ForEach(Array(estadisticasVM.miembrosGrupo.enumerated()), id: \.element.id) { index, miembro in
                        let posicion = index + 1
                        let esLider = posicion == 1
                        HStack(spacing: 10) {
                            Text(posicion == 1 ? "👑" : (posicion == 2 ? "🥈" : (posicion == 3 ? "🥉" : "\(posicion).")))
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(esLider ? BiDealTheme.accentGold : .secondary)
                                .frame(width: 22)
                            
                            Circle()
                                .fill(miembro.es_usuario ? BiDealTheme.primary : Color.gray.opacity(0.3))
                                .frame(width: 28, height: 28)
                                .overlay(
                                    Text(String(miembro.nombre.prefix(1)).uppercased())
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .foregroundColor(miembro.es_usuario ? .white : .primary)
                                )
                            
                            VStack(alignment: .leading, spacing: 1) {
                                HStack(spacing: 4) {
                                    Text(miembro.es_usuario ? "Tú (\(miembro.nombre))" : miembro.nombre)
                                        .font(.caption)
                                        .fontWeight(miembro.es_usuario ? .bold : .medium)
                                    if miembro.es_usuario {
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
                                    Text("Líder provisional · +\(estadisticasVM.boteKmCoins) KMC")
                                        .font(.system(size: 9))
                                        .foregroundColor(BiDealTheme.accentGold)
                                }
                            }
                            
                            Spacer()
                            
                            Text(String(format: "%.1f km", miembro.km_semana))
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(esLider ? BiDealTheme.primary : .primary)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(miembro.es_usuario ? BiDealTheme.primaryLight.opacity(0.4) : Color.clear)
                        .cornerRadius(8)
                    }
                }
            }
        }
    }
    
    private var enlacesYCompartir: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Enlace directo de 1 clic (sin teclear códigos):")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
            
            Text(estadisticasVM.enlaceDirectoGrupo)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(BiDealTheme.primary)
                .lineLimit(1)
            
            HStack(spacing: 8) {
                Button(action: {
                    UIPasteboard.general.string = estadisticasVM.enlaceDirectoGrupo
                    copiadoEnlace = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) { copiadoEnlace = false }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: copiadoEnlace ? "checkmark" : "link")
                        Text(copiadoEnlace ? "¡Enlace copiado!" : "Copiar Enlace")
                    }
                    .font(.caption)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.bidealBackground)
                    .cornerRadius(8)
                }
                
                Button(action: {
                    UIPasteboard.general.string = estadisticasVM.codigoEfectivo
                    copiadoCodigo = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) { copiadoCodigo = false }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: copiadoCodigo ? "checkmark" : "doc.on.doc")
                        Text(copiadoCodigo ? "¡Código copiado!" : "Copiar Código")
                    }
                    .font(.caption)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.bidealBackground)
                    .cornerRadius(8)
                }
            }
        }
        .padding(12)
        .background(Color.bidealBackground.opacity(0.7))
        .cornerRadius(12)
    }
    
    private var botonInvitar: some View {
        Button(action: compartirWhatsApp) {
            HStack(spacing: 8) {
                Image(systemName: "paperplane.fill")
                Text("Invitar al Grupo por WhatsApp")
                    .fontWeight(.heavy)
            }
            .font(.subheadline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(BiDealTheme.primary)
            .foregroundColor(.white)
            .cornerRadius(14)
            .shadow(color: BiDealTheme.primary.opacity(0.3), radius: 6, y: 3)
        }
    }
    
    private var botonCanjear: some View {
        Button(action: { mostrarModalCanje = true }) {
            Text("¿Tienes el enlace o código de un amigo? Canjearlo aquí")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(BiDealTheme.primary)
                .frame(maxWidth: .infinity)
        }
    }
    
    private func compartirWhatsApp() {
        let directLink = estadisticasVM.enlaceDirectoGrupo
        let texto = "¡Únete a mi grupo ciclista en BiDeal! 🚲💨\n\nPedaleamos juntos por Pamplona, sumamos km en equipo y conseguimos descuentos en comercios locales.\n\n👉 Pulsa en este enlace para unirte directamente a mi grupo sin meter códigos:\n\(directLink)\n\n(O abre la app en bideal://grupo?codigo=\(estadisticasVM.codigoEfectivo))"
        
        guard let encoded = texto.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let whatsappURL = URL(string: "whatsapp://send?text=\(encoded)") else {
            return
        }
        
        if UIApplication.shared.canOpenURL(whatsappURL) {
            UIApplication.shared.open(whatsappURL)
        } else {
            let av = UIActivityViewController(activityItems: [texto], applicationActivities: nil)
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                rootVC.present(av, animated: true, completion: nil)
            }
        }
    }
}

struct ModalCanjeCodigoGrupo: View {
    @Binding var inputCodigo: String
    @Binding var uniendo: Bool
    let onUnirse: () -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Únete a un Grupo Ciclista")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Introduce el código de grupo que te ha compartido tu amigo para sumar kilómetros juntos en la clasificación semanal.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                TextField("Ej: BD-852F7B", text: $inputCodigo)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .font(.system(.title3, design: .monospaced).weight(.heavy))
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.bidealBackground)
                    .cornerRadius(12)
                
                Button(action: onUnirse) {
                    HStack {
                        if uniendo {
                            ProgressView().tint(.white)
                        } else {
                            Text("Vincularme al Grupo")
                                .fontWeight(.bold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(inputCodigo.trimmingCharacters(in: .whitespaces).isEmpty ? Color.gray : BiDealTheme.primary)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(inputCodigo.trimmingCharacters(in: .whitespaces).isEmpty || uniendo)
                
                Spacer()
            }
            .padding(24)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium])
    }
}
