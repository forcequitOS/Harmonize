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
    
    // Define a closure that the host app can provide to specify valid inputs and how to handle them
    public var validInputsHandler: (([String: Any]) -> (response: [String: Any], output: String?))?
    
    public init() {
        // Generate a new pairing code if it hasn't been generated yet
        if pairingCode == 0 {
            resetPairingCode()
        }
    }
    
    // Start the server with an optional port
    public func start(port: UInt16 = 6996) {
        guard server == nil else { return } // Server already running
        
        let server = HttpServer()
        server.listenAddressIPv4 = "127.0.0.1"
        
        server["/"] = { request in
            guard let jsonData = Data(request.body) as? Data,
                  let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
                return HttpResponse.badRequest(.text("Invalid JSON"))
            }
            
            guard let authCode = json["auth"] as? Int else {
                print("No pairing code detected.")
                return HttpResponse.badRequest(.text("Your request is missing a pairing code."))
            }
            
            // Handle verification
            if authCode == self.pairingCode {
                let verification = json["verification"] as? Bool
                if verification == true {
                    print("Successfully authenticated!")
                    DispatchQueue.main.async {
                        self.dismissPairingCode()
                    }
                    return HttpResponse.ok(.text("Success"))
                }
                
                // Process valid inputs (ignoring pairing code and verification)
                if let validInputsHandler = self.validInputsHandler {
                    let (response, output) = validInputsHandler(json)
                    
                    // If the host app did not specify an output, send a default response
                    let responseText = output ?? "Message received!"
                    return HttpResponse.ok(.text(responseText))
                } else {
                    return HttpResponse.badRequest(.text("No valid input handler provided by host app."))
                }
            } else {
                print("Invalid Harmonize pairing code.")
                return HttpResponse.badRequest(.text("Your pairing code is incorrect."))
            }
        }
        
        // Start the server
        do {
            try server.start(port, forceIPv4: true)
            print("Harmonize initialized successfully on port \(port)!")
            self.server = server
            DispatchQueue.main.async {
                self.isRunning = true
                self.displayPairingCode()
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
}
