import SwiftUI

struct TaskInputPage: View {
    @ObservedObject var viewModel: TaskViewModel
    @Binding var isPresented: Bool
    @State private var taskName: String = ""
    @State private var selectedDuration: TimeInterval = 1200 // 20 minutes default
    @State private var showDurationPicker = false
    @State private var showBlockList = false
    @State private var rewardTime: TimeInterval = 300 // 5 minutes default
    @State private var showRewardPicker = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Top spacer with rounded corners
                Color.clear
                    .frame(height: 64)
                    .background(
                        Color("ghost")
                    )
                    .cornerRadius(25)
                ZStack {
                    Color("ghost").edgesIgnoringSafeArea(.all)
                    
                    VStack(spacing: 24) {
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Text("Set Your Frog")
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                Spacer()
                                Button(action: {
                                    isPresented = false
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top)
                            .padding(.leading, 5)
                            
                            TextField("What's your frog?", text: $taskName)
                                .font(.system(size: 18))
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(25)
                                .padding(.horizontal)
                            
                            // Duration Button
                            Button(action: { showDurationPicker = true }) {
                                HStack {
                                    Image(systemName: "clock")
                                        .font(.system(size: 20))
                                        .foregroundColor(Color("lime"))
                                    Text("Duration")
                                        .font(.system(size: 18))
                                        .foregroundColor(Color("earth"))
                                    Spacer()
                                    Text(formatDuration(selectedDuration))
                                        .foregroundColor(Color("lime"))
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color("lime"))
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(25)
                                .padding(.horizontal)
                            }
                            .sheet(isPresented: $showDurationPicker) {
                                CustomDurationPicker(duration: $selectedDuration, isPresented: $showDurationPicker)
                                    .presentationDetents([.height(400)])
                            }
                            
                            // Reward Time Button
                            Button(action: { showRewardPicker = true }) {
                                HStack {
                                    Image(systemName: "gift")
                                        .font(.system(size: 20))
                                        .foregroundColor(Color("lime"))
                                    Text("Reward Time")
                                        .font(.system(size: 18))
                                        .foregroundColor(Color("earth"))
                                    Spacer()
                                    Text(formatDuration(rewardTime))
                                        .foregroundColor(Color("lime"))
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color("lime"))
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(25)
                                .padding(.horizontal)
                            }
                            .sheet(isPresented: $showRewardPicker) {
                                CustomDurationPicker(duration: $rewardTime, isPresented: $showRewardPicker)
                                    .presentationDetents([.height(400)])
                            }
                            
                            // Apps Blocked Button
                            Button(action: { showBlockList = true }) {
                                HStack {
                                    Image(systemName: "shield")
                                        .font(.system(size: 20))
                                        .foregroundColor(Color("lime"))
                                    Text("Apps Blocked")
                                        .font(.system(size: 18))
                                        .foregroundColor(Color("earth"))
                                    Spacer()
                                    Circle()
                                        .fill(.red)
                                        .frame(width: 8, height: 8)
                                    Text("Block List")
                                        .foregroundColor(Color("lime"))
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color("lime"))
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(25)
                                .padding(.horizontal)
                            }
                            
                            // Schedule for Later Button
                            Button(action: {}) {
                                HStack {
                                    Image(systemName: "calendar")
                                        .font(.system(size: 20))
                                        .foregroundColor(Color("lime"))
                                    Text("Schedule for later")
                                        .font(.system(size: 18))
                                        .foregroundColor(Color("earth"))
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color("lime"))
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(25)
                                .padding(.horizontal)
                            }
                        }
                        
                        Spacer()
                        
                        // Start Session Button
                        Button(action: {
                            saveTask()
                            isPresented = false
                        }) {
                            Text("Start Task")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color("lime"))
                                .cornerRadius(30)
                                .shadow(
                                    color: Color("lime").opacity(0.5),
                                    radius: 20,
                                    x: 0,
                                    y: 10
                                )
                        }
                        .padding(.horizontal)
                        .disabled(taskName.isEmpty)
                        .opacity(taskName.isEmpty ? 0.6 : 1)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }
    
    private func saveTask() {
        if !taskName.isEmpty {
            viewModel.taskName = taskName
            viewModel.remainingTime = selectedDuration
            viewModel.totalTime = selectedDuration
            viewModel.startTask()
        }
    }
}

struct CustomDurationPicker: View {
    @Binding var duration: TimeInterval
    @Binding var isPresented: Bool
    @State private var hours: Int = 0
    @State private var minutes: Int = 20
    
    var body: some View {
        ZStack {
            Color("ghost").edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("Duration")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.black)
                
                Text("Select a deadline for your frog.")
                    .font(.system(size: 17))
                    .foregroundColor(.gray)
                    .padding(.bottom, 20)
                
                HStack(spacing: 0) {
                    Picker("Hours", selection: $hours) {
                        ForEach(0..<24) { hour in
                            Text("\(hour)")
                                .tag(hour)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 100)
                    .clipped()
                    .compositingGroup()
                    
                    Text("hours")
                        .foregroundColor(.black)
                        .padding(.trailing, 20)
                    
                    Picker("Minutes", selection: $minutes) {
                        ForEach(0..<60) { minute in
                            Text("\(minute)")
                                .tag(minute)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 100)
                    .clipped()
                    .compositingGroup()
                    
                    Text("minutes")
                        .foregroundColor(.black)
                }
                .padding(.horizontal)
                
                HStack(spacing: 20) {
                    Button(action: {
                        hours = 0
                        minutes = 0
                    }) {
                        Text("Always On")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(25)
                    }
                    
                    Button(action: {
                        duration = TimeInterval(hours * 3600 + minutes * 60)
                        isPresented = false
                    }) {
                        Text("Confirm")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("lime"))
                            .cornerRadius(25)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 30)
            }
            .padding()
        }
        .onAppear {
            hours = Int(duration) / 3600
            minutes = (Int(duration) % 3600) / 60
        }
    }
}

struct TaskInputPage_Previews: PreviewProvider {
    static var previews: some View {
        TaskInputPage(viewModel: TaskViewModel(), isPresented: .constant(true))
            .preferredColorScheme(.light)
    }
}

