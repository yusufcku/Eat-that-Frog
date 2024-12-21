import SwiftUI

struct AnimatedRainbowOutline: View {
    @State private var gradientOffset: Double = 0.0 // For rotating the gradient colors
    @State private var shineOffset: CGFloat = -1.0 // For moving the shine effect

    var body: some View {
        ZStack {
            // Rotating rainbow colors
            RoundedRectangle(cornerRadius: 30)
                .strokeBorder(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            .red, .orange, .yellow, .green, .blue, .purple, .red
                        ]),
                        center: .center,
                        startAngle: .degrees(gradientOffset),
                        endAngle: .degrees(gradientOffset + 360)
                    ),
                    lineWidth: 3
                )
                .onAppear {
                    startColorRotation()
                }

            // Shine effect moving along the outline
            RoundedRectangle(cornerRadius: 30)
                .strokeBorder(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            Color.clear,
                            Color.white.opacity(0.8), // Bright shine
                            Color.clear
                        ]),
                        center: .center,
                        startAngle: .degrees(shineOffset),
                        endAngle: .degrees(shineOffset + 20) // Narrow shine
                    ),
                    lineWidth: 3
                )
                .onAppear {
                    startShineAnimation()
                }
        }
    }

    private func startColorRotation() {
        withAnimation(
            Animation.linear(duration: 3)
                .repeatForever(autoreverses: false)
        ) {
            gradientOffset = 360 // Full rotation
        }
    }

    private func startShineAnimation() {
        withAnimation(
            Animation.linear(duration: 1.5)
                .repeatForever(autoreverses: false)
        ) {
            shineOffset = 360 // Move shine along the outline
        }
    }
}
