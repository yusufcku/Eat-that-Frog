import SwiftUI
import FamilyControls

struct SyncScreenView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var authorizationStatus = AuthorizationCenter.shared.authorizationStatus
    @State private var showSettingsAlert = false
    
    @State private var isLoading = false
    @State private var goToNextPage = false
    
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
                
                // Hourglass Icon
                Image("Screen_Time")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .scaledToFit()
                
                // Title
                Text("Sync Screen Time\nwith Eat that Frog")
                    .font(.system(size: 32, weight: .bold))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Description
                Text("Your information stays on your device,\n100% private, only used to block apps")
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
                    requestScreenTimeAuthorization()
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
                    title: Text("Screen Time Access Required"),
                    message: Text("We couldn’t enable app blocking. Please grant Screen Time authorization in your device's Settings."),
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

extension SyncScreenView {
    private func requestScreenTimeAuthorization() {
        Task {
            do {
                try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                
                let newStatus = AuthorizationCenter.shared.authorizationStatus
                DispatchQueue.main.async {
                    authorizationStatus = newStatus
                    isLoading = false
                    if newStatus == .approved {
                        // Authorization granted - call onContinue if you want
                        onContinue()
                        // If you want, do something else here
                    } else {
                        // Not approved
                        showSettingsAlert = true
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    isLoading = false
                    showSettingsAlert = true
                    print("Error requesting authorization: \(error.localizedDescription)")
                }
            }
        }
    }
}


#Preview {
    SyncScreenView {
        // `onContinue` callback
        print("Authorization was approved.")
    }
}

private func triggerHapticFeedback() {
    let generator = UIImpactFeedbackGenerator(style: .light)
    generator.impactOccurred()
}
