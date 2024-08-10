import Foundation
import SwiftUI
import Swifter

public struct PlaycutsConfiguration {
    public var port: UInt16
    public var pairingCodeLength: Int

    public init(port: UInt16 = 6996, pairingCodeLength: Int = 4) {
        self.port = port
        self.pairingCodeLength = pairingCodeLength
    }
}

public final class Playcuts: ObservableObject {
    private var server: HttpServer?
    private var configuration: PlaycutsConfiguration
    @Published public private(set) var isRunning = false
    @Published public private(set) var pairingCode: Int = 0
    @Published public private(set) var isPairingCodeVisible = false

    public init(configuration: PlaycutsConfiguration = PlaycutsConfiguration()) {
        self.configuration = configuration
    }

    public func start() {
        if isRunning {
            print("Playcuts server is already running.")
            return
        }

        let server = HttpServer()
        server.listenAddressIPv4 = "127.0.0.1"
        pairingCode = generatePairingCode()

        server["/"] = { request in
            guard let jsonData = Data(request.body) as? Data,
                  let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
                return HttpResponse.badRequest(.text("Invalid JSON"))
            }

            guard let authCode = json["auth"] as? Int else {
                return HttpResponse.badRequest(.text("Missing pairing code."))
            }

            if authCode == self.pairingCode {
                // Handle valid requests
                return HttpResponse.ok(.text("Authenticated successfully."))
            } else {
                return HttpResponse.badRequest(.text("Invalid pairing code."))
            }
        }

        do {
            try server.start(configuration.port, forceIPv4: true)
            self.server = server
            isRunning = true
            print("Playcuts server started on port \(configuration.port).")
        } catch {
            print("Failed to start Playcuts server: \(error)")
        }
    }

    public func stop() {
        guard isRunning else {
            print("Playcuts server is not running.")
            return
        }

        server?.stop()
        server = nil
        isRunning = false
        print("Playcuts server stopped.")
    }

    public func displayPairingCode() {
        pairingCode = generatePairingCode()
        withAnimation {
            isPairingCodeVisible = true
        }
    }

    public func dismissPairingCode() {
        withAnimation {
            isPairingCodeVisible = false
        }
    }

    private func generatePairingCode() -> Int {
        return Int.random(in: 1...(Int(pow(10, Double(configuration.pairingCodeLength))) - 1))
    }
}
