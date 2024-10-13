import SwiftUI
import Swifter

public class Harmonize: ObservableObject {
    @AppStorage("pairingCode") private var storedPairingCode: Int = 0
    @Published public var isRunning = false
    @Published public var receivedDisplayData: String = ""
    @Published public var isPairingCodeVisible = false
    
    private var server: HttpServer?
    
    public var pairingCode: Int {
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
        let port: UInt16 = 6996  // You can make this configurable
        
        server["/"] = { request in
            guard let jsonData = Data(request.body) as? Data,
                  let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
                return HttpResponse.badRequest(.text("Invalid JSON"))
            }
            
            if let authCode = json["auth"] as? Int, authCode == self.pairingCode {
                // Handle valid requests
                self.handleValidRequest(json)
                return HttpResponse.ok(.text("Request processed successfully"))
            } else {
                return HttpResponse.badRequest(.text("Invalid pairing code"))
            }
        }
        
        do {
            try server.start(port, forceIPv4: true)
            print("Harmonize initialized successfully on port \(port)!")
            self.server = server
            DispatchQueue.main.async {
                self.isRunning = true
                self.displayPairingCode()  // Show the pairing code when the server starts
            }
        } catch {
            print("Harmonize initialization error: \(error)")
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
    
    private func handleValidRequest(_ json: [String: Any]) {
        // Here, you can manage inputs and outputs as needed
        // For example:
        if let displayData = json["display"] as? String {
            DispatchQueue.main.async {
                self.receivedDisplayData = displayData
            }
        }
    }
}
