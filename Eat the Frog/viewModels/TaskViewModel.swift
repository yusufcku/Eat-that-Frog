import SwiftUI
import Combine
import ManagedSettings
import UserNotifications

class TaskViewModel: ObservableObject {
    @Published var taskName: String = "" {
        didSet { saveTaskData() }
    }
    @Published var totalTime: TimeInterval = 0 {
        didSet { saveTaskData() }
    }
    @Published var remainingTime: TimeInterval = 0 {
        didSet { saveTaskData() }
    }
    @Published var isTaskStarted: Bool = false {
        didSet { saveTaskData() }
    }
    @Published var streakCount: Int = 0 {
        didSet { saveTaskData() }
    }
    @Published var taskCompletionHistory: [Date] = [] {
        didSet { saveTaskData() }
    }
    
    @Published var isTaskInputActive: Bool = false
    
    
    @Published var response: String = "Completed!"
        private let responses = [
            "Frog Completed!",
            "Task Completed!",
            "Completed!",
            "Complete!",
            "Yes!",
            "Frog Conquered!",
            "Mission Accomplished!"
        ]
    
    @Published private var _isDailyFrogRequired: Bool = UserDefaults.standard.bool(forKey: "isDailyFrogRequired") {
        didSet {
            UserDefaults.standard.set(_isDailyFrogRequired, forKey: "isDailyFrogRequired")
        }
    }
    
    var isDailyFrogRequired: Bool {
        get { _isDailyFrogRequired }
        set { _isDailyFrogRequired = newValue }
    }
        
        func getRandomResponse() {
            response = responses.randomElement() ?? "Completed!"
        }

    private var timer: Timer?
    private var backgroundEntryTime: Date?
    private let store = ManagedSettingsStore()
  
    init() {
        loadTaskData()
        // Load data when the ViewModel is initialized
        
        if UserDefaults.standard.object(forKey: "isDailyFrogRequired") == nil {
              isDailyFrogRequired = true
          }
            if isDailyFrogRequired && !hasCompletedFrogToday {
                blockApps()
            }
        checkForDailyReset()
    }

    // Start the timer and mark the task as started
    func startTask() {
        guard totalTime > 0, remainingTime > 0 else { return }
        isTaskStarted = true
        startTimer()
        getRandomResponse()
        blockApps()
    }
    
    func scheduleNotification() {
        guard remainingTime > 0 else {
            print("Notification not scheduled. Invalid remainingTime: \(remainingTime)")
            return
        }

        print("Scheduling notification with remaining time: \(remainingTime) seconds")

        let content = UNMutableNotificationContent()
        content.title = "Your timer's up! 🕒"
        content.body = "Reset, refocus, and let’s try again! Set your frog again."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: remainingTime, repeats: false)

        let request = UNNotificationRequest(identifier: "TimeUpNotification", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled successfully.")
            }
        }
    }


    
    func blockApps() {
        let settingsViewModel = SettingsViewModel()
        let applications = settingsViewModel.activitySelection.applicationTokens
        
        store.shield.applications = applications.isEmpty ? nil : applications
    }


    func unblockApps() {
        // To unblock, simply set applications to nil (or an empty set)
        store.shield.applications = nil
    }


       
    // Stop the timer and reset the task state
    func stopTask() {
        timer?.invalidate()
        timer = nil
        isTaskStarted = false
        unblockApps()
    }

    // Initialize a task with a specific name and duration
    func initializeTask(name: String, duration: TimeInterval) {
        taskName = name
        totalTime = duration
        remainingTime = duration
        isTaskStarted = false
    }

    // Start the timer to decrement remainingTime
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.remainingTime > 0 {
                self.remainingTime -= 1
            } else {
                self.remainingTime = 1
                self.completeTask(isTaskCompleted: false)
            }
        }
    }
    
    func saveTimerState() {
           backgroundEntryTime = Date()
           UserDefaults.standard.set(remainingTime, forKey: "remainingTime")
           UserDefaults.standard.set(backgroundEntryTime, forKey: "backgroundEntryTime")
       }
    
    func resumeTimerIfNeeded() {
            guard isTaskStarted else { return }

            let savedRemainingTime = UserDefaults.standard.double(forKey: "remainingTime")
            let savedBackgroundEntryTime = UserDefaults.standard.object(forKey: "backgroundEntryTime") as? Date

            if let backgroundTime = savedBackgroundEntryTime {
                let elapsedTime = Date().timeIntervalSince(backgroundTime)
                remainingTime = max(0, savedRemainingTime - elapsedTime)

                if remainingTime > 0 {
                    startTimer() // Restart the timer if there's time left
                } else {
                    completeTask(isTaskCompleted: false) // Complete the task if time is up
                }
            }
        }
    
    func checkForDailyReset() {
        let currentDay = Calendar.current.startOfDay(for: Date())
        let lastResetDay = UserDefaults.standard.object(forKey: "lastDailyReset") as? Date ?? .distantPast
        
        if currentDay > lastResetDay {
            // A new day has begun. Mark "frog not completed" for today.
            // Option A: If you rely on `taskCompletionHistory`, no direct change is needed
            //           but you can do other daily resets if you have them.

            // Record we have reset for today
            UserDefaults.standard.set(currentDay, forKey: "lastDailyReset")
            
            // If user wants daily frog, block if not completed
            let dailyFrogRequired = UserDefaults.standard.bool(forKey: "isDailyFrogRequired")
            if dailyFrogRequired && !hasCompletedFrogToday {
                blockApps()
            }
        }
    }


    // Mark a task as completed
    func completeTask(isTaskCompleted: Bool) {
        stopTask()
        if isTaskCompleted {
            unblockApps()
            addTaskCompletion()// Unblock apps only if the task is explicitly completed
        } else {
            blockApps()
            scheduleNotification()
            // Keep apps blocked if the timer just runs out
        }
    }

    
  



    // Add a task completion to the history and update the streak count
    func addTaskCompletion() {
        let today = Calendar.current.startOfDay(for: Date())
        taskCompletionHistory.append(today)

        if let lastCompletion = taskCompletionHistory.dropLast().last {
            if Calendar.current.isDate(lastCompletion, inSameDayAs: today.addingTimeInterval(-86400)) {
                streakCount += 1
            } else if !Calendar.current.isDate(lastCompletion, inSameDayAs: today) {
                streakCount = 1
            }
        } else {
            streakCount = 1
        }
    }

    // Save data to UserDefaults
    private func saveTaskData() {
        let data: [String: Any] = [
            "taskName": taskName,
            "totalTime": totalTime,
            "remainingTime": remainingTime,
            "isTaskStarted": isTaskStarted,
            "streakCount": streakCount,
            "taskCompletionHistory": taskCompletionHistory.map { $0.timeIntervalSince1970 }
        ]
        UserDefaults.standard.set(data, forKey: "TaskViewModelData")
    }

    // Load data from UserDefaults
    private func loadTaskData() {
        guard let data = UserDefaults.standard.dictionary(forKey: "TaskViewModelData") else { return }

        taskName = data["taskName"] as? String ?? ""
        totalTime = data["totalTime"] as? TimeInterval ?? 0
        remainingTime = data["remainingTime"] as? TimeInterval ?? 0
        isTaskStarted = data["isTaskStarted"] as? Bool ?? false
        streakCount = data["streakCount"] as? Int ?? 0
        if let history = data["taskCompletionHistory"] as? [TimeInterval] {
            taskCompletionHistory = history.map { Date(timeIntervalSince1970: $0) }
        }
    }
    
    var hasCompletedFrogToday: Bool {
          let todayStart = Date().startOfDay
          // Check if any completion in `taskCompletionHistory` is on or after today's startOfDay
          return taskCompletionHistory.contains { $0.startOfDay == todayStart }
      }

    deinit {
        stopTask()
    }
}

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
}
