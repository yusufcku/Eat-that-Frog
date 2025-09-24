import SwiftUI
import AVFoundation
import ConfettiSwiftUI

struct TaskInputView: View {
    @ObservedObject var viewModel: TaskViewModel
    @State private var deadline: Date = Date()
    @State private var confettiCounter = 0
    @State private var isBreathingPagePresented = false
    @State private var isBreathingExerciseEnabled = UserDefaults.standard.bool(forKey: "isBreathingExerciseEnabled")

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack(alignment: .top) {
                    Color("ghost").edgesIgnoringSafeArea(.all)
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 20) {
                            TimerBlockView(viewModel: viewModel)
                                .padding(.top, -135)
                            StreakBlockView(viewModel: viewModel)
                            if viewModel.isTaskStarted {
                                CompletedTaskCard(viewModel: viewModel, confettiCounter: $confettiCounter, isBreathingPagePresented: $isBreathingPagePresented)
                            } else {
                                taskInputCard()
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, geometry.safeAreaInsets.top + 120)
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
                    .zIndex(2)
                    ZStack {
                        Color("earth")
                            .ignoresSafeArea(edges: .horizontal)
                            .frame(height: 120)
                    }
                    .zIndex(1)
                    ZStack {
                        Color("earth")
                            .ignoresSafeArea(edges: .top)
                            .frame(height: 40)
                        HStack(spacing: 4) {
                            Text("Eat")
                                .font(.system(size: 22, weight: .regular, design: .monospaced))
                                .foregroundColor(.white)
                            Text("that")
                                .font(.system(size: 22, weight: .regular, design: .monospaced))
                                .foregroundColor(.white)
                                .padding(.leading, -1)
                            Text("Frog")
                                .font(.system(size: 22, weight: .bold, design: .default))
                                .foregroundColor(.white)
                        }
                    }
                    .zIndex(3)
                }
            }
        }
    }

    func taskInputCard() -> some View {
        VStack(spacing: 20) {
            Text("What's your frog today?")
                .font(.system(size: 20, weight: .regular, design: .monospaced))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            NavigationLink(destination: TaskInputPage(viewModel: viewModel)) {
                Text("Set Your Frog")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .frame(height: 45)
                    .background(Color("lime"))
                    .cornerRadius(30)
                    .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 2)
            }
            .simultaneousGesture(
                TapGesture().onEnded {
                    viewModel.isTaskInputActive = true
                    triggerHapticFeedback()
                }
            )
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 2)
    }
}
    private func triggerHapticFeedback() {
           let generator = UIImpactFeedbackGenerator(style: .light)
           generator.impactOccurred()
       }


struct TaskInputView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Case: 2-Day Streak
            TaskInputView(viewModel: {
                let viewModel = TaskViewModel()
                viewModel.streakCount = 2
                viewModel.taskCompletionHistory = generateTaskCompletionHistory(for: 2)
                return viewModel
            }())
            .previewDisplayName("2-Day Streak")

            // Case: 5-Day Streak
            TaskInputView(viewModel: {
                let viewModel = TaskViewModel()
                viewModel.streakCount = 5
                viewModel.taskCompletionHistory = generateTaskCompletionHistory(for: 5)
                return viewModel
            }())
            .previewDisplayName("5-Day Streak")

            // Case: 10-Day Streak
            TaskInputView(viewModel: {
                let viewModel = TaskViewModel()
                viewModel.streakCount = 10
                viewModel.taskCompletionHistory = generateTaskCompletionHistory(for: 10)
                return viewModel
            }())
            .previewDisplayName("10-Day Streak")

            // Case: 15-Day Streak
            TaskInputView(viewModel: {
                let viewModel = TaskViewModel()
                viewModel.streakCount = 15
                viewModel.taskCompletionHistory = generateTaskCompletionHistory(for: 15)
                return viewModel
            }())
            .previewDisplayName("15-Day Streak")

            // Case: Task Already Inputted
            TaskInputView(viewModel: {
                let viewModel = TaskViewModel()
                viewModel.taskName = "Finish SwiftUI Project"
                viewModel.totalTime = 3600 // Set a 1-hour task
                viewModel.remainingTime = 1800 // 30 minutes remaining
                viewModel.isTaskStarted = true
                return viewModel
            }())
            .previewDisplayName("Task Already Inputted")
        }
    }

    /// Helper function to generate a streak history
    private static func generateTaskCompletionHistory(for days: Int) -> [Date] {
        var history: [Date] = []
        for dayOffset in 1...days {
            let date = Calendar.current.date(byAdding: .day, value: -dayOffset, to: Date())!
            history.append(date)
        }
        return history
    }
}
