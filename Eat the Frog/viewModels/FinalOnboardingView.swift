import SwiftUI
import ConfettiSwiftUI

struct FinalOnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentStep = 0
    @State private var showConfetti = false
    @State private var opacity = 1.0
    @State private var isBouncing = false
    @State private var tapped = 0
    let hoursPerYear: Double
    
    // Removed stepDuration and any timer usage
    @State private var confettiCounter = 0
    @State private var isGestureProcessing = false

    let onNext: () -> Void
    
    var body: some View {
        ZStack{
            Color("ghost").edgesIgnoringSafeArea(.all)
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // Progress bars
                    HStack(spacing: 8) {
                        ForEach(0..<4) { index in
                            Capsule()
                                .fill(index <= currentStep ? Color("lime") : Color.gray.opacity(0.3))
                                .frame(height: 4)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Content with fade transition
                    content
                        .opacity(opacity)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onEnded { value in
                                    guard !isGestureProcessing else { return } // Prevent gesture spamming
                                    isGestureProcessing = true // Block further gestures
                                    
                                    // If user taps or drags on the right side, advance
                                    if currentStep < 3 && value.location.x > geometry.size.width / 2 {
                                        triggerHapticFeedback()
                                        goToNextStep()
                                    }
                                    // Allow new gestures after a short delay
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                        isGestureProcessing = false
                                    }
                                }
                        )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
            }
        }
    }
    // MARK: - Content
    private var content: some View {
        Group {
            switch currentStep {
            case 0:
                welcomeView
            case 1:
                badNewsView
            case 2:
                goodNewsView
            case 3:
                weeklyGoalsView
            default:
                EmptyView()
            }
        }
    }
    
    private var welcomeView: some View {
        VStack(spacing: 24) {
            Text("Sorry, that took a bit longer than expected, but now we’re all set to help you take control of your days!")
                .font(.system(size: 32, weight: .regular))
                .multilineTextAlignment(.center)
                .foregroundColor(.black)
        }
        .padding(.horizontal, 32)
    }
    
    private var badNewsView: some View {
        VStack(spacing: 24) {
            Text("You would procrastinate")
                .font(.system(size: 24))
                .foregroundColor(.black)
            
            Text("\(Int(hoursPerYear/2))\ntasks")
                .font(.system(size: 80, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color("lime"), .orange],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            Text("due to your phone this year.")
                .font(.system(size: 24))
                .foregroundColor(.black)
            
            Text("That's about \(Int(hoursPerYear/24)) days spent on your phone")
                .font(.system(size: 20))
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .fontWeight(.light)
                .padding(.top, 8)
        }
        .padding(.horizontal, 32)
    }
    
    private var goodNewsView: some View {
        VStack(spacing: 24) {
            Text("Eating your frog can save you")
                .font(.system(size: 24))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
            
            Text("\(Int(hoursPerYear/52))+\ndays")
                .font(.system(size: 80, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color("lime"), .orange],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            Text("That's almost \(Int((hoursPerYear/8760)*27)) years or \(Int(hoursPerYear/2)*80) tasks you didn't put off in your life")
                .font(.system(size: 20))
                .foregroundColor(.gray)
                .fontWeight(.light)
                .multilineTextAlignment(.center)
                .padding(.top, 8)
        }
        .padding(.horizontal, 32)
    }
    
    private var weeklyGoalsView: some View {
        VStack(spacing: 32) {
            Text("This week, Eat that Frog can help you:")
                .font(.system(size: 28, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundColor(.black)
                .padding(.top, 30)
            
            VStack(alignment: .leading, spacing: 30) {
                goalRow("Reduce procrastination by 70%")
                goalRow("Reduce distractions by 40%")
                goalRow("Finish 7 grueling tasks")
                goalRow("Develop 1 good habit")
                goalRow("Reduce screen time by 30%")
            }
            
            Spacer()
            
            VStack(spacing: 16) {
                Text("🤙")
                    .font(.system(size: 60))
                    .offset(y: isBouncing ? -10 : 0)
                    .animation(
                        Animation.easeInOut(duration: 0.6)
                            .repeatForever(autoreverses: true),
                        value: isBouncing
                    )
                    .onAppear { isBouncing = true }
                    .onTapGesture {
                        if tapped < 1  {
                            
                            tapped+=1
                            triggerHapticFeedback()
                            confettiCounter += 1
                            // Then move on after a short delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                onNext()
                            }
                        }
                    }
                
                Text("Click to pinky promise: let's eat our frogs this week!")
                    .font(.system(size: 18))
                    .multilineTextAlignment(.center)
                    .fontWeight(.light)
                    .foregroundColor(.gray)
            }
            .confettiCannon(
                counter: $confettiCounter,
                num: 40,
                confettiSize: 15,
                openingAngle: Angle.degrees(0),
                closingAngle: Angle.degrees(180),
                radius: 500,
                repetitions: 1,
                repetitionInterval: 0
            )
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 24)
    }
    
    private func goalRow(_ text: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: "checkmark.seal.fill")
                .foregroundColor(Color("lime"))
                .font(.system(size: 23, weight: .bold))
            
            Text(text)
                .font(.system(size: 20))
                .foregroundColor(.black)
        }
    }
    
    // MARK: - Step Functions (No more timer)
    private func goToNextStep() {
        guard currentStep < 3 else { return }
        advanceStep(forward: true)
    }
    
    private func goToPreviousStep() {
        guard currentStep > 0 else { return }
        advanceStep(forward: false)
    }
    
    private func advanceStep(forward: Bool) {
        withAnimation(.easeInOut(duration: 0.3)) {
            opacity = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            currentStep += forward ? 1 : -1
            
            withAnimation(.easeInOut(duration: 0.3)) {
                opacity = 1
            }
        }
    }
}

// MARK: - Preview
struct FinalOnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        FinalOnboardingView(hoursPerYear: 8760,
            onNext:{ print("Next tapped") })
    }
}

// MARK: - Haptic
private func triggerHapticFeedback() {
    let generator = UIImpactFeedbackGenerator(style: .light)
    generator.impactOccurred()
}
