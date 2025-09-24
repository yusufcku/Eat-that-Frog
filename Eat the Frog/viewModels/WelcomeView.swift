import SwiftUI

struct WelcomeView: View {
    let onGetStarted: () -> Void
    
    @State private var contentOffset: CGFloat = 50
    @State private var contentOpacity: Double = 0
    @State private var buttonOffset: CGFloat = 30
    @State private var buttonOpacity: Double = 0
    @State private var ratingOffset: CGFloat = 20
    @State private var ratingOpacity: Double = 0
    @State private var isAnimatingOut: Bool = false
    
    var body: some View {
        ZStack {
            Image("mountain-background")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Spacer()
                
                VStack(spacing: 20) {
                    Image("app-icon")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .cornerRadius(20)
                    
                    VStack(spacing: 5) {
                        Text("Eat that Frog.\nUnlock Your Day.")
                            .font(.system(size: 27, weight: .black))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .shadow(color: Color.black.opacity(0.3), radius: 4, x: 3, y: 3)
                        
                        Text("“If it's your job to eat a frog, it's best to do\nit first thing in the morning” - Mark Twain")
                            .font(.system(size: 16, weight: .light))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .padding()
                            .shadow(color: Color.black.opacity(0.7), radius: 4, x: 3, y: 3)
                    }
                }
                .offset(y: contentOffset)
                .opacity(contentOpacity)
                
                HStack(spacing: 8) {
                    Image(systemName: "laurel.leading")
                        .foregroundColor(.yellow)
                    Text("PROVEN THE BEST PRODUCTIVITY LIFE-HACK")
                        .font(.system(size: 11, weight: .regular))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    Image(systemName: "laurel.trailing")
                        .foregroundColor(.yellow)
                }
                .padding(.top, 40)
                .offset(y: ratingOffset)
                .opacity(ratingOpacity)
                
                VStack(spacing: 16) {
                    Button(action: {
                        triggerHapticFeedback()
                        withAnimation(.easeInOut(duration: 0.5)) {
                            isAnimatingOut = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            onGetStarted()
                        }
                    }) {
                        Text("Get Started")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color("lime"))
                            .cornerRadius(28)
                    }
                    
                }
                .padding()
                .padding(.bottom, 50)
                .offset(y: buttonOffset)
                .opacity(buttonOpacity)
            }
            .padding(.horizontal, 24)
            .opacity(isAnimatingOut ? 0 : 1)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0).delay(0.2)) {
                contentOffset = 0
                contentOpacity = 1
            }
            
            withAnimation(.easeOut(duration: 0.8).delay(0.7)) {
                ratingOffset = 0
                ratingOpacity = 1
            }
            
            withAnimation(.easeOut(duration: 0.8).delay(1.0)) {
                buttonOffset = 0
                buttonOpacity = 1
            }
        }
    }
}



struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(onGetStarted: {
            print("Get Started button tapped")
        })
        .previewDevice("iPhone 16")
    }
}


private func triggerHapticFeedback() {
    let generator = UIImpactFeedbackGenerator(style: .light)
    generator.impactOccurred()
}
