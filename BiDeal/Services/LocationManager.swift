import Foundation
import CoreLocation
import CoreMotion
import Combine
import UserNotifications

/// Gestor de Ubicación y Reconocimiento de Actividad Física (CoreLocation + CoreMotion)
/// Paridad 1:1 con BicycleTrackingService de Android:
/// - Muestreo GPS de alta precisión a intervalos de 3 segundos
/// - Detección automática de ciclismo con CMMotionActivityManager (.cycling vs .automotive)
/// - Acumulación y empaquetado seguro en lotes cada 5 minutos hacia POST /api/calcular_ruta
/// - Prevención de trampas y cálculo exclusivo en servidor Vercel
public final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    public static let shared = LocationManager()
    
    // MARK: - Managers del Sistema
    private let locationManager = CLLocationManager()
    private let motionActivityManager = CMMotionActivityManager()
    private let motionQueue = OperationQueue()
    
    // MARK: - Estado Publicado (UI)
    @Published public var estadoAutorizacion: CLAuthorizationStatus = .notDetermined
    @Published public var estaGrabando: Bool = false
    @Published public var ubicacionActual: CLLocation?
    @Published public var distanciaKm: Double = 0.0
    @Published public var velocidadActualKmH: Double = 0.0
    @Published public var tiempoSegundos: Int = 0
    @Published public var velocidadMediaKmH: Double = 0.0
    @Published public var saldoKmCoinsConfirmado: Int = 0
    @Published public var actividadDetectada: String = "ON_BICYCLE"
    @Published public var confianzaActividad: Int = 85
    @Published public var puntosEnBuffer: Int = 0
    @Published public var ultimoError: String?
    
    // MARK: - Almacenamiento Interno de Puntos y Temporizadores
    private var listaPuntosLocal: [PuntoRuta] = []
    private let queueLote = DispatchQueue(label: "org.bideal.puntosQueue", attributes: .concurrent)
    
    private var ultimaUbicacionValida: CLLocation?
    private var temporizadorCronometro: AnyCancellable?
    private var temporizadorMuestreo3s: Timer?
    private var temporizadorEnvioLotes5m: Timer?
    
    private let intervaloMuestreoSegundos: TimeInterval = 3.0
    private let intervaloEnvioLotesSegundos: TimeInterval = 300.0 // 5 minutos
    
    public override init() {
        super.init()
        configurarLocationManager()
        solicitarPermisoNotificaciones()
        iniciarDeteccionMovimientoCoreMotion()
    }
    
    // MARK: - Configuración Inicial
    private func configurarLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 3.0 // Actualizar ante movimiento sensible
        locationManager.activityType = .fitness
        locationManager.pausesLocationUpdatesAutomatically = false
        
        #if os(iOS)
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.showsBackgroundLocationIndicator = true
        #endif
    }
    
    private func solicitarPermisoNotificaciones() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            if granted {
                print("🔔 Notificaciones locales de BiDeal autorizadas")
            }
        }
    }
    
    // MARK: - CoreMotion: Detección Automática de Ciclismo (Equivalente ActivityRecognition)
    private func iniciarDeteccionMovimientoCoreMotion() {
        guard CMMotionActivityManager.isActivityAvailable() else {
            print("⚠️ CoreMotion no disponible en este dispositivo (simulador o hardware antiguo)")
            return
        }
        
        motionActivityManager.startActivityUpdates(to: motionQueue) { [weak self] activity in
            guard let self = self, let activity = activity else { return }
            
            DispatchQueue.main.async {
                let confianza: Int
                switch activity.confidence {
                case .high: confianza = 95
                case .medium: confianza = 75
                case .low: confianza = 50
                @unknown default: confianza = 70
                }
                
                self.confianzaActividad = confianza
                
                if activity.cycling {
                    self.actividadDetectada = "ON_BICYCLE"
                } else if activity.automotive {
                    self.actividadDetectada = "IN_VEHICLE"
                } else if activity.walking {
                    self.actividadDetectada = "WALKING"
                } else if activity.running {
                    self.actividadDetectada = "RUNNING"
                } else if activity.stationary {
                    self.actividadDetectada = "STILL"
                } else {
                    self.actividadDetectada = "UNKNOWN"
                }
            }
        }
    }
    
    // MARK: - Permisos de Ubicación
    public func solicitarPermisos() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    public func solicitarPermisoSegundoPlano() {
        locationManager.requestAlwaysAuthorization()
    }
    
    // MARK: - Control de Grabación de Ruta
    public func iniciarGrabacion() {
        guard !estaGrabando else { return }
        
        distanciaKm = 0.0
        velocidadActualKmH = 0.0
        tiempoSegundos = 0
        velocidadMediaKmH = 0.0
        ultimaUbicacionValida = nil
        ultimoError = nil
        
        queueLote.async(flags: .barrier) {
            self.listaPuntosLocal.removeAll()
            DispatchQueue.main.async { self.puntosEnBuffer = 0 }
        }
        
        estaGrabando = true
        locationManager.startUpdatingLocation()
        
        // Cronómetro en UI cada 1s
        temporizadorCronometro = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, self.estaGrabando else { return }
                self.tiempoSegundos += 1
                if self.tiempoSegundos > 0 {
                    let horas = Double(self.tiempoSegundos) / 3600.0
                    self.velocidadMediaKmH = self.distanciaKm / horas
                }
            }
        
        // Muestreador GPS continuo cada 3 segundos (paridad fija con Android)
        iniciarTemporizadorMuestreo()
        
        // Temporizador de envío por lotes cada 5 minutos
        iniciarTemporizadorLotes()
        
        print("🚴‍♂️ Grabación de ruta iniciada con CoreLocation y CoreMotion activos")
    }
    
    public func pausarGrabacion() {
        estaGrabando = false
        temporizadorCronometro?.cancel()
        temporizadorMuestreo3s?.invalidate()
        temporizadorMuestreo3s = nil
        locationManager.stopUpdatingLocation()
    }
    
    public func reanudarGrabacion() {
        guard !estaGrabando else { return }
        estaGrabando = true
        locationManager.startUpdatingLocation()
        
        temporizadorCronometro = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, self.estaGrabando else { return }
                self.tiempoSegundos += 1
                if self.tiempoSegundos > 0 {
                    let horas = Double(self.tiempoSegundos) / 3600.0
                    self.velocidadMediaKmH = self.distanciaKm / horas
                }
            }
        
        iniciarTemporizadorMuestreo()
        iniciarTemporizadorLotes()
    }
    
    public func finalizarGrabacion() {
        pausarGrabacion()
        temporizadorEnvioLotes5m?.invalidate()
        temporizadorEnvioLotes5m = nil
        
        // Enviar inmediatamente todos los puntos acumulados pendientes
        Task {
            await enviarLoteAcumuladoAlServidor(esFinalDeRuta: true)
        }
    }
    
    // MARK: - Muestreo Cada 3 Segundos
    private func iniciarTemporizadorMuestreo() {
        temporizadorMuestreo3s?.invalidate()
        temporizadorMuestreo3s = Timer.scheduledTimer(withTimeInterval: intervaloMuestreoSegundos, repeats: true) { [weak self] _ in
            self?.capturarPuntoActual()
        }
    }
    
    private func capturarPuntoActual() {
        guard estaGrabando, let loc = ubicacionActual else { return }
        
        // Descartar lecturas satelitales con poca precisión (> 25 metros)
        guard loc.horizontalAccuracy >= 0 && loc.horizontalAccuracy <= 25.0 else { return }
        
        // Si CoreMotion detecta que el usuario está en coche/autobús con alta certeza, no sumar puntos de trampa
        if actividadDetectada == "IN_VEHICLE" && confianzaActividad >= 80 {
            print("🚗 Desplazamiento en vehículo detectado por CoreMotion. Punto descartado.")
            return
        }
        
        let velKmh = loc.speed >= 0 ? loc.speed * 3.6 : nil
        
        let nuevoPunto = PuntoRuta(
            timestamp: Int64(loc.timestamp.timeIntervalSince1970 * 1000),
            latitud: loc.coordinate.latitude,
            longitud: loc.coordinate.longitude,
            precision_metros: loc.horizontalAccuracy > 0 ? loc.horizontalAccuracy : 5.0,
            velocidad_kmh: velKmh,
            actividad: actividadDetectada,
            confianza: confianzaActividad
        )
        
        queueLote.async(flags: .barrier) {
            self.listaPuntosLocal.append(nuevoPunto)
            let total = self.listaPuntosLocal.count
            DispatchQueue.main.async {
                self.puntosEnBuffer = total
            }
        }
    }
    
    // MARK: - Temporizador y Envío en Lotes (POST /api/calcular_ruta)
    private func iniciarTemporizadorLotes() {
        temporizadorEnvioLotes5m?.invalidate()
        temporizadorEnvioLotes5m = Timer.scheduledTimer(withTimeInterval: intervaloEnvioLotesSegundos, repeats: true) { [weak self] _ in
            Task { [weak self] in
                await self?.enviarLoteAcumuladoAlServidor(esFinalDeRuta: false)
            }
        }
    }
    
    public func enviarLoteAcumuladoAlServidor(esFinalDeRuta: Bool) async {
        guard SupabaseService.shared.isAuthenticated else {
            print("ℹ️ Usuario no autenticado en Supabase. Esperando sesión para enviar lote.")
            return
        }
        
        var puntosAEnviar: [PuntoRuta] = []
        queueLote.sync {
            puntosAEnviar = self.listaPuntosLocal
        }
        
        guard !puntosAEnviar.isEmpty else {
            print("ℹ️ Buffer GPS vacío, no hay puntos pendientes de envío.")
            return
        }
        
        print("🚀 Enviando lote de \(puntosAEnviar.count) puntos GPS a Vercel (/api/calcular_ruta)...")
        
        let resultado = await ApiClient.shared.enviarLoteRuta(puntos: puntosAEnviar)
        
        switch resultado {
        case .success(let resp):
            print("✅ Lote validado por servidor: +\(resp.distanciaSumadaKm) km, +\(resp.kmcoinsGanadas) KmCoins (Saldo Total: \(resp.saldoActualKmcoins))")
            
            // Vaciar del buffer los puntos que ya fueron procesados con éxito
            queueLote.async(flags: .barrier) {
                self.listaPuntosLocal.removeAll()
                DispatchQueue.main.async {
                    self.puntosEnBuffer = 0
                    self.saldoKmCoinsConfirmado = resp.saldoActualKmcoins
                    if resp.distanciaSumadaKm > 0 {
                        self.distanciaKm += resp.distanciaSumadaKm
                    }
                }
            }
            
            // Enviar notificación local si se ganaron monedas y la app está en segundo plano
            if resp.kmcoinsGanadas > 0 {
                dispararNotificacionRecompensa(kmcoins: resp.kmcoinsGanadas, distanciaKm: resp.distanciaSumadaKm)
            }
            
        case .failure(let error):
            print("❌ Error al enviar lote GPS a Vercel: \(error.localizedDescription). Los puntos se mantienen en buffer para reintento.")
            DispatchQueue.main.async {
                self.ultimoError = error.localizedDescription
            }
        }
    }
    
    private func dispararNotificacionRecompensa(kmcoins: Int, distanciaKm: Double) {
        let content = UNMutableNotificationContent()
        content.title = "🎉 ¡Pedaleo Recompensado!"
        content.body = String(format: "Has ganado +%d KmCoins tras recorrer %.2f km en bicicleta.", kmcoins, distanciaKm)
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - CLLocationManagerDelegate
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.estadoAutorizacion = manager.authorizationStatus
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let nuevaUbicacion = locations.last else { return }
        
        DispatchQueue.main.async {
            self.ubicacionActual = nuevaUbicacion
        }
        
        guard estaGrabando else { return }
        
        // Filtrar ubicaciones con mala precisión (> 25 metros)
        guard nuevaUbicacion.horizontalAccuracy >= 0 && nuevaUbicacion.horizontalAccuracy <= 25.0 else { return }
        
        DispatchQueue.main.async {
            if nuevaUbicacion.speed >= 0 {
                self.velocidadActualKmH = nuevaUbicacion.speed * 3.6
            }
            
            if let ultima = self.ultimaUbicacionValida {
                let metros = nuevaUbicacion.distance(from: ultima)
                let tiempoDelta = nuevaUbicacion.timestamp.timeIntervalSince(ultima.timestamp)
                
                if tiempoDelta > 0 {
                    let velEstimadaKmH = (metros / tiempoDelta) * 3.6
                    // Validación en vivo: velocidad ciclista entre 2.5 y 45 km/h
                    if velEstimadaKmH >= 2.5 && velEstimadaKmH <= 45.0 {
                        self.distanciaKm += metros / 1000.0
                    }
                }
            }
            
            self.ultimaUbicacionValida = nuevaUbicacion
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("⚠️ Error en CoreLocation: \(error.localizedDescription)")
    }
}
