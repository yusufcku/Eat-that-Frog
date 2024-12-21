import SwiftUI

struct DailyFrogInfo: View {
    var body: some View {
        VStack(spacing: 20) {


            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                    Text("0 - 4 Days: Orange Flame")
                }
                .font(.headline)
             

                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.red)
                    Text("5 - 9 Days: Red Flame")
                }
                .font(.headline)
               
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.purple)
                    Text("10 - 14 Days: Purple Flame")
                }
                .font(.headline)
         

                HStack {
                    LinearGradient(
                        gradient: Gradient(colors: [.red, .orange, .yellow, .green, .blue, .purple]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .mask(
                        Image(systemName: "flame.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                    )
                    .frame(width: 20, height: 20)
                    Text("15+ Days: Rainbow Flame")
                }
                .font(.headline)
                
            }
            .padding()

            Spacer()

        }
        .padding()
    }

    @Environment(\.dismiss) private var dismiss
}
