import SwiftUI
import FamilyControls

struct AppPickerView: View {
    @Binding var activitySelection: FamilyActivitySelection
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            // Background color
            Color("appcolor") // Replace "ghost" with your gray color name
                .edgesIgnoringSafeArea(.all) // Ensures the background fills the entire screen

            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        dismiss() // Dismiss the view
                    }) {
                        Image(systemName: "arrow.up")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24) // Adjust size of the arrow
                            .foregroundColor(Color("earth")) // Use "earth" color
                    }
                    .padding()
                    .padding(.top,10)// Add padding around the button
                    Spacer()
                }
                FamilyActivityPicker(selection: $activitySelection) // App selection
            }
        }
    }
}
