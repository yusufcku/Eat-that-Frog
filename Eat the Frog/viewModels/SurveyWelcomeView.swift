import SwiftUI

struct SurveyWelcomeView: View {
    let onNext: () -> Void
    let onSkip: () -> Void
    @State private var opacity = 0.0
    
    var body: some View {
        ZStack {
            // White background layer
            Color("ghost").edgesIgnoringSafeArea(.all) // Ensure the background covers the entire screen
            
            VStack {
                Spacer()
                Image("app-icon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .cornerRadius(20)
                
                Text("Welcome to\nEat that Frog")
                    .font(.system(size: 32, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
                
                Text("Let's understand your habits\nand create you a plan")
                    .font(.system(size: 16, weight: .light))
                    .foregroundColor(.gray)
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                    .multilineTextAlignment(.center)
                
                Spacer()
                VStack(spacing: 16) {
                    Button(action: {
                        triggerHapticFeedback()
                        withAnimation(.easeInOut(duration: 0.5)) {
                            opacity = 0 // Fade out the entire page
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            onSkip() // Trigger the skip action
                        }
                    }) {
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(Color("lime"))
                            Text("takes 1 minute (click here to skip)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }

                    Button(action: {
                        triggerHapticFeedback()
                               withAnimation(.easeInOut(duration: 0.5)) {
                                   opacity = 0 // Fade out the entire page
                               }
                               DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                   onNext() // Trigger the next action after the animation completes
                               }
                           }) {
                               Text("Continue")
                                   .font(.headline)
                                   .foregroundColor(.white)
                                   .frame(maxWidth: .infinity)
                                   .frame(height: 56)
                                   .background(Color("lime"))
                                   .cornerRadius(28)
                           }
                        }
                            .padding(.bottom, 45)
                        }
            .padding()
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeIn(duration: 0.8)) {
                    opacity = 1.0
                }
            }
        }
    }
}

struct SurveyWelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        SurveyWelcomeView(
            onNext: {
                print("Next button tapped!")
            },
            onSkip: {
                print("Skip to Sync button tapped!")
            }
        )
    }
}

private func triggerHapticFeedback() {
    let generator = UIImpactFeedbackGenerator(style: .light)
    generator.impactOccurred()
}
