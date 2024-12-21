import SwiftUI
import FamilyControls
import ManagedSettings

class SettingsViewModel: ObservableObject {
    @Published var activitySelection = FamilyActivitySelection()
    @Published var blockedApps: [String] = []

    init() {
        loadBlockedApps()
    }

    func updateBlockedAppsFromSelection() {
        var appData = [String: String]()
        for token in activitySelection.applicationTokens {
            if let tokenData = try? JSONEncoder().encode(token) {
                let tokenKey = tokenData.base64EncodedString()
                // Map token to app name. You can enhance this logic:
                let appName = "Placeholder Name"
                appData[tokenKey] = appName
            }
        }
        UserDefaults.standard.set(appData, forKey: "BlockedAppData")
        blockedApps = Array(appData.values)
        print("Blocked apps saved:", appData)
    }

    func loadBlockedApps() {
        guard let savedAppData = UserDefaults.standard.dictionary(forKey: "BlockedAppData") as? [String: String] else {
            print("No blocked apps found in UserDefaults.")
            return
        }

        blockedApps = Array(savedAppData.values)

        let restoredTokens = savedAppData.keys.compactMap { key -> ApplicationToken? in
            guard let tokenData = Data(base64Encoded: key) else { return nil }
            return try? JSONDecoder().decode(ApplicationToken.self, from: tokenData)
        }
        activitySelection.applicationTokens = Set(restoredTokens)
        print("Loaded blocked apps:", blockedApps)
    }
}
