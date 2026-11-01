import SwiftUI
import CoreLocation

public struct EstadoRastreadorView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var healthKitManager = HealthKitManager.shared
    @ObservedObject var locationManager = LocationManager.shared
    
    public init() {}
    
    private var permisoGpsOk: Bool {
        locationManager.estadoAutorizacion == .authorizedAlways || locationManager.estadoAutorizacion == .authorizedWhenInUse
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color.bidealBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Tarjeta Resumen de Estado Global
                        tarjetaResumenGlobal
                        
                        // Lista de Componentes de Diagnóstico
                        VStack(spacing: 12) {
                            ItemDiagnosticoRastreador(
                                icono: "bicycle",
                                titulo: "Rastreo Pasivo Inteligente",
                                descripcion: "La app detecta automáticamente cuando pedaleas. CERO botones manuales necesarios.",
                                estado: "Activo",
                                colorEstado: BiDealTheme.primary
                            )
                            
                            ItemDiagnosticoRastreador(
                                icono: "heart.fill",
                                titulo: "Apple Health (HealthKit)",
                                descripcion: "Lectura continua de entrenamientos y distancia ciclista.",
                                estado: healthKitManager.estaAutorizado ? "Conectado" : "Pendiente",
                                colorEstado: healthKitManager.estaAutorizado ? BiDealTheme.primary : Color.orange
                            )
                            
                            ItemDiagnosticoRastreador(
                                icono: "location.fill",
                                titulo: "Servicios de Ubicación / GPS",
                                descripcion: "Precisión de alta fidelidad para verificar trayectos urbanos.",
                                estado: permisoGpsOk ? "Correcto" : "Revisar",
                                colorEstado: permisoGpsOk ? BiDealTheme.primary : Color.orange
                            )
                            
                            ItemDiagnosticoRastreador(
                                icono: "battery.100",
                                titulo: "Eficiencia de Batería",
                                descripcion: "Rastreo pasivo con impacto mínimo (<2% diario).",
                                estado: "Optimizado",
                                colorEstado: BiDealTheme.primary
                            )
                            
                            ItemDiagnosticoRastreador(
                                icono: "network",
                                titulo: "Conexión a Base de Datos",
                                descripcion: "Sincronización en vivo con Supabase Cloud.",
                                estado: "En línea",
                                colorEstado: BiDealTheme.primary
                            )
                        }
                        
                        // Botón Abrir Ajustes de iOS
                        Button(action: {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "gearshape.fill")
                                Text("Abrir Ajustes de iOS")
                                    .fontWeight(.bold)
                            }
                            .font(.system(size: 15))
                            .foregroundColor(Color.bidealDarkGreen)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.white)
                            .cornerRadius(14)
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.bidealBorder, lineWidth: 1))
                        }
                        
                        Spacer().frame(height: 30)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Estado del Rastreador")
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
    
    private var tarjetaResumenGlobal: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(red: 220/255, green: 252/255, blue: 231/255))
                    .frame(width: 64, height: 64)
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 32))
                    .foregroundColor(BiDealTheme.primary)
            }
            
            Text("Sistema de Rastreo 100% Operativo")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color.bidealDarkGreen)
                .multilineTextAlignment(.center)
            
            Text("No tienes que pulsar 'Iniciar pedaleo' ni abrir la app antes de salir. Cada vez que montes en bicicleta por Pamplona, tus kilómetros se registrarán en segundo plano.")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color.bidealSurface)
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.bidealBorder, lineWidth: 1))
    }
}

struct ItemDiagnosticoRastreador: View {
    let icono: String
    let titulo: String
    let descripcion: String
    let estado: String
    let colorEstado: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(colorEstado.opacity(0.12))
                    .frame(width: 40, height: 40)
                Image(systemName: icono)
                    .font(.system(size: 18))
                    .foregroundColor(colorEstado)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(titulo)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.primary)
                    Spacer()
                    Text(estado)
                        .font(.system(size: 11, weight: .heavy))
                        .foregroundColor(colorEstado)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(colorEstado.opacity(0.12))
                        .cornerRadius(6)
                }
                
                Text(descripcion)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(14)
        .background(Color.bidealSurface)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.bidealBorder, lineWidth: 1))
    }
}
