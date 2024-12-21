import SwiftUI
import FamilyControls
import ManagedSettings

struct SettingsView: View {
    @State private var isInfoPresented = false
    @State private var isInfoPresented1 = false
    @EnvironmentObject private var viewModel: TaskViewModel
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @State private var isPressed = false
    @State private var authorizationStatus = AuthorizationCenter.shared.authorizationStatus
    @State private var showAppPicker = false
    @State private var isBreathingExerciseEnabled: Bool = {
        if UserDefaults.standard.object(forKey: "isBreathingExerciseEnabled") == nil {
            UserDefaults.standard.set(true, forKey: "isBreathingExerciseEnabled")
            return true
        } else {
            return UserDefaults.standard.bool(forKey: "isBreathingExerciseEnabled")
        }
    }()
    
    @State private var isDailyFrogRequired: Bool = {
        let key = "isDailyFrogRequired"
        if UserDefaults.standard.object(forKey: key) == nil {
            UserDefaults.standard.set(false, forKey: key)
            return true
        } else {
            return UserDefaults.standard.bool(forKey: key)
        }
    }()
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack(alignment: .top) {
                    // Background
                    Color("ghost").edgesIgnoringSafeArea(.all)

                    // Scrollable Content
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 20) {
                            // Section for Blocked Apps
                            blockedAppsCard()
                                .padding(.top, -135)

                            // Toggle for Breathing Exercise
                            breathingExerciseToggle()
                            dailyFrogToggle()

                            // Section for Customization
                            customizationCard()
                        }
                        .padding(.horizontal)
                        .padding(.top, geometry.safeAreaInsets.top + 120)
                    }
                    .zIndex(2)

                    // Green Header
                    ZStack {
                        Color("earth")
                            .frame(height: 120)
                            .ignoresSafeArea(edges: .horizontal)
                    }
                    .zIndex(1)

                    // Smaller Fixed Header
                    ZStack {
                        Color("earth")
                            .ignoresSafeArea(edges: .top)
                            .frame(height: 40)

                        HStack(spacing: 4) {
                            Text("Settings")
                                .font(.system(size: 22, weight: .regular, design: .monospaced))
                                .foregroundColor(.white)
                        }
                    }
                    .zIndex(3)
                }
            }
        }
        .onAppear {
            requestNotificationPermissions()
            if authorizationStatus != .approved {
                authorizationStatus = AuthorizationCenter.shared.authorizationStatus
            }
            if settingsViewModel.blockedApps.isEmpty {
                print("SettingsView appeared, loaded apps: \(settingsViewModel.blockedApps)")
            }
            if isDailyFrogRequired && !viewModel.hasCompletedFrogToday {
                    viewModel.blockApps()
                }
        }

        .sheet(isPresented: $showAppPicker, onDismiss: {
            settingsViewModel.updateBlockedAppsFromSelection()
        }) {
            AppPickerView(activitySelection: $settingsViewModel.activitySelection)
        }
    }
    
    private func dailyFrogToggle() -> some View {
        VStack(alignment: .leading) {
            HStack {
                Toggle("Daily Frog Required", isOn: $isDailyFrogRequired)
                    .onChange(of: isDailyFrogRequired) { oldValue, newValue in
                        UserDefaults.standard.set(newValue, forKey: "isDailyFrogRequired")
                        triggerHapticFeedback()
                        print("Daily Frog Required: \(newValue)")
                        handleDailyFrogToggleChange(newValue: newValue)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: Color("lime")))

                // Info Button
                Button(action: {
                    isInfoPresented = true // Show the info modal
                }) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.blue)
                        .accessibilityLabel("What is Daily Frog Required?")
                }
                .padding(.leading, 8)
            }
            .padding()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 2)
        .sheet(isPresented: $isInfoPresented) { // Full-screen modal
            ZStack {
                Color.white.edgesIgnoringSafeArea(.all) // Background color

                VStack {
                    Text("Daily Frog Required")
                        .font(.system(size: 22, weight: .bold, design: .monospaced))
                        .padding()

                    Text("""
    This setting ensures that you complete the most important task of the day (your Frog) before other distractions. If enabled, all selected apps will be blocked from the beggining of the day (even if you didn't set a Frog) until you mark a Frog task as complete.
    """)
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding()

                    Spacer()

                    // Close Button
                    Button(action: {
                        isInfoPresented = false
                    }) {
                        Text("Close")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("lime"))
                            .cornerRadius(12)
                    }
                    .padding()
                }
                .padding()
            }
        }
    }


    private func breathingExerciseToggle() -> some View {
        VStack(alignment: .leading) {
            HStack {
                Toggle("Breathing Exercises", isOn: $isBreathingExerciseEnabled)
                    .onChange(of: isBreathingExerciseEnabled) { oldValue, newValue in
                        UserDefaults.standard.set(newValue, forKey: "isBreathingExerciseEnabled")
                        triggerHapticFeedback()
                        print("Breathing Exercise Enabled: \(newValue)")
                    }
                    .toggleStyle(SwitchToggleStyle(tint: Color("lime")))

                // Info Button
                Button(action: {
                    isInfoPresented1 = true // Show the info modal
                }) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.blue)
                        .accessibilityLabel("What are Breathing Exercises?")
                }
                .padding(.leading, 8)
            }
            .padding()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 2)
        .sheet(isPresented: $isInfoPresented1) { // Full-screen modal
            ZStack {
                Color.white.edgesIgnoringSafeArea(.all) // Background color

                VStack {
                    Text("Breathing Exercises")
                        .font(.system(size: 22, weight: .bold, design: .monospaced))
                        .padding()

                    Text("""
    This setting enables guided breathing exercises to help you stay mindful and true to your goals and self. When enabled, you will be prompted a short breathing excercise when trying to set a Frog as complete.
    """)
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding()

                    Spacer()

                    // Close Button
                    Button(action: {
                        isInfoPresented = false
                    }) {
                        Text("Close")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("lime"))
                            .cornerRadius(12)
                    }
                    .padding()
                }
                .padding()
            }
        }
    }


    func blockedAppsCard() -> some View {
        VStack {
            Text("Blocked Apps")
                .font(.system(size: 20, weight: .regular, design: .monospaced))
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            if settingsViewModel.activitySelection.applicationTokens.isEmpty {
                Text("No apps are currently blocked.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ScrollView {
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 3), // 3 columns
                        spacing: 20 // Space between rows
                    ) {
                        ForEach(Array(settingsViewModel.activitySelection.applicationTokens), id: \.self) { token in
                            VStack(spacing: 10) { // Stack icon and name vertically
                                // App icon
                                Label(token)
                                    .labelStyle(IconOnlyLabelStyle())
                                    .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 2)
                
                            
                                    .scaleEffect(2.5)

                                // App name below icon
                                Label(token)
                                    .labelStyle(TitleOnlyLabelStyle())
                                    .scaleEffect(0.6) // Increases the size of the icon

                            }
                        }
                    }
                    .padding()
                    .padding(.top, 20)
                }
                .frame(maxHeight: 300) // Constrain the scrollable area height
                .background(Color.white) // Keeps the list background clean
                .cornerRadius(12)
                .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 2)
            }

            Button(action: {
                handleSelectApps()
            }) {
                Text("Select Apps to Block")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .frame(height: 45)
                    .background(Color("lime"))
                    .cornerRadius(30)
                    .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 2)
            }
            .padding(.top, 10)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 2)
    }

    func customizationCard() -> some View {
        VStack {
            Text("Customization")
                .font(.system(size: 20, weight: .regular, design: .monospaced))
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Text("More settings will be available soon!")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding()

            Button(action: {
                print("Reset all settings to default!")
                triggerHapticFeedback()
            }) {
                Text("Reset to Default")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .frame(height: 45)
                    .background(Color.red)
                    .cornerRadius(30)
                    .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 2)
                    .scaleEffect(isPressed ? 0.98 : 1.0)
            }
            .onChange(of: isPressed) { oldValue, newValue in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0)) {
                        isPressed = false
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 2)
    }

    private func handleSelectApps() {
        if authorizationStatus == .approved {
            showAppPicker = true
        } else {
            requestAuthorization()
        }
    }
    
    private func requestNotificationPermissions() {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if let error = error {
                    print("Notification permission error: \(error.localizedDescription)")
                } else if granted {
                    print("Notification permissions granted.")
                } else {
                    print("Notification permissions denied.")
                }
            }
        }
    
    private func handleDailyFrogToggleChange(newValue: Bool) {
         if newValue {
             // Turned ON: If user hasn’t done the frog today, block immediately
             if !viewModel.hasCompletedFrogToday {
                 viewModel.blockApps()
             }
         } else {
             // Turned OFF: Unblock apps
             viewModel.unblockApps()
         }
     }
    
    private func requestAuthorization() {
        Task {
            do {
                try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                DispatchQueue.main.async {
                    authorizationStatus = AuthorizationCenter.shared.authorizationStatus
                    if authorizationStatus == .approved {
                        showAppPicker = true
                    } else {
                        print("Authorization not granted.")
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    print("Error requesting authorization: \(error.localizedDescription)")
                }
            }
        }
    }
}

private func triggerHapticFeedback() {
    let generator = UIImpactFeedbackGenerator(style: .light)
    generator.impactOccurred()
}


struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        let taskViewModel = TaskViewModel() // Create a mock or default instance
        let settingsViewModel = SettingsViewModel() // Create a mock or default instance

        return SettingsView()
            .environmentObject(taskViewModel) // Inject TaskViewModel as an environment object
            .environmentObject(settingsViewModel) // Inject SettingsViewModel as an environment object
    }
}
