import SwiftUI

struct TaskInputView1: View {
    @ObservedObject var viewModel: TaskViewModel
    @State private var glowIntensity: CGFloat = 0.85
    @State private var scrollOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Background
            Color("ghost").edgesIgnoringSafeArea(.all)
            
            // Content
            ScrollView {
                VStack(spacing: 20) {
                    // Spacer for fixed header
                    Color.clear.frame(height: 60)
                    
                    // Timer Display with Green Glow
                    ZStack {
                        // Green Glow Effect
                        Circle()
                            .fill(Color("lime").opacity(0.75))
                            .frame(width: glowSize, height: glowSize)
                            .blur(radius: 50)
                            .opacity(glowOpacity)
                        
                        // Timer Display
                        VStack(spacing: 4) {
                            Text(formattedTime(viewModel.remainingTime))
                                .font(.system(size: 72, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text(viewModel.taskName.isEmpty ? "Input task name here" : viewModel.taskName)
                                .font(.system(size: 18, weight: .regular))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .frame(height: 210)
                    .animation(.easeInOut(duration: 1), value: viewModel.isTaskStarted)
                    .zIndex(1)
                    
                    // Monthly Streak View
                    MonthlyStreakView()
                        .padding(.horizontal)
                        .padding(.top, 60)
                    
                    // Streak Block View
                    StreakBlockView(viewModel: viewModel)
                        .padding(.horizontal)
                    
                    Spacer()
                        .frame(height: 100)
                }
                .background(GeometryReader {
                    Color.clear.preference(key: ScrollOffsetPreferenceKey.self,
                                           value: -$0.frame(in: .named("scroll")).origin.y)
                })
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                    self.scrollOffset = value
                }
            }
            .coordinateSpace(name: "scroll")
            .scrollIndicators(.hidden)
            
            // Fixed Header
            VStack {
                HStack {
                    // App Title
                    HStack(spacing: 4) {
                        Text("Eat")
                            .font(.system(size: 22, weight: .regular, design: .monospaced))
                        Text("that")
                            .font(.system(size: 22, weight: .regular, design: .monospaced))
                            .padding(.leading, -1)
                        Text("Frog")
                            .font(.system(size: 22, weight: .bold, design: .default))
                    }
                    
                    Spacer()
                    
                    // Get PRO Button
                    Button(action: {
                        // Handle PRO upgrade
                        triggerHapticFeedback()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "sparkles")
                            Text("Get PRO")
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color("lime"))
                        .cornerRadius(15)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .background(
                    Color("ghost")
                        .opacity(scrollOffset > 0 ? 1 : 0)
                        .animation(.easeInOut(duration: 0.3), value: scrollOffset > 0)
                )
                
                Spacer()
            }
            
            // Fixed Bottom Button with enhanced glow
            VStack {
                Spacer()
                Button(action: {
                    viewModel.isTaskInputActive = true
                    triggerHapticFeedback()
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                        Text("Set Your Frog")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color("lime"))
                    .cornerRadius(30)
                    .shadow(
                        color: Color("lime").opacity(0.5),
                        radius: 20,
                        x: 0,
                        y: 10
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color("earth").opacity(0.4), lineWidth: 1)
                            .blur(radius: 2)
                            .shadow(
                                color: Color("lime").opacity(1),
                                radius: 10,
                                x: 0,
                                y: 0
                            )
                    )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .sheet(isPresented: $viewModel.isTaskInputActive) {
                TaskInputPage(viewModel: viewModel, isPresented: $viewModel.isTaskInputActive)
                    .presentationDetents([.height(520)])
                    .presentationDragIndicator(.visible)
                    .transition(.move(edge: .bottom))
                
            }
        }
    }
    
    
    private var glowSize: CGFloat {
        let baseSize: CGFloat = 300
        let shrinkFactor = viewModel.isTaskStarted ? CGFloat(viewModel.remainingTime / viewModel.totalTime) : 1
        return baseSize * shrinkFactor
    }
    
    private var glowOpacity: Double {
        guard viewModel.isTaskStarted else { return 0.75 }
        return 0.75 + (0.25 * sin(Date().timeIntervalSince1970 * 2))
    }
    
    private func triggerHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    private func formattedTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        let seconds = Int(time) % 60

        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

struct TaskInputView1_Previews: PreviewProvider {
    static var previews: some View {
        TaskInputView1(viewModel: TaskViewModel())
    }
}

