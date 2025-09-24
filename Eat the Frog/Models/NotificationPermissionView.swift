import SwiftUI
import UserNotifications

struct NotificationPermissionView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @State private var showSettingsAlert = false
    
    @State private var isLoading = false
    
    let onContinue: () -> Void
    
    var body: some View {
        ZStack {
            Color("ghost").edgesIgnoringSafeArea(.all)
            VStack(spacing: 20) {
                // Back button
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(Color("lime"))
                            .font(.system(size: 24))
                    }
                    Spacer()
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Bell Icon
                Image(systemName: "bell.badge")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 70, height: 70)
                    .foregroundColor(Color("lime"))
                
                // Title
                Text("Enable Notifications\nfor Eat that Frog")
                    .font(.system(size: 32, weight: .bold))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Description
                Text("We use notifications to guide you\nand help you achieve your goals")
                    .font(.system(size: 16))
                    .fontWeight(.light)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .padding(.top, 5)
                
                Spacer()
                
                // Secured by Apple
                HStack {
                    Text("Secured by")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .fontWeight(.light)
                        .offset(x: 2)
                    Image(systemName: "apple.logo")
                        .resizable()
                        .foregroundColor(.gray)
                        .frame(width: 10, height: 12)
                        .scaledToFit()
                    Text("Apple")
                        .font(.system(size: 12))
                        .fontWeight(.light)
                        .foregroundColor(.gray)
                        .offset(x: -2)
                }
                
                // Continue (or Loading) Button
                Button(action: {
                    isLoading = true
                    requestNotificationAuthorization()
                    triggerHapticFeedback()
                }) {
                    ZStack {
                        // Background and frame
                        Color("lime")
                            .frame(height: 56)
                            .cornerRadius(28)
                        
                        // Button content
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                                .scaleEffect(1.2)
                        } else {
                            Text("Continue")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .background(Color.white)
            .navigationBarHidden(true)
            .alert(isPresented: $showSettingsAlert) {
                Alert(
                    title: Text("Notifications Access Required"),
                    message: Text("We couldn't enable notifications. Please grant notification permissions in your device's Settings."),
                    primaryButton: .default(Text("Open Settings")) {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    },
                    secondaryButton: .cancel(Text("Dismiss")) {
                        isLoading = false
                    }
                )
            }
        }
    }
}

extension NotificationPermissionView {
    private func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if granted {
                    self.authorizationStatus = .authorized
                    self.onContinue()
                } else {
                    self.authorizationStatus = .denied
                    self.showSettingsAlert = true
                }
            }
        }
    }
}

#Preview {
    NotificationPermissionView {
        // `onContinue` callback
        print("Notification permission was granted.")
    }
}
private func triggerHapticFeedback() {
    let generator = UIImpactFeedbackGenerator(style: .light)
    generator.impactOccurred()
}
