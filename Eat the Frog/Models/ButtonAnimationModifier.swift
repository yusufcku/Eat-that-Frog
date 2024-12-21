import SwiftUI

struct NoHighlightButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 1.1 : 1.0) // Add the zoom effect
            .background(configuration.isPressed ? Color.red.opacity(0.8) : Color.red) // Optional pressed color adjustment
            .cornerRadius(30)
            .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 2)
            .animation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0), value: configuration.isPressed)
    }
}
