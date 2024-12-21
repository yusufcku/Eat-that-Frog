import SwiftUI

struct StreakBlockView: View {
    @ObservedObject var viewModel: TaskViewModel
    @State private var isInfoPresented = false

    private func flameColor() -> AnyView {
        if viewModel.streakCount >= 15 {
            // Rainbow flame using AngularGradient
            return AnyView(
                LinearGradient(
                    gradient: Gradient(colors: [.red, .orange, .yellow, .green, .blue, .purple]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .mask(
                    Image(systemName: "flame.fill")
                        .resizable()
                        .scaledToFit()
                )
                .frame(width: 40, height: 40)
            )
        } else if viewModel.streakCount >= 10 {
            // Purple flame
            return AnyView(
                Image(systemName: "flame.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.purple)
                    .frame(width: 40, height: 40)
            )
        } else if viewModel.streakCount >= 5 {
            // Red flame
            return AnyView(
                Image(systemName: "flame.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.red)
                    .frame(width: 40, height: 40)
            )
        } else {
            // Default orange flame
            return AnyView(
                Image(systemName: "flame.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.orange)
                    .frame(width: 40, height: 40)
            )
        }
    }

    var body: some View {
        ZStack(alignment: .topTrailing) { // Use ZStack to overlay the info button
            VStack(spacing: 10) {
                HStack {
                    flameColor()
    

                    VStack(alignment: .leading, spacing: 5) {
                        Text(" Keep Your Streak Alive!")
                            .font(.headline)
                            .foregroundColor(.black)

                        if viewModel.streakCount > 1 {
                            Text("🎉 You're on a \(viewModel.streakCount)-day streak!")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        } else if viewModel.streakCount == 1 {
                            Text("🔥 Great start!")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        } else {
                            Text("✨ Get your streak started!")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }

                    Spacer()

                    // Info button in the top-right corner
                    Button(action: {
                        isInfoPresented.toggle()
                    }) {
                        Image(systemName: "info.circle")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(Color.blue.opacity(0.6))
                      
            
                    }
                }
                .padding(.bottom, -5)
                .padding()

                Divider()

                HStack {
                    VStack(spacing: 5) {
                        Text("\(viewModel.streakCount)")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(Color("lime"))
                            .animation(.easeInOut(duration: 0.3))
                        Text("Day Streak")
                            .font(.system(size: 15, weight: .regular, design: .monospaced))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)

                    VStack(spacing: 5) {
                        Text("\(viewModel.taskCompletionHistory.count)")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(Color("lime"))
                        Text("Frogs Eaten")
                            .font(.system(size: 15, weight: .regular, design: .monospaced))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(.top, -13)
                .padding()
            }
            .frame(maxWidth: .infinity) // Ensure it stretches to fill the horizontal space
                   .padding(.horizontal)      // Add consistent horizontal padding
                   .background(Color.white)   // Match the background color
                   .cornerRadius(12)          // Match the corner radius of other blocks
                   .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 2) // Add shadow
        }
        .fullScreenCover(isPresented: $isInfoPresented) { // Full-screen modal
            ZStack {
                Color.white.edgesIgnoringSafeArea(.all) // Background color

                VStack {
                    Spacer() // Push content and button down

                    HStack {
                        Spacer()

                        // Close button
                        Button(action: {
                            isInfoPresented = false
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.gray)
                                .padding()
                        }
                        .padding(.bottom, -30) // Adjust button's position from the bottom
                    }

                    Spacer()

                    StreakInfoView() // Use your existing StreakInfoView
                        .padding()
                }
            }
        }

    }
}

struct StreakBlockView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Test for streak < 5 (Orange Flame)
            StreakBlockView(viewModel: {
                let viewModel = TaskViewModel()
                viewModel.streakCount = 1
                return viewModel
            }())
            .previewDisplayName("Streak: 3 (Orange Flame)")

            // Test for streak >= 5 (Red Flame)
            StreakBlockView(viewModel: {
                let viewModel = TaskViewModel()
                viewModel.streakCount = 5
                return viewModel
            }())
            .previewDisplayName("Streak: 5 (Red Flame)")

            // Test for streak >= 10 (Purple Flame)
            StreakBlockView(viewModel: {
                let viewModel = TaskViewModel()
                viewModel.streakCount = 10
                return viewModel
            }())
            .previewDisplayName("Streak: 10 (Purple Flame)")

            // Test for streak >= 15 (Rainbow Flame)
            StreakBlockView(viewModel: {
                let viewModel = TaskViewModel()
                viewModel.streakCount = 15
                return viewModel
            }())
            .previewDisplayName("Streak: 15 (Rainbow Flame)")
        }
    }
}
