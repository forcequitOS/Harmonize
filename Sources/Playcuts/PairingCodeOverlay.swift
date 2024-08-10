import SwiftUI

public struct PairingCodeOverlay: View {
    let pairingCode: String
    let onDismiss: () -> Void

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
    var style: UIBlurEffect.Style = .systemMaterial

    public func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }

    public func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}
