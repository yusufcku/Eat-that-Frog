import SwiftUI

struct SurveyView: View {
    @Binding var currentStep: Int
    let earthColor: Color
    let onComplete: () -> Void
    
    @State private var selectedAnswers: [Int] = Array(repeating: -1, count: 7)
    @State private var hoursPerDay: Double = 7
    @State private var offset: CGFloat = 0
    @State private var opacity: Double = 0.0
    @State private var isAnimating: Bool = false
    @State private var path = NavigationPath()
    
    private var hoursPerYear: Double {
        hoursPerDay * 365
    }
    
    private let questions = [
        "Do you find yourself using your phone late at night, even when it interferes with your sleep?",
        "Has your phone usage negatively impacted your relationships with family or friends?",
        "Do you ever feel regret or guilt about how much time you spend on your smartphone?",
        "How does your smartphone usage affect your ability to focus and be productive?",
        "Do you feel the strongest urge to check your phone immediately after waking up?",
        "If you had an ideal daily smartphone screen time, how close are you to achieving it?"
    ]
    
    private let options: [[String]] = [
        ["Yes, almost every night", "Occasionally, not nightly", "Rarely, special occasions", "No, I don't use it at night"],
        ["Yes, caused real conflicts", "Sometimes, I prioritize it", "Rarely, it's come up before", "No, no effect on my ties"],
        ["Yes, I waste too much time", "Sometimes, but not always", "Rarely, but it has happened", "No, I don't regret my use"],
        ["It kills my focus a lot", "Distracts me, but I recover", "Rarely affects productivity", "No, no impact on my work"],
        ["Yes, right after I wake up", "Sometimes, but not always", "Rarely, I usually delay it", "No, I don't feel the urge"],
        ["Far from my goal", "Somewhat close", "Nearly meeting it", "I'm fine with my current use"]
    ]
    
    private let images = [
        "moon.zzz.fill",
        "person.2.fill",
        "hand.raised.fill",
        "doc.text.magnifyingglass",
        "sunrise.fill",
        "hourglass.bottomhalf.fill"
    ]
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Color("ghost").edgesIgnoringSafeArea(.all)
                
                Group {
                    if currentStep == 4 {
                        SurveyWelcomeView(
                            onNext: {
                                // Handle the continue action
                                withAnimation(.easeInOut(duration: 0.1)) {
                                    opacity = 0
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    currentStep += 1
                                    withAnimation(.easeInOut(duration: 0.7)) {
                                        opacity = 1
                                    }
                                }
                            },
                            onSkip: {
                                // Handle the skip to sync action
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    opacity = 0
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    path.append("syncScreen") // Navigate directly to SyncScreenView
                                }
                            }
                        )
                    }
 else {
                        VStack(spacing: 0) {
                            topBar
                            questionContent
                        }
                        .opacity(opacity)
                    }
                }
                .onChange(of: currentStep) { oldValue, newValue in
                    animateTransition()
                }
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 0.5)) {
                    opacity = 1.0
                }
            }
            .navigationDestination(for: String.self) { route in
                switch route {
                case "analysis":
                    AnalysisView(
                        earthColor: earthColor,
                        onNext: {
                            // When "Let's fix it together" is tapped inside AnalysisView,
                            // we want to navigate to the SyncScreenView
                            path.append("syncScreen")
                        },
                        selectedAnswers: selectedAnswers,
                        hoursPerYear: hoursPerYear
                    )
                    .navigationBarBackButtonHidden(true)

                case "syncScreen":
                    SyncScreenView(onContinue: {
                        // When Screen Time authorization is granted, navigate to NotificationPermissionView
                        path.append("notificationPermission")
                    })
                    .navigationBarBackButtonHidden(true)

                case "notificationPermission":
                    NotificationPermissionView(onContinue: {
                        // Do something or navigate further when both Screen Time and Notification permissions are granted
                        print("Both Screen Time and Notification permissions granted")
                        // You can add further navigation or actions here
                        path.append("finalOnboarding")
                    })
                    .navigationBarBackButtonHidden(true)
                    
                case "finalOnboarding":
                    FinalOnboardingView(hoursPerYear: hoursPerYear, onNext: {
                        // When Screen Time authorization is granted, navigate to NotificationPermissionView
                        path.append("paywall")
                    })
                    .navigationBarBackButtonHidden(true)

                case "paywall":
                    PaywallView(hoursPerYear: hoursPerYear, onComplete: {
                        // When Screen Time authorization is granted, navigate to NotificationPermissionView
                        path.append("finalOnboardingComplete")
                    })
                    .navigationBarBackButtonHidden(true)
                    
                    
                case "finalOnboardingComplete":
                    FinalPageView(onComplete: {
                        onComplete()
                        
                    })
                    .navigationBarBackButtonHidden(true)
                    
                default:
                    EmptyView()
                    .navigationBarBackButtonHidden(true)
                }
            }
        }
    }
    
    private var topBar: some View {
        VStack(spacing: 4) {
            ZStack {
                HStack {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            currentStep -= 1
                        }
                    }) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(Color("lime"))
                            .imageScale(.large)
                    }
                    
                    Spacer()
                    
                    if currentStep < 11 {
                    Button(action: {
                    skipQuestion()
                    }) {
                        Text("Skip")
                        .foregroundColor(Color("lime"))
                        }
                    }
                }
                .padding(.horizontal, 22)
                
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 200, height: 6)
                    
                    Rectangle()
                        .fill(Color("lime"))
                        .frame(width: max(0, CGFloat(currentStep - 4) / 7 * 200), height: 6)
                }
                .cornerRadius(3)
                .frame(width: 200)
            }
            
            Text("\(min(currentStep - 4, 7))/7")
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 16)
    }
    
    private var questionContent: some View {
        Group {
            if currentStep >= 5 && currentStep <= 10 {
                normalQuestionView(questionIndex: currentStep - 5)
            } else if currentStep == 11 {
                timeCalculatorView
            }
        }
        .offset(x: offset)
    }
    
    private func normalQuestionView(questionIndex: Int) -> some View {
        ScrollView {
            VStack(spacing: 30) {
                if questionIndex < questions.count {
                    Image(systemName: images[questionIndex])
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .foregroundColor(earthColor)
                        .padding()
                        .background(Circle().fill(earthColor.opacity(0.1)))
                        .padding(.top, 30)
                        .scaleEffect(isAnimating ? 1 : 0.7)
                        .opacity(isAnimating ? 1 : 0)
                    
                    Text(questions[questionIndex])
                        .font(.system(size: 20, weight: .bold))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 23)
                        .foregroundColor(.black)
                    
                    VStack(spacing: 12) {
                        ForEach(0..<4) { index in
                            Button(action: {
                                triggerHapticFeedback()
                                withAnimation {
                                    selectedAnswers[questionIndex] = index
                                }
                            }) {
                                Text(options[questionIndex][index])
                                    .font(.system(size: 17))
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(
                                        RoundedRectangle(cornerRadius: 28)
                                            .stroke(selectedAnswers[questionIndex] == index ? earthColor : Color.gray.opacity(0.3), lineWidth: 3.5)
                                            .background(selectedAnswers[questionIndex] == index ? earthColor.opacity(0.1) : Color.white)
                                    )
                                    .cornerRadius(28)
                                    .shadow(color: selectedAnswers[questionIndex] == index ? Color("lime").opacity(0.3) : Color.clear, radius: 10, x: 0, y: 5)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    if selectedAnswers[questionIndex] != -1 {
                        Button(action: {
                            triggerHapticFeedback()
                            nextQuestion()
                        }) {
                            Text("Next")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color("lime"))
                                .cornerRadius(28)
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                        .transition(.opacity)
                    }
                } else {
                    Text("All questions answered")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.bottom, 50)
        }
    }
    
    private var timeCalculatorView: some View {
        ScrollView {
            VStack(spacing: 25) {
                Image(systemName: "clock.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .foregroundColor(earthColor)
                    .padding()
                    .background(Circle().fill(earthColor.opacity(0.1)).frame(width: 100, height: 100))
                    .padding(.top, 30)
                    .scaleEffect(isAnimating ? 1 : 0.7)
                    .opacity(isAnimating ? 1 : 0)
                
                Text("How many hours do you\nspend on your phone per day?")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(spacing: 10) {
                    Picker("Hours Per Day", selection: $hoursPerDay) {
                        ForEach(0...24, id: \.self) { hour in
                            Text("\(hour) hours")
                                .tag(Double(hour))
                                .foregroundColor(.black)
                                .font(.system(size: 16, design: .monospaced))
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 150, height: 100)
                    .overlay(
                                  ZStack {
                                      // Left curved line
                                      Path { path in
                                          path.move(to: CGPoint(x: -75, y: -50))
                                          path.addCurve(
                                              to: CGPoint(x: -75, y: 50),
                                              control1: CGPoint(x: -85, y: -30),
                                              control2: CGPoint(x: -85, y: 30)
                                          )
                                      }
                                      .offset(x: 9)
                                      .stroke(earthColor, lineWidth: 1.5)

                                      // Right curved line
                                      Path { path in
                                          path.move(to: CGPoint(x: 75, y: -50))
                                          path.addCurve(
                                              to: CGPoint(x: 75, y: 50),
                                              control1: CGPoint(x: 85, y: -30),
                                              control2: CGPoint(x: 85, y: 30)
                                          )
                                      }
                                      .offset(x: -9)
                                      .stroke(earthColor, lineWidth: 1.5)
                                  }
                                .offset(x: 75, y: 50)
                              )
                }
                
                VStack(spacing: 15) {
                    Text("Your yearly screen time:")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text("\(Int(hoursPerYear)) hours")
                        .font(.title2).bold()
                        .foregroundColor(.red)
                    
                    InfoBox(
                        title: "Average user's yearly screen time:",
                        value: "813 hours",
                        valueColor: .green,
                        setColor: .green
                    )
                }
                .padding(.vertical)
                
                Button(action: {
                    triggerHapticFeedback()
                    path.append("analysis")
                }) {
                    Text("See Results")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color("lime"))
                        .cornerRadius(28)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .transition(.opacity)
            }
        }
    }
    
    private func nextQuestion() {
        let index = currentStep - 5
        if index >= 0 && index < selectedAnswers.count && selectedAnswers[index] == -1 {
            selectedAnswers[index] = 3
        }
        
        withAnimation(.easeInOut(duration: 0.5)) {
            if currentStep < 11 {
                currentStep += 1
            } else {
                path.append("analysis")
            }
        }
    }
    
    private func skipQuestion() {
        let index = currentStep - 5
        if index >= 0 && index < selectedAnswers.count && selectedAnswers[index] == -1 {
            withAnimation(.easeInOut(duration: 0.5)) {
                opacity = 0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                selectedAnswers[index] = 3
                nextQuestion()
            }
        } else if currentStep < 11 {
            nextQuestion()
        } else {
            path.append("analysis")
        }
    }
    
    private func animateTransition() {
        withAnimation(.easeInOut(duration: 0.3)) {
            opacity = 0
            offset = -50
            isAnimating = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            offset = 50
            withAnimation(.easeInOut(duration: 0.5)) {
                offset = 0
                opacity = 1
                isAnimating = true
            }
        }
    }
}
// MARK: - Preview

struct SurveyView_Previews: PreviewProvider {
    static var previews: some View {
        SurveyView(
            currentStep: .constant(11),
            earthColor: Color("earth"),
            onComplete: {}
        )
    }
}


private func triggerHapticFeedback() {
    let generator = UIImpactFeedbackGenerator(style: .light)
    generator.impactOccurred()
}

