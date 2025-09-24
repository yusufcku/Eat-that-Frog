import SwiftUI
import ManagedSettings
import ManagedSettingsUI
import BackgroundTasks

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Register the background task
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.eatthefrog.dailyreset", using: nil) { task in
            handleDailyResetTask(task: task as! BGAppRefreshTask)
        }
        
        return true
    }
}

@main
struct EatTheFrogApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var viewModel = TaskViewModel()
    @StateObject private var settingsViewModel = SettingsViewModel()
    @State private var selectedTab: Int = 0
    @Environment(\.scenePhase) var scenePhase
    @State private var showOnboarding: Bool = !UserDefaults.standard.hasCompletedOnboarding1 // Show onboarding on first launch
    
    var body: some Scene {
         WindowGroup {
             ZStack {
                 if showOnboarding {
                     // Onboarding
                     OnboardingView1(onComplete: {
                         UserDefaults.standard.hasCompletedOnboarding1 = true
                         // Animate the fade-out of onboarding & fade-in of main tab
                         withAnimation(.easeInOut(duration: 0.5)) {
                             showOnboarding = false
                         }
                     })
                     .transition(.opacity)
                     
                 } else {
                     // Main tab view
                     mainTabView
                         .transition(.opacity)
                 }
             }
             // This ensures SwiftUI knows to animate changes to showOnboarding
             .animation(.easeInOut, value: showOnboarding)
         }
     }
    
    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            // Task Page
            buildTaskView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            // About Us Page
            buildAboutUsView()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
                .tag(1)
            // Settings Page
            buildSettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(2)
        }
        .accentColor(Color("earth")) // Replace "earth" with your custom color if necessary
        .preferredColorScheme(.light)
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .background {
                viewModel.saveTimerState()
            } else if newPhase == .active {
                viewModel.resumeTimerIfNeeded()
                viewModel.checkForDailyReset()
            }
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                if newValue != 0 { // Assuming tab 0 is the Task tab
                    viewModel.isTaskInputActive = false
                    checkFrogStatus()
                }
            }
            triggerHapticFeedback()
        }
        .environmentObject(viewModel) // Pass viewModel as an environment object
        .environmentObject(settingsViewModel) // Pass settingsViewModel as an environment object
    }
    
    
    private func checkFrogStatus() {
        let dailyFrogRequired = UserDefaults.standard.bool(forKey: "isDailyFrogRequired")
        
        if dailyFrogRequired && !viewModel.hasCompletedFrogToday {
            viewModel.blockApps()
        }
    }

    @ViewBuilder
    private func buildTaskView() -> some View {
        TaskInputView1(viewModel: viewModel)
            .environmentObject(viewModel)
    }

    @ViewBuilder
    private func buildSettingsView() -> some View {
        SettingsView()
            .environmentObject(settingsViewModel)
            .environmentObject(viewModel)
    }

    @ViewBuilder
    private func buildAboutUsView() -> some View {
        AboutView()
    }

    private func triggerHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}


private func handleDailyResetTask(task: BGAppRefreshTask) {
    scheduleDailyReset() // Reschedule the task for the next day

    // Reset the frog state
    let currentDay = Calendar.current.startOfDay(for: Date())
    UserDefaults.standard.set(currentDay, forKey: "lastDailyReset")
    
    let dailyFrogRequired = UserDefaults.standard.bool(forKey: "isDailyFrogRequired")
    if dailyFrogRequired {
        let taskViewModel = TaskViewModel()
        if !taskViewModel.hasCompletedFrogToday {
            taskViewModel.blockApps()
        }
    }
    
    task.setTaskCompleted(success: true)
}

private func scheduleDailyReset() {
    let request = BGAppRefreshTaskRequest(identifier: "com.eatthefrog.dailyreset")
    request.earliestBeginDate = Calendar.current.startOfDay(for: Date().addingTimeInterval(86400)) // Next day start
    do {
        try BGTaskScheduler.shared.submit(request)
        print("Scheduled daily reset.")
    } catch {
        print("Failed to schedule daily reset: \(error)")
    }
}



