import SwiftUI

public struct TerminosView: View {
    let onAccept: () -> Void
    let showBackButton: Bool
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authVM: AuthViewModel
    
    @State private var showDeleteAccountDialog: Bool = false
    
    public init(onAccept: @escaping () -> Void = {}, showBackButton: Bool = false) {
        self.onAccept = onAccept
        self.showBackButton = showBackButton
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color.bidealBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 18) {
                            // Encabezado
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Condiciones de Uso de BiDeal")
                                    .font(.system(size: 20, weight: .heavy))
                                    .foregroundColor(BiDealTheme.primary)
                                Text("Última actualización: Octubre 2026")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.top, 8)
                            
                            SeccionTerminoView(
                                numero: "1",
                                titulo: "Uso del Sistema de Rastreo Automático",
                                contenido: "El sistema de la aplicación mide continuamente la actividad física del usuario en segundo plano utilizando los sensores del dispositivo y Apple Health. El rastreo se activa de forma automática únicamente cuando el dispositivo detecta que el usuario está montando en bicicleta, recogiendo datos de distancia de forma periódica. Los datos recopilados se sincronizan automáticamente con nuestra API para otorgar recompensas justas."
                            )
                            
                            SeccionTerminoView(
                                numero: "2",
                                titulo: "Sistema Antifraude y Exclusión de Rutas",
                                contenido: "BiDeal se reserva el derecho de descartar y anular trayectos que no cumplan con los parámetros físicos razonables de una bicicleta. El sistema anulará automáticamente tramos donde se superen velocidades máximas de 50 km/h o inferiores a 1 km/h."
                            )
                            
                            SeccionTerminoView(
                                numero: "3",
                                titulo: "Economía Virtual (KMCoins) y Misiones",
                                contenido: "Los usuarios obtienen KMCoins al acumular kilómetros verificados y al superar misiones diarias o semanales en Pamplona. Cada lote de KMCoins posee una vigencia temporal y caducará automáticamente tras un (1) año natural desde su emisión. El gasto de KMCoins se procesa mediante un algoritmo FIFO (las más antiguas se consumen primero)."
                            )
                            
                            SeccionTerminoView(
                                numero: "4",
                                titulo: "Canje de Descuentos en Comercios Locales",
                                contenido: "Las KMCoins pueden ser utilizadas como medio de intercambio virtual para obtener descuentos al escanear códigos QR en mostradores de comercios locales asociados de Pamplona. Las ofertas están sujetas a disponibilidad y condiciones de cada establecimiento."
                            )
                            
                            Divider()
                                .padding(.vertical, 8)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Política de Privacidad de BiDeal")
                                    .font(.system(size: 20, weight: .heavy))
                                    .foregroundColor(BiDealTheme.primary)
                                Text("Última actualización: Octubre 2026")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                            
                            SeccionTerminoView(
                                numero: "1",
                                titulo: "Recopilación de Datos de Ubicación y Actividad",
                                contenido: "Aviso Destacado de Privacidad: BiDeal recopila datos de distancia ciclista y ubicación para calcular el trayecto en bicicleta y generar recompensas (KMCoins) incluso cuando la app está cerrada o no está en uso. Estos datos son esenciales para el funcionamiento central de la aplicación y la validación de premios en comercios de proximidad."
                            )
                            
                            SeccionTerminoView(
                                numero: "2",
                                titulo: "Datos Personales e Información del Perfil",
                                contenido: "Para crear y mantener una cuenta en BiDeal, recopilamos información personal básica (ID, correo electrónico, nombre, apellidos, teléfono y género). Esta información se almacena de manera segura y encriptada en nuestra infraestructura de base de datos de Supabase."
                            )
                            
                            SeccionTerminoView(
                                numero: "3",
                                titulo: "Acceso a la Cámara del Dispositivo",
                                contenido: "La aplicación solicita permiso explícito para usar la cámara con un único propósito: escanear los códigos QR situados en los comercios locales de Pamplona. Las imágenes se procesan localmente en el dispositivo para extraer el código y nunca son transmitidas ni almacenadas en servidores externos."
                            )
                            
                            SeccionTerminoView(
                                numero: "4",
                                titulo: "Conservación de Datos y Derecho al Olvido (RGPD)",
                                contenido: "De conformidad con el Reglamento General de Protección de Datos (RGPD) de la UE, conservas en todo momento el derecho a la supresión total de tus datos. Puedes solicitar la eliminación definitiva de tu cuenta y de tus registros en cualquier momento."
                            )
                            
                            if showBackButton {
                                Button(action: { showDeleteAccountDialog = true }) {
                                    Text("Eliminar cuenta y datos personales")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(Color(red: 220/255, green: 38/255, blue: 38/255))
                                        .underline()
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .padding(.vertical, 12)
                                }
                            }
                            
                            Spacer().frame(height: 20)
                        }
                        .padding(20)
                    }
                    
                    // Botón inferior
                    if !showBackButton {
                        VStack {
                            Divider()
                            Button(action: onAccept) {
                                Text("Aceptar y Continuar")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 15)
                                    .background(BiDealTheme.primary)
                                    .cornerRadius(16)
                                    .shadow(color: BiDealTheme.primary.opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                        }
                        .background(Color.bidealSurface)
                    }
                }
            }
            .navigationTitle("Términos y Privacidad")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if showBackButton {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(action: { dismiss() }) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color.bidealDarkGreen)
                        }
                    }
                }
            }
            .alert("Eliminar cuenta", isPresented: $showDeleteAccountDialog) {
                Button("Cancelar", role: .cancel) { }
                Button("Eliminar definitivamente", role: .destructive) {
                    authVM.cerrarSesion()
                    dismiss()
                }
            } message: {
                Text("¿Estás seguro de que deseas eliminar tu cuenta? Esta acción borrará permanentemente todos tus KmCoins acumulados, tus estadísticas y tu registro en BiDeal.")
            }
        }
    }
}

struct SeccionTerminoView: View {
    let numero: String
    let titulo: String
    let contenido: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("\(numero). \(titulo)")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(Color.bidealDarkGreen)
            
            Text(contenido)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .lineSpacing(3)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.bidealSurface)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.bidealBorder, lineWidth: 1)
        )
    }
}
