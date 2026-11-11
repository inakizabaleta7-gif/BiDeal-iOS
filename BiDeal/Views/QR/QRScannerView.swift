import SwiftUI
import AVFoundation
import UIKit

// MARK: - Vista Principal del Escáner QR de BiDeal
public struct QRScannerView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authVM: AuthViewModel
    
    @State private var hasCameraPermission: Bool = false
    @State private var isProcessing: Bool = false
    @State private var torchActive: Bool = false
    @State private var errorMensaje: String?
    
    // Datos recibidos del backend tras escanear
    @State private var scannedQRData: RespuestaEscaneoQR?
    @State private var showBottomSheet: Bool = false
    
    // Estados de confirmación y resultado del canje
    @State private var descuentoAConfirmar: DescuentoDto?
    @State private var resultadoCanjeExitoso: RespuestaCanje?
    @State private var descuentoCanjeadoUltimo: DescuentoDto?
    
    // Fallback manual
    @State private var mostrarInputManual: Bool = false
    @State private var codigoManual: String = ""
    
    // Animación de escaneo láser
    @State private var scanLineOffset: CGFloat = -110
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ZStack {
                Color.bidealBackground.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header de navegación personalizado
                    headerView
                    
                    if hasCameraPermission {
                        // Visor de Cámara con Retícula y Láser
                        ZStack {
                            CameraPreviewRepresentable(torchActive: $torchActive) { scannedCode in
                                handleScannedCode(scannedCode)
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(Color.bidealOutline, lineWidth: 1.5)
                            )
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            
                            // Marco guía del QR
                            reticulaGuiaView
                        }
                        .frame(maxHeight: .infinity)
                    } else {
                        // Estado sin permisos de cámara
                        permisoCamaraRequeridoView
                            .frame(maxHeight: .infinity)
                    }
                    
                    // Controles Inferiores (Linterna y Código Manual)
                    bottomControlsView
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                }
                
                // Indicador de Carga sobrepuesto
                if isProcessing {
                    ZStack {
                        Color.black.opacity(0.45).ignoresSafeArea()
                        VStack(spacing: 12) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.4)
                            Text("Validando comercio...")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .padding(24)
                        .background(Color.bidealSurface)
                        .cornerRadius(16)
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                checkCameraPermission()
                iniciarAnimacionLaser()
            }
            // Sheet de Descuentos del Comercio
            .sheet(isPresented: $showBottomSheet) {
                if let data = scannedQRData {
                    ModalDescuentosComercioView(
                        data: data,
                        onSelectDescuento: { desc in
                            descuentoAConfirmar = desc
                        }
                    )
                }
            }
            // Alerta de confirmación previa al canje
            .alert(item: $descuentoAConfirmar) { desc in
                Alert(
                    title: Text("Confirmar Canje"),
                    message: Text("¿Deseas canjear '\(desc.titulo)' en \(scannedQRData?.comercio.nombre ?? "el comercio") por \(desc.precioKmcoins) KmCoins?"),
                    primaryButton: .default(Text("Confirmar"), action: {
                        ejecutarCanje(descuento: desc)
                    }),
                    secondaryButton: .cancel(Text("Cancelar"))
                )
            }
            // Modal de Éxito y Código de Canje
            .sheet(item: $resultadoCanjeExitoso) { canje in
                ModalExitoCanjeView(
                    resultado: canje,
                    descuento: descuentoCanjeadoUltimo,
                    comercioNombre: scannedQRData?.comercio.nombre ?? "Comercio Asociado",
                    onDismiss: {
                        resultadoCanjeExitoso = nil
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            }
            // Alerta de Errores
            .alert(isPresented: Binding<Bool>(
                get: { errorMensaje != nil },
                set: { if !$0 { errorMensaje = nil } }
            )) {
                Alert(
                    title: Text("Aviso de BiDeal"),
                    message: Text(errorMensaje ?? "Ha ocurrido un error inesperado."),
                    dismissButton: .default(Text("Entendido"))
                )
            }
            // Modal de Entrada Manual de Código
            .sheet(isPresented: $mostrarInputManual) {
                modalInputManualView
            }
        }
    }
    
    // MARK: - Subvistas
    
    private var headerView: some View {
        HStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 26))
                    .foregroundColor(Color.bidealTextSecondary)
            }
            
            Spacer()
            
            Text("Escanear Comercio")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color.bidealTextPrimary)
            
            Spacer()
            
            // Botón de Linterna (Torch)
            Button(action: {
                toggleTorch()
            }) {
                Image(systemName: torchActive ? "flashlight.on.fill" : "flashlight.off.fill")
                    .font(.system(size: 22))
                    .foregroundColor(torchActive ? Color.bidealAccentGold : Color.bidealTextSecondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }
    
    private var reticulaGuiaView: some View {
        ZStack {
            // Marco cuadrado de escaneo
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.bidealPrimary, lineWidth: 3)
                .frame(width: 240, height: 240)
            
            // Esquinas visuales decorativas
            VStack {
                HStack {
                    Image(systemName: "viewfinder")
                        .font(.system(size: 40))
                        .foregroundColor(Color.bidealPrimary)
                        .opacity(0.8)
                    Spacer()
                }
                Spacer()
            }
            .frame(width: 260, height: 260)
            
            // Línea láser animada de arriba hacia abajo
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.clear, Color.bidealPrimary, Color.clear]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 220, height: 3)
                .offset(y: scanLineOffset)
        }
    }
    
    private var bottomControlsView: some View {
        VStack(spacing: 12) {
            Text("Apunta con la cámara al código QR ubicado en el mostrador del establecimiento.")
                .font(.system(size: 13, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundColor(Color.bidealTextSecondary)
                .padding(.horizontal, 16)
            
            Button(action: {
                mostrarInputManual = true
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "keyboard")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Introducir código manualmente")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(Color.bidealPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.bidealSurfaceVariant)
                .cornerRadius(12)
            }
        }
    }
    
    private var permisoCamaraRequeridoView: some View {
        VStack(spacing: 16) {
            Image(systemName: "camera.badge.ellipsis")
                .font(.system(size: 54))
                .foregroundColor(Color.bidealPrimary)
            
            Text("Permiso de Cámara Requerido")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color.bidealTextPrimary)
            
            Text("Para validar las peanas y carteles QR de los comercios colaboradores de Pamplona, BiDeal necesita acceso a tu cámara.")
                .font(.system(size: 14))
                .multilineTextAlignment(.center)
                .foregroundColor(Color.bidealTextSecondary)
                .padding(.horizontal, 32)
            
            Button(action: {
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            }) {
                Text("Abrir Ajustes de iOS")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.bidealPrimary)
                    .cornerRadius(12)
            }
        }
        .padding(24)
    }
    
    private var modalInputManualView: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Introduce el identificador del código QR que figura impreso bajo el recuadro óptico.")
                    .font(.system(size: 14))
                    .foregroundColor(Color.bidealTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 16)
                
                TextField("Ej: BIDEAL-MUNDORAIN-01", text: $codigoManual)
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .autocapitalization(.allCharacters)
                    .disableAutocorrection(true)
                    .padding(14)
                    .background(Color.bidealSurfaceVariant)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.bidealOutline, lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                
                Button(action: {
                    let cod = codigoManual.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !cod.isEmpty {
                        mostrarInputManual = false
                        handleScannedCode(cod)
                    }
                }) {
                    Text("Validar Código")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(codigoManual.isEmpty ? Color.gray : Color.bidealPrimary)
                        .cornerRadius(12)
                }
                .disabled(codigoManual.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .navigationTitle("Código Manual")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Cerrar") {
                mostrarInputManual = false
            })
        }
    }
    
    // MARK: - Lógica de Negocio y Comunicación con Backend
    
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            hasCameraPermission = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    self.hasCameraPermission = granted
                }
            }
        default:
            hasCameraPermission = false
        }
    }
    
    private func iniciarAnimacionLaser() {
        withAnimation(Animation.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
            scanLineOffset = 110
        }
    }
    
    private func toggleTorch() {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        do {
            try device.lockForConfiguration()
            device.torchMode = torchActive ? .off : .on
            torchActive.toggle()
            device.unlockForConfiguration()
        } catch {
            print("⚠️ No se pudo cambiar el estado de la linterna: \(error.localizedDescription)")
        }
    }
    
    private func limpiarCodigoQr(_ raw: String) -> String {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.contains("/qr/") {
            return String(trimmed.components(separatedBy: "/qr/").last ?? trimmed)
        } else if trimmed.contains("/") {
            return String(trimmed.components(separatedBy: "/").last ?? trimmed)
        }
        return trimmed
    }
    
    private func handleScannedCode(_ rawCode: String) {
        guard !isProcessing && !showBottomSheet && resultadoCanjeExitoso == nil else { return }
        let limpio = limpiarCodigoQr(rawCode)
        guard !limpio.isEmpty else { return }
        
        isProcessing = true
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        Task {
            let res = await ApiClient.shared.escanearQr(codigo: limpio)
            await MainActor.run {
                self.isProcessing = false
                switch res {
                case .success(let data):
                    self.scannedQRData = data
                    self.showBottomSheet = true
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                case .failure(let err):
                    self.errorMensaje = "Comercio no reconocido o QR no registrado en BiDeal."
                    print("❌ Error escaneando QR: \(err.localizedDescription)")
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                }
            }
        }
    }
    
    private func ejecutarCanje(descuento: DescuentoDto) {
        isProcessing = true
        
        Task {
            let res = await ApiClient.shared.canjearDescuento(
                descuentoId: descuento.id,
                comercioId: scannedQRData?.comercio.id
            )
            
            await MainActor.run {
                self.isProcessing = false
                switch res {
                case .success(let canje):
                    self.showBottomSheet = false
                    self.descuentoCanjeadoUltimo = descuento
                    self.resultadoCanjeExitoso = canje
                    
                    if let restante = canje.kmcoinsRestantes {
                        self.authVM.currentUser?.kmcoinsBalance = restante
                        self.authVM.kmcoinsBalance = restante
                    }
                    
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    
                case .failure(let err):
                    self.errorMensaje = err.localizedDescription
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                }
            }
        }
    }
}

// MARK: - UIViewControllerRepresentable para Captura Óptica de AVFoundation
struct CameraPreviewRepresentable: UIViewControllerRepresentable {
    @Binding var torchActive: Bool
    var onCodeFound: (String) -> Void
    
    func makeUIViewController(context: Context) -> CameraScannerViewController {
        let controller = CameraScannerViewController()
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: CameraScannerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onCodeFound: onCodeFound)
    }
    
    class Coordinator: NSObject, CameraScannerDelegate {
        var onCodeFound: (String) -> Void
        init(onCodeFound: @escaping (String) -> Void) {
            self.onCodeFound = onCodeFound
        }
        func didFindCode(_ code: String) {
            onCodeFound(code)
        }
    }
}

protocol CameraScannerDelegate: AnyObject {
    func didFindCode(_ code: String)
}

class CameraScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    weak var delegate: CameraScannerDelegate?
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupCamera()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.layer.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if captureSession?.isRunning == false {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession?.startRunning()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if captureSession?.isRunning == true {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession?.stopRunning()
            }
        }
    }
    
    private func setupCamera() {
        let session = AVCaptureSession()
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            return
        }
        session.addInput(input)
        
        let metadataOutput = AVCaptureMetadataOutput()
        guard session.canAddOutput(metadataOutput) else { return }
        session.addOutput(metadataOutput)
        
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        metadataOutput.metadataObjectTypes = [.qr]
        
        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(preview)
        
        self.previewLayer = preview
        self.captureSession = session
        
        DispatchQueue.global(qos: .userInitiated).async {
            session.startRunning()
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
           let stringValue = metadataObject.stringValue {
            delegate?.didFindCode(stringValue)
        }
    }
}

// MARK: - Modal de Catálogo de Descuentos del Comercio
struct ModalDescuentosComercioView: View {
    let data: RespuestaEscaneoQR
    var onSelectDescuento: (DescuentoDto) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Cabecera del Comercio
            VStack(spacing: 8) {
                Capsule()
                    .fill(Color.bidealOutline)
                    .frame(width: 40, height: 5)
                    .padding(.top, 12)
                
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.bidealPrimary.opacity(0.15))
                            .frame(width: 48, height: 48)
                        Image(systemName: "storefront.fill")
                            .font(.system(size: 22))
                            .foregroundColor(Color.bidealPrimary)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(data.comercio.nombre)
                            .font(.system(size: 19, weight: .bold))
                            .foregroundColor(Color.bidealTextPrimary)
                        
                        if let dir = data.comercio.direccion {
                            Text(dir)
                                .font(.system(size: 13))
                                .foregroundColor(Color.bidealTextSecondary)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                
                // Chip de Saldo Disponible
                HStack {
                    Text("Tu Saldo Actual:")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color.bidealTextSecondary)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Text("Ⓚ")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Color.bidealAccentGold)
                        Text("\(data.saldoUsuarioKmcoins) KmCoins")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color.bidealTextPrimary)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.bidealSurfaceVariant)
                    .cornerRadius(8)
                }
                .padding(.horizontal, 20)
                .padding(.top, 4)
            }
            .padding(.bottom, 12)
            
            Divider()
                .background(Color.bidealOutline)
            
            // Lista de Descuentos
            ScrollView {
                VStack(spacing: 12) {
                    if data.descuentos.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "tag.slash")
                                .font(.system(size: 36))
                                .foregroundColor(Color.bidealTextSecondary)
                            Text("No hay promociones activas en este momento.")
                                .font(.system(size: 14))
                                .foregroundColor(Color.bidealTextSecondary)
                        }
                        .padding(.vertical, 40)
                    } else {
                        ForEach(data.descuentos) { desc in
                            ItemDescuentoCanjeableView(
                                descuento: desc,
                                saldoDisponible: data.saldoUsuarioKmcoins,
                                onCanjear: {
                                    onSelectDescuento(desc)
                                }
                            )
                        }
                    }
                }
                .padding(20)
            }
        }
        .background(Color.bidealBackground.ignoresSafeArea())
    }
}

// MARK: - Tarjeta Individual de Descuento
struct ItemDescuentoCanjeableView: View {
    let descuento: DescuentoDto
    let saldoDisponible: Int
    var onCanjear: () -> Void
    
    var saldoSuficiente: Bool {
        saldoDisponible >= descuento.precioKmcoins
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(descuento.titulo)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color.bidealTextPrimary)
                    
                    if !descuento.descripcion.isEmpty {
                        Text(descuento.descripcion)
                            .font(.system(size: 13))
                            .foregroundColor(Color.bidealTextSecondary)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                // Píldora de Precio
                HStack(spacing: 4) {
                    Text("Ⓚ")
                        .font(.system(size: 13, weight: .black))
                        .foregroundColor(Color.bidealAccentGold)
                    Text("\(descuento.precioKmcoins)")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color.bidealTextPrimary)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.bidealGoldLight.opacity(0.3))
                .cornerRadius(6)
            }
            
            HStack {
                if !saldoSuficiente {
                    Text("Te faltan \(descuento.precioKmcoins - saldoDisponible) KmCoins")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.red.opacity(0.8))
                }
                
                Spacer()
                
                Button(action: onCanjear) {
                    Text("Canjear")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(saldoSuficiente ? Color.bidealPrimary : Color.gray.opacity(0.5))
                        .cornerRadius(8)
                }
                .disabled(!saldoSuficiente)
            }
        }
        .padding(14)
        .background(Color.bidealSurface)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.bidealOutline, lineWidth: 1)
        )
    }
}

// MARK: - Modal de Éxito de Canje
struct ModalExitoCanjeView: View {
    let resultado: RespuestaCanje
    let descuento: DescuentoDto?
    let comercioNombre: String
    var onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.bidealPrimary.opacity(0.15))
                    .frame(width: 84, height: 84)
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 46))
                    .foregroundColor(Color.bidealPrimary)
            }
            
            Text("¡Canje Realizado!")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color.bidealTextPrimary)
            
            Text("Muestra este código al personal de **\(comercioNombre)** en el momento del pago:")
                .font(.system(size: 14))
                .multilineTextAlignment(.center)
                .foregroundColor(Color.bidealTextSecondary)
                .padding(.horizontal, 24)
            
            // Cupón Destacado
            if !resultado.codigoCanje.isEmpty {
                let cod = resultado.codigoCanje
                VStack(spacing: 6) {
                    Text(cod)
                        .font(.system(size: 28, weight: .black, design: .monospaced))
                        .foregroundColor(Color.bidealPrimary)
                        .tracking(3)
                    
                    Text("Código único intransferible")
                        .font(.system(size: 11))
                        .foregroundColor(Color.bidealTextSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(Color.bidealSurfaceVariant)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.bidealPrimary, style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                )
                .padding(.horizontal, 32)
            }
            
            if let saldo = resultado.kmcoinsRestantes {
                Text("Nuevo saldo disponible: **\(saldo) KmCoins**")
                    .font(.system(size: 14))
                    .foregroundColor(Color.bidealTextPrimary)
            }
            
            Spacer()
            
            Button(action: onDismiss) {
                Text("Aceptar y Salir")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.bidealPrimary)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(Color.bidealBackground.ignoresSafeArea())
    }
}
