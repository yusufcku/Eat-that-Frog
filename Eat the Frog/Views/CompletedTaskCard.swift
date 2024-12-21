import SwiftUI

struct AnimatedRainbowOutline1: View {
    @State private var gradientOffset: Double = 0.0 // Gradient rotation state
    @State private var shineOffset: CGFloat = -1.0 // Shine effect state
    @State private var timer: Timer? // Timer to control updates

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
        }
        .drawingGroup() // GPU optimization for smoother rendering
        .onAppear {
            startTimer() // Start the timer when the view appears
        }
        .onDisappear {
            stopTimer() // Stop the timer when the view disappears
        }
    }

    private func startTimer() {
        // Set up a timer to manually update the animation states
        timer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { _ in
            gradientOffset += 2
            shineOffset += 3
            if gradientOffset >= 360 { gradientOffset = 0 }
            if shineOffset >= 360 { shineOffset = 0 }
        }
    }

    private func stopTimer() {
        // Invalidate the timer when the view disappears
        timer?.invalidate()
        timer = nil
    }
}

struct CompletedTaskCard: View {
    @ObservedObject var viewModel: TaskViewModel
    @Binding var confettiCounter: Int
    @Binding var isBreathingPagePresented: Bool

    var body: some View {
        
        VStack(spacing: 20) {
            Text("Did you eat your frog?")
                .font(.system(size: 21, weight: .regular, design: .monospaced))
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button(action: {
                triggerHapticFeedback()
                let isBreathingEnabled = UserDefaults.standard.bool(forKey: "isBreathingExerciseEnabled")
                if isBreathingEnabled {
                    isBreathingPagePresented = true
                } else {
                    viewModel.stopTask()
                    viewModel.addTaskCompletion()
                    SoundPlayer.shared.playSound("confetti", withExtension: "mp3", volume: 0.3)
                    confettiCounter += 1
                }
            }) {
                Text(viewModel.response)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .frame(height: 45)
                    .overlay(
                        AnimatedRainbowOutline1() // Timer-based animation here
                            .cornerRadius(30)
                    )
                    .background(Color.lime)
                    .cornerRadius(30)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 2)
        .fullScreenCover(isPresented: $isBreathingPagePresented) {
            BreathingExcerciseView(isPresented: $isBreathingPagePresented) {
                viewModel.stopTask()
                viewModel.addTaskCompletion()
                confettiCounter += 1
                triggerHapticFeedback()
                SoundPlayer.shared.playSound("confetti", withExtension: "mp3", volume: 0.3)
            }
        }
    }
    

    private func triggerHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}

struct CompletedTaskCard_Previews: PreviewProvider {
    @State static var confettiCounter = 0
    @State static var isBreathingPagePresented = false

    static var previews: some View {
        CompletedTaskCard(
            viewModel: TaskViewModel(), // Pass an instance of TaskViewModel
            confettiCounter: $confettiCounter, // Binding for confettiCounter
            isBreathingPagePresented: $isBreathingPagePresented // Binding for fullScreenCover
        )
        .previewLayout(.sizeThatFits) // Preview size
        .padding()
        .background(Color.gray.opacity(0.2)) // Background for visibility
    }
}
