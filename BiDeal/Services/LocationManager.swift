import Foundation
import CoreLocation
import Combine

public final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    public static let shared = LocationManager()
    
    private let manager = CLLocationManager()
    
    @Published public var estadoAutorizacion: CLAuthorizationStatus = .notDetermined
    @Published public var estaGrabando: Bool = false
    @Published public var ubicacionActual: CLLocation?
    @Published public var distanciaKm: Double = 0.0
    @Published public var velocidadActualKmH: Double = 0.0
    @Published public var tiempoSegundos: Int = 0
    @Published public var velocidadMediaKmH: Double = 0.0
    
    private var ultimaUbicacion: CLLocation?
    private var temporizador: AnyCancellable?
    
    public override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        manager.distanceFilter = 5.0 // Actualizar cada 5 metros
        manager.activityType = .fitness
        manager.pausesLocationUpdatesAutomatically = false
        
        #if os(iOS)
        manager.allowsBackgroundLocationUpdates = true
        manager.showsBackgroundLocationIndicator = true
        #endif
    }
    
    public func solicitarPermisos() {
        manager.requestWhenInUseAuthorization()
    }
    
    public func solicitarPermisoSegundoPlano() {
        manager.requestAlwaysAuthorization()
    }
    
    public func iniciarGrabacion() {
        guard !estaGrabando else { return }
        distanciaKm = 0.0
        velocidadActualKmH = 0.0
        tiempoSegundos = 0
        velocidadMediaKmH = 0.0
        ultimaUbicacion = nil
        estaGrabando = true
        
        manager.startUpdatingLocation()
        
        temporizador = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, self.estaGrabando else { return }
                self.tiempoSegundos += 1
                if self.tiempoSegundos > 0 {
                    let horas = Double(self.tiempoSegundos) / 3600.0
                    self.velocidadMediaKmH = self.distanciaKm / horas
                }
            }
    }
    
    public func pausarGrabacion() {
        estaGrabando = false
        temporizador?.cancel()
        manager.stopUpdatingLocation()
    }
    
    public func reanudarGrabacion() {
        guard !estaGrabando else { return }
        estaGrabando = true
        manager.startUpdatingLocation()
        
        temporizador = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, self.estaGrabando else { return }
                self.tiempoSegundos += 1
                if self.tiempoSegundos > 0 {
                    let horas = Double(self.tiempoSegundos) / 3600.0
                    self.velocidadMediaKmH = self.distanciaKm / horas
                }
            }
    }
    
    public func finalizarGrabacion() -> ActividadCiclista {
        pausarGrabacion()
        
        let kmFinal = distanciaKm
        let tiempoFinal = tiempoSegundos
        let velMedia = velocidadMediaKmH
        let co2 = CO2Calculator.calcularCo2EvitadoKg(distanciaKm: kmFinal)
        let kmcoins = Int(kmFinal * 10) // 10 KmCoins por kilómetro pedaleado
        
        let actividad = ActividadCiclista(
            distanciaKm: kmFinal,
            duracionSegundos: tiempoFinal,
            velocidadMediaKmH: velMedia,
            kmcoinsGanadas: kmcoins,
            co2EvitadoKg: co2
        )
        
        return actividad
    }
    
    // MARK: - CLLocationManagerDelegate
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        estadoAutorizacion = manager.authorizationStatus
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let nuevaUbicacion = locations.last else { return }
        ubicacionActual = nuevaUbicacion
        
        guard estaGrabando else { return }
        
        // Descartar lecturas con poca precisión GPS (> 25 metros)
        guard nuevaUbicacion.horizontalAccuracy >= 0 && nuevaUbicacion.horizontalAccuracy < 25 else { return }
        
        // Velocidad en km/h
        if nuevaUbicacion.speed > 0 {
            velocidadActualKmH = nuevaUbicacion.speed * 3.6
        }
        
        if let ultima = ultimaUbicacion {
            let metros = nuevaUbicacion.distance(from: ultima)
            let tiempoDelta = nuevaUbicacion.timestamp.timeIntervalSince(ultima.timestamp)
            
            if tiempoDelta > 0 {
                let velEstimadaKmH = (metros / tiempoDelta) * 3.6
                // Filtro ciclista inteligente: validar velocidades realistas (entre 3 y 38 km/h)
                if velEstimadaKmH >= 3.0 && velEstimadaKmH <= 40.0 {
                    distanciaKm += metros / 1000.0
                }
            }
        }
        
        ultimaUbicacion = nuevaUbicacion
    }
}
