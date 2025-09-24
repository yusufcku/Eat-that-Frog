import SwiftUI

struct StreakBlockView: View {
    @ObservedObject var viewModel: TaskViewModel
    @State private var isInfoPresented = false

    private func flameColor() -> AnyView {
        if viewModel.streakCount >= 15 {
            // Rainbow flame using LinearGradient
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
        ZStack(alignment: .topTrailing) {
            HStack(spacing: 0) {
                flameColor()
                    .padding(.leading, 30)

                Spacer()

                VStack(spacing: 5) {
                    Text("\(viewModel.streakCount)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color("earth"), Color("lime")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .animation(.easeInOut(duration: 0.3))
                    Text("Day Streak")
                        .font(.system(size: 14, weight: .regular, design: .monospaced))
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(spacing: 5) {
                    Text("\(viewModel.taskCompletionHistory.count)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color("earth"), Color("lime")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    Text("Frogs Eaten")
                        .font(.system(size: 14, weight: .regular, design: .monospaced))
                        .foregroundColor(.secondary)
                }
                .padding(.trailing, 65)
            }
            
            Button(action: {
                isInfoPresented.toggle()
            }) {
                Image(systemName: "info.circle")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.blue.opacity(0.6))
            }
            .padding([.top, .trailing], 10)
        }
        .padding(.vertical, 10)
        .background(Color("ghost"))
        .cornerRadius(12)
        .sheet(isPresented: $isInfoPresented) {
            ZStack {
                Color("ghost").edgesIgnoringSafeArea(.all)

                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            isInfoPresented = false
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.secondary)
                                .padding()
                        }
                    }

                    StreakInfoView()

                    Spacer()
                }
            }
        }
    }
}

struct StreakBlockView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            StreakBlockView(viewModel: {
                let viewModel = TaskViewModel()
                viewModel.streakCount = 1
                return viewModel
            }())
            .previewDisplayName("Streak: 1 (Orange Flame)")

            StreakBlockView(viewModel: {
                let viewModel = TaskViewModel()
                viewModel.streakCount = 5
                return viewModel
            }())
            .previewDisplayName("Streak: 5 (Red Flame)")

            StreakBlockView(viewModel: {
                let viewModel = TaskViewModel()
                viewModel.streakCount = 10
                return viewModel
            }())
            .previewDisplayName("Streak: 10 (Purple Flame)")

            StreakBlockView(viewModel: {
                let viewModel = TaskViewModel()
                viewModel.streakCount = 15
                return viewModel
            }())
            .previewDisplayName("Streak: 15 (Rainbow Flame)")
        }
        .background(Color("ghost"))
        .previewLayout(.sizeThatFits)
    }
}

