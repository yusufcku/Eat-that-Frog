import SwiftUI

    struct TimerBlockView: View {
        @ObservedObject var viewModel: TaskViewModel

        var body: some View {
            VStack(spacing: 20) {
                ZStack {
                    // Background Circle
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 10)

                    // Foreground Circle (Green Progress Bar)
                    Circle()
                        .trim(from: 0.0, to: CGFloat(progress()))
                        .stroke(
                            Color.green,
                            style: StrokeStyle(lineWidth: 10, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90)) // Start progress at the top
                        .animation(.linear(duration: 0.2), value: viewModel.remainingTime)

                    // Frog Image
                    Image("frog")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                }
                .frame(width: 150, height: 150)

                // Task and Time Information
                VStack(spacing: 8) {
                    if viewModel.isTaskStarted {
                        Text("currently working on:")
                            .font(.system(size: 17, weight: .regular, design: .monospaced))
                            .foregroundColor(.gray)
                        
                        Text(viewModel.taskName.isEmpty ? "Unnamed Task" : viewModel.taskName)
                                    .font(.headline)
                                    .foregroundColor(.primary)

                        Text("Time Remaining: \(formattedTime(viewModel.remainingTime))")
                            .font(.subheadline)
                            .foregroundColor(Color("coolgrey"))
                    } else {
                        Text("no active task")
                            .font(.system(size: 17, weight: .regular, design: .monospaced))
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity) 
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 2)
        }

        // Calculate progress for the green bar
        func progress() -> Double {
            if !viewModel.isTaskStarted || viewModel.totalTime == 0 {
                return 0.0 // Return 0 if no task is active
            }
            return 1.0 - (viewModel.remainingTime / viewModel.totalTime)
        }


        // Format remaining time as HH:MM:SS or MM:SS
        func formattedTime(_ time: TimeInterval) -> String {
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



struct TimerBlockView_Previews: PreviewProvider {
    static var previews: some View {
        TimerBlockView(viewModel: TaskViewModel()) // Pass a sample ViewModel
    }
}
