import SwiftUI

struct FinalPageView: View {
    // Callback when the user taps the button
    let onComplete: () -> Void
    
    @State private var opacity = 0.0
    
    // If you still want to dismiss modals, you can keep this:
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Background
            Color.white
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                // Icon
                Image("app-icon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .foregroundColor(Color("lime"))
                
                // Title + subtitle
                Text("Finally...")
                    .font(.system(size: 16, weight: .light))
                    .foregroundColor(.gray)
                    .padding(.top, 8)
                    .padding(.bottom, 5)
                
                Text("Welcome to\nEat that Frog")
                    .font(.system(size: 32, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
                
                Text("Select apps to block, set\ndaily frogs, and get productive!")
                    .font(.system(size: 16, weight: .light))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                
                Spacer()
                
                // Action area
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "gear")
                            .foregroundColor(Color("lime"))
                        
                        Text("Go to settings for set up")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Button(action: {
                        triggerHapticFeedback()
                        
                        withAnimation(.easeInOut(duration: 0.5)) {
                            opacity = 0  // Fade out animation
                        }
                        
                        // Fire the completion callback after fade
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            onComplete()
                        }
                    }) {
                        Text("Let's make it happen!")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color("lime"))
                            .cornerRadius(28)
                    }
                    .padding(.bottom, 45)
                }
            }
            .padding()
            .opacity(opacity)
            .onAppear {
                // Animate in
                withAnimation(.easeIn(duration: 0.8)) {
                    opacity = 1.0
                }
            }
        }
    }
}

struct FinalPageView_Previews: PreviewProvider {
    static var previews: some View {
        FinalPageView(onComplete: {
            // What should happen when tapped in preview?
            print("Completed Final Page!")
        })
    }
}

// MARK: - Haptic Feedback
private func triggerHapticFeedback() {
    let impact = UIImpactFeedbackGenerator(style: .light)
    impact.impactOccurred()
}
