import SwiftUI
import Swifter

public struct PlaycutsConfiguration {
    public var port: UInt16

    public init(port: UInt16 = 6996) {
        self.port = port
    }
}

public class Playcuts: ObservableObject {
    public static let shared = Playcuts()

    @AppStorage("pairingCode") public var pairingCode: Int = 0
    public var server: HttpServer?
    public var isRunning = false
    @Published public var receivedDisplayData: String = ""
    @Published public var isPairingCodeVisible = false
    @Published public var showingResetAlert = false

    // Change initializer to public
    public init() {}

    public func start(configuration: PlaycutsConfiguration = PlaycutsConfiguration()) {
        guard !isRunning else { return }
        let server = HttpServer()
        server.listenAddressIPv4 = "127.0.0.1"

        server["/"] = { [weak self] request in
            guard let self = self else { return HttpResponse.internalServerError }

            guard let jsonData = Data(request.body) as? Data,
                  let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
                return HttpResponse.badRequest(.text("Invalid JSON"))
            }

            guard let authCode = json["auth"] as? Int else {
                print("No pairing code detected.")
                return HttpResponse.badRequest(.text("Your request is missing a pairing code. Assuming you're a developer, you can correct this by providing an auth key with a simple integer value matching the current pairing code."))
            }

            let verification = json["verification"] as? Bool
            let display = json["display"] as? String

            var consoleLog = json
            consoleLog.removeValue(forKey: "auth")

            if authCode == self.pairingCode {
                if verification == true {
                    print("Successfully authenticated!")
                    return HttpResponse.ok(.text("Success"))
                } else if verification == nil {
                    if let displayData = display {
                        print("Received: \(consoleLog)")
                        self.receivedDisplayData = displayData
                        return HttpResponse.ok(.text("Request received successfully!"))
                    } else {
                        print("Received: \(consoleLog)")
                        return HttpResponse.badRequest(.text("Request received but no 'display' key found."))
                    }
                }
            } else {
                print("Uh-oh! Invalid pairing code.")
                return HttpResponse.badRequest(.text("Your pairing code is incorrect. Please verify that your pairing code is the same across this app and Shortcuts."))
            }

            print("Received: \(consoleLog)")
            print("This request cannot be used by the app.")
            return HttpResponse.badRequest(.text("Invalid request!"))
        }

        do {
            try server.start(configuration.port, forceIPv4: true)
            print("Server initialized successfully on port \(configuration.port)!")
            self.server = server
            self.isRunning = true
        } catch {
            print("Server initialization error: \(error)")
        }
    }

    public func stop() {
        guard isRunning else { return }
        server?.stop()
        server = nil
        isRunning = false
        print("Server has stopped")
    }

    public func displayPairingCode() {
        self.isPairingCodeVisible = true
    }

    public func dismissPairingCode() {
        self.isPairingCodeVisible = false
    }

    public func resetPairingCode() {
        pairingCode = Int.random(in: 1...9999)
        displayPairingCode()
    }
}

public struct PairingCodeOverlay: View {
    public let pairingCode: String
    public let onDismiss: () -> Void

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
    }
}

public struct VisualEffectBlur: UIViewRepresentable {
    public var style: UIBlurEffect.Style = .systemMaterial

    public init(style: UIBlurEffect.Style = .systemMaterial) {
        self.style = style
    }

    public func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }

    public func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}
