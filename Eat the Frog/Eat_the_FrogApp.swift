import SwiftUI
import ManagedSettings
import ManagedSettingsUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct EatTheFrogApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var viewModel = TaskViewModel()
    @StateObject private var settingsViewModel = SettingsViewModel()
    @State private var selectedTab: Int = 0
    
    

    var body: some Scene {
        WindowGroup {
            TabView(selection: $selectedTab) {
                // Task Page
                buildTaskView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    .tag(0)

                // Settings Page
                buildSettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
                    .tag(1)

                // About Us Page
                buildAboutUsView()
                    .tabItem {
                        Label("About", systemImage: "info.circle")
                    }
                    .tag(2)
            }
            .accentColor(Color("earth")) // Replace "earth" with your custom color if necessary
            .preferredColorScheme(.light)
            .onChange(of: selectedTab) { oldValue, newValue in
                // Delay the dismissal by 1 second (or your desired duration)
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
    }
    
    private func checkFrogStatus() {
           let dailyFrogRequired = UserDefaults.standard.bool(forKey: "isDailyFrogRequired")
           
           // If daily frog is required and the user hasn't done today’s frog,
           // then block apps again.
           if dailyFrogRequired && !viewModel.hasCompletedFrogToday {
               viewModel.blockApps()
           } else {
               // If user has completed it (or daily frog not required), unblock.
               viewModel.unblockApps()
           }
       }

    @ViewBuilder
    private func buildTaskView() -> some View {
        TaskInputView(viewModel: viewModel)
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
