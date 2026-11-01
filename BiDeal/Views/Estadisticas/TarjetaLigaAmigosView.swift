import SwiftUI

public struct TarjetaLigaAmigosView: View {
    @EnvironmentObject var estadisticasVM: EstadisticasViewModel
    @EnvironmentObject var homeVM: HomeViewModel
    
    @State private var panelDesplegado: Bool = true
    @State private var mostrarOpcionesAnadir: Bool = false
    @State private var copiadoEnlace: Bool = false
    @State private var copiadoCodigo: Bool = false
    @State private var mostrarModalCanje: Bool = false
    @State private var inputCodigoCanje: String = ""
    @State private var uniendoAGrupo: Bool = false
    
    public init() {}
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            cabeceraGrupo
            seccionAnadirLiga
            
            if panelDesplegado {
                VStack(alignment: .leading, spacing: 14) {
                    rejillaPremios
                    metaEquipo
                    clasificacionSemanal
                    enlacesYCompartir
                    botonInvitar
                    botonCanjear
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(18)
        .background(Color.bidealSurface)
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.bidealBorder, lineWidth: 1)
        )
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: panelDesplegado)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: mostrarOpcionesAnadir)
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
                        panelDesplegado = true
                    }
                }
            )
        }
    }
    
    // ==========================================
    // 1. CABECERA: TÍTULO, CAPACIDAD Y TOGGLE PANEL
    // ==========================================
    private var cabeceraGrupo: some View {
        HStack(alignment: .center) {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
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
                        .lineLimit(1)
                    
                    HStack(spacing: 6) {
                        Text("\(estadisticasVM.totalMiembros)/\(estadisticasVM.maximoGrupo) ciclistas")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.bidealBackground)
                            .cornerRadius(6)
                        
                        Text("● En vivo")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(BiDealTheme.primary)
                    }
                }
            }
            
            Spacer()
            
            // Botón Desplegar / Plegar Panel
            Button(action: {
                withAnimation {
                    panelDesplegado.toggle()
                }
            }) {
                HStack(spacing: 4) {
                    Text(panelDesplegado ? "Panel ▲" : "Panel ▼")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.primary)
                }
                .padding(.horizontal, 9)
                .padding(.vertical, 6)
                .background(Color.bidealBackground)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.bidealBorder, lineWidth: 1)
                )
            }
        }
    }
    
    // ==========================================
    // 2. SECCIÓN: AÑADIR LIGA CICLISTA (CREAR / UNIRME)
    // ==========================================
    private var seccionAnadirLiga: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center) {
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(BiDealTheme.primaryLight)
                            .frame(width: 28, height: 28)
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(BiDealTheme.primary)
                    }
                    
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Añadir Liga Ciclista")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.primary)
                        Text("Crear nuevo grupo o unirme con código")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        mostrarOpcionesAnadir.toggle()
                    }
                }) {
                    Text(mostrarOpcionesAnadir ? "Ocultar" : "Elegir")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(BiDealTheme.primary)
                }
            }
            
            if mostrarOpcionesAnadir {
                VStack(spacing: 8) {
                    // Opción 1: Crear Liga Ciclista
                    Button(action: {
                        withAnimation {
                            mostrarOpcionesAnadir = false
                            panelDesplegado = true
                        }
                    }) {
                        HStack(spacing: 10) {
                            Text("👑")
                                .font(.system(size: 18))
                            VStack(alignment: .leading, spacing: 1) {
                                Text("Crear Liga Ciclista")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.primary)
                                Text("Eres el capitán · Genera tu enlace directo")
                                    .font(.system(size: 10))
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text("➔")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.secondary)
                        }
                        .padding(10)
                        .background(Color.bidealSurface)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.bidealBorder, lineWidth: 1)
                        )
                    }
                    
                    // Opción 2: Unirme a Liga Ciclista
                    Button(action: {
                        mostrarOpcionesAnadir = false
                        mostrarModalCanje = true
                    }) {
                        HStack(spacing: 10) {
                            Text("🤝")
                                .font(.system(size: 18))
                            VStack(alignment: .leading, spacing: 1) {
                                Text("Unirme a Liga Ciclista")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.primary)
                                Text("Introduce el código de un amigo ciclista")
                                    .font(.system(size: 10))
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text("➔")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.secondary)
                        }
                        .padding(10)
                        .background(Color.bidealSurface)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.bidealBorder, lineWidth: 1)
                        )
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding(12)
        .background(Color.bidealBackground)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.bidealBorder, lineWidth: 1)
        )
    }
    
    // ==========================================
    // 3. REJILLA DE PREMIOS (SIN SALTOS FEOS EN KMCOINS)
    // ==========================================
    private var rejillaPremios: some View {
        HStack(spacing: 8) {
            // Tarjeta 1: Líder Semanal
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("👑 Líder")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(BiDealTheme.accentGold)
                    Spacer()
                    Text("Dom 23:59")
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                }
                
                HStack(alignment: .lastTextBaseline, spacing: 3) {
                    Text("+\(estadisticasVM.boteKmCoins)")
                        .font(.system(size: 17, weight: .black))
                        .foregroundColor(BiDealTheme.accentGold)
                    Text("KmCoins")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(BiDealTheme.accentGold)
                }
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(BiDealTheme.goldLight.opacity(0.35))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(BiDealTheme.accentGold.opacity(0.3), lineWidth: 1)
            )
            
            // Tarjeta 2: Meta Colectiva
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("🤝 Meta 200 km")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(BiDealTheme.primaryDark)
                    Spacer()
                    Text("Para todos")
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                }
                
                HStack(alignment: .lastTextBaseline, spacing: 3) {
                    Text("+\(estadisticasVM.premioMetaKmCoins)")
                        .font(.system(size: 17, weight: .black))
                        .foregroundColor(BiDealTheme.primary)
                    Text("KmCoins c/u")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(BiDealTheme.primaryDark)
                }
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(BiDealTheme.primaryLight.opacity(0.35))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(BiDealTheme.primary.opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    // ==========================================
    // 4. META COOPERATIVA DE GRUPO (BARRA 200 KM)
    // ==========================================
    private var metaEquipo: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                HStack(spacing: 4) {
                    Text("🚲")
                        .font(.system(size: 13))
                    Text(String(format: "Progreso: %.1f / %.0f km", estadisticasVM.kmTotalesGrupo, estadisticasVM.metaKmGrupal))
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.primary)
                }
                Spacer()
                Text("\(Int(estadisticasVM.porcentajeMetaGrupal * 100))%")
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundColor(estadisticasVM.metaGrupalAlcanzada ? Color.green : BiDealTheme.primary)
            }
            
            ProgressView(value: estadisticasVM.porcentajeMetaGrupal)
                .tint(estadisticasVM.metaGrupalAlcanzada ? Color.green : BiDealTheme.primary)
            
            HStack {
                let kmRestantes = max(0, estadisticasVM.metaKmGrupal - estadisticasVM.kmTotalesGrupo)
                Text(estadisticasVM.metaGrupalAlcanzada ? "¡Meta conseguida! +\(estadisticasVM.premioMetaKmCoins) KMC para todos" : String(format: "Faltan %.1f km para el bote común", kmRestantes))
                    .font(.system(size: 11))
                    .foregroundColor(estadisticasVM.metaGrupalAlcanzada ? Color.green : .secondary)
                Spacer()
                if !estadisticasVM.metaGrupalAlcanzada {
                    Text("+\(estadisticasVM.premioMetaKmCoins) KMC")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(BiDealTheme.primary)
                }
            }
        }
        .padding(12)
        .background(Color.bidealBackground)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(estadisticasVM.metaGrupalAlcanzada ? Color.green.opacity(0.4) : Color.bidealBorder, lineWidth: 1)
        )
    }
    
    // ==========================================
    // 5. CLASIFICACIÓN SEMANAL (RANKING LIMPIO)
    // ==========================================
    private var clasificacionSemanal: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Ranking en Vivo")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.primary)
                Spacer()
                Text("Semana actual")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            
            if estadisticasVM.miembrosGrupo.isEmpty {
                HStack(spacing: 8) {
                    Text("👑")
                        .font(.system(size: 13))
                        .frame(width: 22)
                    Circle()
                        .fill(BiDealTheme.primary)
                        .frame(width: 30, height: 30)
                        .overlay(Text("T").font(.system(size: 12, weight: .bold)).foregroundColor(.white))
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Tú (\(homeVM.usuario.nombre ?? "Ciclista"))")
                            .font(.system(size: 13, weight: .heavy))
                        Text("Líder · +\(estadisticasVM.boteKmCoins) KMC")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(BiDealTheme.accentGold)
                    }
                    Spacer()
                    Text(String(format: "%.1f km", homeVM.usuario.km_semana))
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(BiDealTheme.primary)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(BiDealTheme.primaryLight.opacity(0.35))
                .cornerRadius(10)
            } else {
                VStack(spacing: 4) {
                    ForEach(Array(estadisticasVM.miembrosGrupo.enumerated()), id: \.element.id) { index, miembro in
                        let posicion = index + 1
                        let esLider = posicion == 1
                        HStack(spacing: 8) {
                            Text(posicion == 1 ? "👑" : (posicion == 2 ? "🥈" : (posicion == 3 ? "🥉" : "\(posicion).")))
                                .font(.system(size: 13, weight: .bold))
                                .frame(width: 22)
                            
                            Circle()
                                .fill(miembro.es_usuario ? BiDealTheme.primary : (esLider ? BiDealTheme.goldLight : Color.gray.opacity(0.25)))
                                .frame(width: 30, height: 30)
                                .overlay(
                                    Text(String(miembro.nombre.prefix(1)).uppercased())
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(miembro.es_usuario ? .white : (esLider ? BiDealTheme.accentGold : .primary))
                                )
                            
                            VStack(alignment: .leading, spacing: 1) {
                                HStack(spacing: 4) {
                                    Text(miembro.es_usuario ? "Tú (\(miembro.nombre))" : miembro.nombre)
                                        .font(.system(size: 13, weight: miembro.es_usuario ? .heavy : .semibold))
                                    if miembro.es_usuario {
                                        Text("TÚ")
                                            .font(.system(size: 8, weight: .black))
                                            .padding(.horizontal, 4)
                                            .padding(.vertical, 1)
                                            .background(BiDealTheme.primaryLight)
                                            .foregroundColor(BiDealTheme.primaryDark)
                                            .cornerRadius(4)
                                    }
                                }
                                if esLider {
                                    Text("Líder · +\(estadisticasVM.boteKmCoins) KMC")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(BiDealTheme.accentGold)
                                }
                            }
                            
                            Spacer()
                            
                            Text(String(format: "%.1f km", miembro.km_semana))
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(esLider ? BiDealTheme.primary : .primary)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(miembro.es_usuario ? BiDealTheme.primaryLight.opacity(0.35) : Color.clear)
                        .cornerRadius(10)
                    }
                }
            }
        }
    }
    
    // ==========================================
    // 6. ENLACES Y COMPARTIR RÁPIDO
    // ==========================================
    private var enlacesYCompartir: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("🔗 Enlace directo 1-clic:")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.secondary)
                Spacer()
                Text("bideal.org/grupo?codigo=\(estadisticasVM.codigoEfectivo)")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(BiDealTheme.primary)
                    .lineLimit(1)
            }
            
            HStack(spacing: 8) {
                Button(action: {
                    UIPasteboard.general.string = estadisticasVM.enlaceDirectoGrupo
                    copiadoEnlace = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) { copiadoEnlace = false }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: copiadoEnlace ? "checkmark" : "link")
                            .font(.system(size: 11))
                        Text(copiadoEnlace ? "¡Copiado!" : "Copiar Enlace")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.bidealBackground)
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.bidealBorder, lineWidth: 1))
                }
                
                Button(action: {
                    UIPasteboard.general.string = estadisticasVM.codigoEfectivo
                    copiadoCodigo = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) { copiadoCodigo = false }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: copiadoCodigo ? "checkmark" : "doc.on.doc")
                            .font(.system(size: 11))
                        Text(copiadoCodigo ? "¡Copiado!" : "Copiar Código")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.bidealBackground)
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.bidealBorder, lineWidth: 1))
                }
            }
        }
        .padding(10)
        .background(Color.bidealBackground)
        .cornerRadius(12)
    }
    
    // ==========================================
    // 7. BOTÓN PRINCIPAL WHATSAPP
    // ==========================================
    private var botonInvitar: some View {
        Button(action: compartirWhatsApp) {
            HStack(spacing: 8) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 14))
                Text("Invitar al Grupo por WhatsApp")
                    .font(.system(size: 13, weight: .bold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(BiDealTheme.primary)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
    }
    
    // ==========================================
    // 8. ACCIÓN SECUNDARIA: UNIRSE A OTRO GRUPO
    // ==========================================
    private var botonCanjear: some View {
        Button(action: { mostrarModalCanje = true }) {
            Text("¿Tienes el código de otro grupo? Unirme aquí")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.secondary)
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
            VStack(spacing: 18) {
                HStack(spacing: 8) {
                    Text("🤝")
                        .font(.title2)
                    Text("Unirme a Liga Ciclista")
                        .font(.headline)
                        .fontWeight(.bold)
                }
                .padding(.top, 10)
                
                Text("Introduce el código de 6 caracteres o enlace que te ha compartido tu amigo ciclista para competir juntos esta semana.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 10)
                
                TextField("Ej: BIDEAL", text: $inputCodigo)
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
                            Text("Unirme a la Liga")
                                .font(.subheadline)
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
            .padding(20)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
            }
        }
        .presentationDetents([.fraction(0.45)])
    }
}
