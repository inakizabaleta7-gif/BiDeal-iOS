# 🚴 BiDeal iOS (Pamplona)

Aplicación móvil nativa para iPhone desarrollada en **Swift y SwiftUI**. Transforma tus kilómetros pedaleados en Pamplona y su comarca en **KmCoins**, puntos canjeables por promociones y descuentos en comercios locales de barrio.

---

## 🌟 Características Principales

* **Seguimiento Ciclista Inteligente (CoreLocation)**:
  - Medición continua de trayectos mediante GPS nativo en primer y segundo plano (`UIBackgroundModes: location`).
  - Validación de patrones de velocidad realista de ciclismo urbano (5 a 35 km/h) para asegurar desplazamientos sostenibles reales.
* **Huella Positiva y CO₂ Evitado**:
  - Cálculo instantáneo del impacto medioambiental: gramos de CO₂ no emitidos, combustible ahorrado y absorción equivalente en pinos adultos.
* **Mapa Interactivo de Comercios (MapKit)**:
  - Visualización en tiempo real de los comercios y talleres ciclistas adheridos en Pamplona (Iturrama, Ensanche, Casco Antiguo, San Juan, Rochapea, etc.).
  - Sincronización directa con la base de datos de **Supabase** (`wtfwkwmvczzyrgdamkpk`).
  - Ruta directa *"Cómo llegar en bici"* mediante Apple Maps / Google Maps.
* **Liga de Amigos (Retos Grupales)**:
  - Creación de grupetas de **2 a 20 ciclistas**.
  - Pique amistoso y clasificación semanal actualizada en tiempo real.
  - **Doble recompensa semanal**:
    - 🥇 **+25 KmCoins** para el líder de la semana al cierre del domingo.
    - 🤝 **Meta cooperativa 200 km**: ¡Si toda la grupeta suma 200 km semanales, **todos ganan +10 KmCoins**!
  - Invitación en 1 toque por WhatsApp con código exclusivo.
* **Canje en Mostrador**:
  - Generación de código QR y lector de cámara para canjear en segundos en los comercios de proximidad.

---

## 🛠️ Arquitectura Técnica

* **Lenguaje**: Swift 5.9+
* **Interfaz**: SwiftUI + Combine
* **Mapeo**: MapKit nativo
* **Geolocalización**: CoreLocation (`CLLocationManager`) con filtros de batería
* **Backend**: Supabase (PostgREST, Auth)
* **Compatibilidad**: iOS 16.0 o superior (iPhone)

---

## 📲 Cómo Instalar y Probar en tu iPhone (100% Gratis sin cuenta de pago)

Para instalar la aplicación en tu iPhone desde un ordenador con Windows sin pagar la cuota de Apple:

1. **Descargar el archivo `.ipa`**:
   - Ve a la pestaña **Actions** de este repositorio de GitHub.
   - Pulsa en la última ejecución exitosa del flujo `Build iOS IPA` y descarga el archivo comprimido con el instalador `BiDeal.ipa`.
2. **Instalar Sideloadly en tu PC**:
   - Descarga e instala [Sideloadly](https://sideloadly.io/) en tu Windows (es gratuita y segura).
   - Asegúrate de tener iTunes o iCloud instalado en el PC para la conexión USB.
3. **Transferir al iPhone**:
   - Conecta tu iPhone al PC con el cable USB y desbloquéalo (pulsa *"Confiar en este ordenador"* si te lo pide).
   - Abre Sideloadly, arrastra el archivo `BiDeal.ipa` a la ventana.
   - Introduce tu Apple ID estándar (tu cuenta gratuita normal de Apple).
   - Pulsa **Start**.
4. **Abrir en tu iPhone**:
   - En 30 segundos verás el icono verde de **BiDeal** en tu pantalla de inicio.
   - La primera vez, ve en tu iPhone a: `Ajustes > General > Gestión de VPN y dispositivos > [Tu Apple ID]` y pulsa **"Confiar"**.
   - ¡Listo! Abre BiDeal y empieza a sumar KmCoins pedaleando por Pamplona.
