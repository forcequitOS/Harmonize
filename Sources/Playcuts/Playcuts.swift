import SwiftUI
import Swifter

public class Playcuts: ObservableObject {
    @AppStorage("pairingCode") private var storedPairingCode: Int = 0
    @Published public var isRunning = false
    @Published public var receivedDisplayData: String = ""
    @Published public var isPairingCodeVisible = false
    
    private var server: HttpServer?
    private var pairingCode: Int {
        get { storedPairingCode }
        set { storedPairingCode = newValue }
    }
    
    public init() {
        // Generate a new pairing code if it hasn't been generated yet
        if pairingCode == 0 {
            resetPairingCode()
        }
    }
    
    public func start() {
        guard server == nil else { return } // Server already running
        
        let server = HttpServer()
        server.listenAddressIPv4 = "127.0.0.1"
        let port: UInt16 = 6996
        
        server["/"] = { request in
            guard let jsonData = Data(request.body) as? Data,
                  let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
                return HttpResponse.badRequest(.text("Invalid JSON"))
            }
            
            guard let authCode = json["auth"] as? Int else {
                print("No pairing code detected.")
                return HttpResponse.badRequest(.text("Your request is missing a pairing code."))
            }
            
            let verification = json["verification"] as? Bool
            let display = json["display"] as? String
            
            if authCode == self.pairingCode {
                if verification == true {
                    print("Successfully authenticated!")
                    return HttpResponse.ok(.text("Success"))
                } else if verification == nil {
                    if let displayData = display {
                        print("Received: \(json)")
                        DispatchQueue.main.async {
                            self.receivedDisplayData = displayData
                        }
                        return HttpResponse.ok(.text("Request received successfully!"))
                    } else {
                        print("Received: \(json)")
                        return HttpResponse.badRequest(.text("Request received but no 'display' key found."))
                    }
                }
            } else {
                print("Invalid pairing code.")
                return HttpResponse.badRequest(.text("Your pairing code is incorrect."))
            }
            
            return HttpResponse.badRequest(.text("Invalid request!"))
        }
        
        do {
            try server.start(port, forceIPv4: true)
            print("Server initialized successfully on port \(port)!")
            self.server = server
            DispatchQueue.main.async {
                self.isRunning = true
                self.displayPairingCode()
            }
        } catch {
            print("Server initialization error: \(error)")
        }
    }
    
    public func stop() {
        server?.stop()
        server = nil
        DispatchQueue.main.async {
            self.isRunning = false
        }
        print("Server has stopped")
    }
    
    public func displayPairingCode() {
        withAnimation {
            isPairingCodeVisible = true
        }
    }
    
    public func dismissPairingCode() {
        withAnimation {
            isPairingCodeVisible = false
        }
    }
    
    public func resetPairingCode() {
        pairingCode = Int.random(in: 1...9999)
        displayPairingCode()
    }
}

public struct PairingCodeOverlay: View {
    let pairingCode: String
    let onDismiss: () -> Void
    
    public init(pairingCode: String, onDismiss: @escaping () -> Void) {
        self.pairingCode = pairingCode
        self.onDismiss = onDismiss
    }
    
    public var body: some View {
        ZStack {
            VisualEffectBlur(style: .systemUltraThinMaterial)
            
            VStack(spacing: 20) {
                Text("Pairing Code")
                    .font(.system(.largeTitle))
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                
                Text("Shortcuts Setup")
                    .font(.system(.title2))
                    .frame(maxWidth: .infinity)
                
                HStack(spacing: 15) {
                    ForEach(pairingCode.map { String($0) }, id: \.self) { digit in
                        Text(digit)
                            .font(.system(size: 50, weight: .medium, design: .monospaced))
                            .frame(width: 60, height: 80)
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(10)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .edgesIgnoringSafeArea(.all)
        .onTapGesture {
            onDismiss()
        }
        .transition(.opacity)
    }
}

public struct VisualEffectBlur: UIViewRepresentable {
    public var style: UIBlurEffect.Style = .systemMaterial
    
    public func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    
    public func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}
