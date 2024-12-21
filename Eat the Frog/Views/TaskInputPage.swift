import SwiftUI

struct TaskInputPage: View {
    @ObservedObject var viewModel: TaskViewModel
    @State private var taskName: String = ""
    @State private var deadline: Date = Date()
    @State private var selectedDuration: Int? = nil // Selected duration in hours
    @State private var hasDeadlineChanged: Bool = false // Track if the user has changed the deadline
    @FocusState private var isTaskNameFocused: Bool // Manage TextField focus state
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            // Set the background color to "ghost"
            Color("ghost").ignoresSafeArea()

            VStack(spacing: 20) {
                HStack {
                    Button(action: {
                        dismissKeyboard() // Dismiss the keyboard
                        presentationMode.wrappedValue.dismiss()
                        triggerHapticFeedback()
                    }) {
                        HStack {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 18, weight: .medium))
                        }
                        .foregroundColor(Color("earth"))
                    }
                    Spacer()
                }
                .padding(.leading)
                .padding(.top)

                Text("Set Your Frog")
                    .font(.system(size: 40, weight: .regular, design: .monospaced))
                    .padding(.top)

                TextField("Enter your task name...", text: $taskName)
                               .focused($isTaskNameFocused)
                               .textFieldStyle(RoundedBorderTextFieldStyle())
                               .padding()
                               .onTapGesture {
                                   isTaskNameFocused = true
                               }
                // Preset Durations Picker
                VStack(alignment: .leading, spacing: 10) {
                    Text("Select Deadline:")
                        .font(.system(size: 16, weight: .regular, design: .monospaced))

                    HStack {
                        ForEach([1, 2, 5, 12, 24], id: \.self) { duration in
                            Button(action: {
                                setPresetDuration(duration)
                            }) {
                                Text("\(duration) \(duration == 1 ? " Hr" : "     Hrs")")
                                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                                    .padding()
                                    .background(selectedDuration == duration ? Color("lime") : Color.gray.opacity(0.2))
                                    .foregroundColor(selectedDuration == duration ? .white : .black)
                                    .cornerRadius(10)
                            }
                        }
                    }
                }
                .padding(.horizontal)

                // Deadline Picker
                DatePicker(
                    "Set Custom Deadline:",
                    selection: $deadline,
                    displayedComponents: [.hourAndMinute]
                )
                .font(.system(size: 16, weight: .regular, design: .monospaced))
                .padding(.horizontal, 25)

                // Save Task Button
                Button(action: {
                    dismissKeyboard() // Dismiss the keyboard
                    triggerHapticFeedback()
                    saveTask()
                    SoundPlayer.shared.playSound("ribbit", withExtension: "mp3", volume: 0.3)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Save Task")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(taskName.isEmpty || (!hasDeadlineChanged && selectedDuration == nil) ? Color.gray : Color("lime"))
                        .cornerRadius(12)
                        .opacity(taskName.isEmpty || (!hasDeadlineChanged && selectedDuration == nil) ? 0.6 : 1.0)
                }
                .disabled(taskName.isEmpty || (!hasDeadlineChanged && selectedDuration == nil))

                Spacer()
            }
            .padding()
            .navigationBarHidden(true)
        }
        .onChange(of: viewModel.isTaskInputActive) { oldValue, newValue in
                    if !newValue {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
    }

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    private func setPresetDuration(_ hours: Int) {
        selectedDuration = hours
        deadline = Date().addingTimeInterval(TimeInterval(hours * 3600))
        hasDeadlineChanged = true
    }

    private func saveTask() {
        if !taskName.isEmpty {
            viewModel.taskName = taskName
            let currentTime = Date()
            viewModel.remainingTime = max(0, deadline.timeIntervalSince(currentTime))
            viewModel.totalTime = viewModel.remainingTime
            viewModel.startTask()
        }
    }
}

private func triggerHapticFeedback() {
    let generator = UIImpactFeedbackGenerator(style: .light)
    generator.impactOccurred()
}


struct TaskInputPage_Previews: PreviewProvider {
    static var previews: some View {
        TaskInputPage(viewModel: TaskViewModel())
    }
}

