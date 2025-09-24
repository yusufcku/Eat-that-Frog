import SwiftUI

struct OnboardingView1: View {
    @State private var currentPage = 0
    @State private var opacity = 1.0
    let onComplete: () -> Void
    @State private var skipButtonOpacity = 0.0
    
    var body: some View {
        ZStack {
            Color("ghost").edgesIgnoringSafeArea(.all)
            if currentPage == 0 {
                WelcomeView(onGetStarted: {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        opacity = 0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        currentPage = 1
                        withAnimation(.easeInOut(duration: 0.5)) {
                            opacity = 1
                        }
                    }
                })
                .opacity(opacity)
            } else if currentPage <= 3 {
                onboardingContent
            } else {
                SurveyView(currentStep: $currentPage, earthColor: Color("earth"), onComplete: onComplete)
                    .transition(.opacity)
            }
                VStack {
                    Spacer()
                    Button(action: {
                        withAnimation {
                            onComplete()
                        }
                    }) {
                        Text("Skip Set Up")
                            .font(.system(size: 13, weight: .light))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.lime)
                            .padding(.bottom,-5)
                    }
                    .opacity(skipButtonOpacity) // Use the opacity state
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation(.easeIn(duration: 1.0)) {
                                skipButtonOpacity = 1.0 // Animate opacity to fade in
                            }
                        }

                    }
                }
        }
        .animation(.easeInOut(duration: 0.5), value: currentPage)
        .preferredColorScheme(.light)
    }
    
    var onboardingContent: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            VStack {
                // Back button
                HStack {
                    Button(action: {
                        if currentPage > 1 {
                            currentPage -= 1
                        } else {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                opacity = 0
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                currentPage = 0
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    opacity = 1
                                }
                            }
                        }
                    }) { 
                        Image(systemName: "arrow.left")
                            .foregroundColor(Color("lime"))
                            .imageScale(.large)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 16)
                
                TabView(selection: $currentPage) {
                    ForEach(1...3, id: \.self) { index in
                        OnboardingPageView(page: onboardingPages[index - 1])
                            .tag(index)
                        
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                HStack(spacing: 8) {
                    ForEach(1...3, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? Color("lime") : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.bottom, 20)
                
                Button(action: {
                    triggerHapticFeedback()
                    if currentPage == 3 {
                                          withAnimation(.easeInOut(duration: 0.5)) {
                                              opacity = 0
                                          }
                                          DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                              currentPage += 1
                                          }
                                      } else {
                                          withAnimation {
                                              currentPage += 1
                                          }
                                      }
                }) {
                    Text("Next")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color("lime"))
                        .cornerRadius(28)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 56)
            }
            .opacity(opacity)
        }
    }
}

extension UserDefaults {
    var hasCompletedOnboarding1: Bool {
        get { bool(forKey: "hasCompletedOnboarding1") }
        set { set(newValue, forKey: "hasCompletedOnboarding1") }
    }
}

struct OnboardingView1_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView1(onComplete: {})
    }
}


private func triggerHapticFeedback() {
    let generator = UIImpactFeedbackGenerator(style: .light)
    generator.impactOccurred()
}

struct InfoBox: View {
    let title: String
    let value: String
    let valueColor: Color
    let setColor: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(valueColor)
        }
        .padding()
        .frame(maxWidth: 300)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.gray.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke((setColor).opacity(0.5), lineWidth: 2)
                )
        )
    }
}
