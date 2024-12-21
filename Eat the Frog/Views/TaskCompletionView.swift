import SwiftUI

struct TaskCompletionView: View {
    
    var savedTask: String {
        UserDefaults.standard.string(forKey: "savedTask") ?? "No task found"
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Congratulations!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            Text("You completed: \(savedTask)")
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding()

            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.green)

            Spacer()
        }
        .padding()
    }
}

struct TaskCompletionView_Previews: PreviewProvider {
    static var previews: some View {
        TaskCompletionView()
    }
}
