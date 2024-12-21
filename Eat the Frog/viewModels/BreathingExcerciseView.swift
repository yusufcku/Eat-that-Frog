import SwiftUI
import CoreHaptics

struct BreathingExcerciseView: View {
    @Binding var isPresented: Bool
    let onConfirm: () -> Void

    @State private var wordOpacities: [Double] = []
    @State private var showButtons = false
    @State private var currentPhase: BreathingPhase = .breatheIn
    @State private var engine: CHHapticEngine?

    enum BreathingPhase {
        case breatheIn, hold, breatheOut
    }

    let questionLine1 = ["Did", "you", "eat"]
    let questionLine2 = ["your", "frog?"]

    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 40) {
                Spacer()

                if !showButtons {
                    VStack(spacing: 10) {
                        questionText(line: questionLine1, offset: 0)
                        questionText(line: questionLine2, offset: questionLine1.count)
                    }
                    .padding()
                }

                if !showButtons {
                    Text(currentPhaseText())
                     
                        .font(.system(size: 20, weight: .regular, design: .monospaced))
                        .foregroundColor(.green)
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 1.5), value: currentPhase)
                        .padding(.bottom, 40)
                }

                if showButtons {
                    VStack(spacing: 20) {
                        yesButton
                        noButton
                    }
                    .frame(maxWidth: 300)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 1.5), value: showButtons)
                }

                Spacer()
            }
            .padding()
        }
        .onAppear {
            startSequence()
            prepareHaptics()
        }
    }

    private var yesButton: some View {
        Button(action: {
            onConfirm()
            isPresented = false
        }) {
            Text("Yes, it's done")
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color("pastelgreen"))
                .foregroundColor(.white)
                .cornerRadius(30)
                .overlay(AnimatedRainbowOutline().cornerRadius(30))
        }
    }

    private var noButton: some View {
        Button(action: {
            isPresented = false
        }) {
            Text("No, not yet")
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color("pastelred"))
                .foregroundColor(.white)
                .cornerRadius(30)
                .animation(.easeInOut(duration: 1.5), value: showButtons) // Added animation
        }
    }

    private func questionText(line: [String], offset: Int) -> some View {
        HStack(spacing: 6) {
            ForEach(0..<line.count, id: \.self) { index in
                let globalIndex = offset + index
                let opacity = wordOpacities[safe: globalIndex] ?? 0
                Text(line[index])
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                    .opacity(opacity)
                    .animation(.easeInOut(duration: 1.0).delay(Double(globalIndex) * 0.5), value: opacity)
            }
        }
    }

    private func currentPhaseText() -> String {
        switch currentPhase {
        case .breatheIn:
            return "Breathe In"
        case .hold:
            return "Hold"
        case .breatheOut:
            return "Breathe Out"
        }
    }

    private func startSequence() {
        let totalWords = questionLine1.count + questionLine2.count
        wordOpacities = Array(repeating: 0.0, count: totalWords)

        for index in 0..<totalWords {
            Timer.scheduledTimer(withTimeInterval: Double(index) * 0.3, repeats: false) { _ in // Adjusted interval
                if index < wordOpacities.count {
                    wordOpacities[index] = 1.0
                }
            }
        }

        Timer.scheduledTimer(withTimeInterval: Double(totalWords) * 0.3 + 2.0, repeats: false) { _ in // Shortened delay
            withAnimation {
                currentPhase = .hold
            }
        }

        Timer.scheduledTimer(withTimeInterval: Double(totalWords) * 0.3 + 4.0, repeats: false) { _ in // Shortened delay
            withAnimation {
                currentPhase = .breatheOut
            }
            triggerHapticFeedback()
        }

        Timer.scheduledTimer(withTimeInterval: Double(totalWords) * 0.3 + 4.0, repeats: false) { _ in // Adjusted timing
            withAnimation(Animation.easeInOut(duration: 3.0)) { // Shortened fade-out
                wordOpacities = Array(repeating: 0.0, count: totalWords)
            }
        }

        Timer.scheduledTimer(withTimeInterval: Double(totalWords) * 0.3 + 7.0, repeats: false) { _ in // Adjusted timing
            withAnimation {
                showButtons = true
            }
        }
    }

    private func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            self.engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("There was an error creating the engine: \(error.localizedDescription)")
        }
    }

    private func triggerHapticFeedback() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        var events = [CHHapticEvent]()

        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
        let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensity, sharpness], relativeTime: 0.0, duration: 1.0)
        events.append(event)

        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription)")
        }
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

struct BreathingExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        BreathingExcerciseView(
            isPresented: .constant(true),
            onConfirm: {
                print("Task completed!")
            }
        )
    }
}
