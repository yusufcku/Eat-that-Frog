import SwiftUI

struct MonthlyStreakView: View {
    let days = ["S", "M", "T", "W", "T", "F", "S"]
    // Sample data - replace with actual streak data
    let streakData: [StreakStatus] = Array(repeating: .missed, count: 30)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Legend
            HStack(spacing: 16) {
                legendItem(color: Color("lime"), text: "Frog Eaten", color1: Color("lime"))
                legendItem(color: Color.gray.opacity(0.2), text: "Frog Missed",color1: Color.gray)
            }
            .padding(.bottom, 4)
            .frame(maxWidth: .infinity, alignment: .center)
            
            // Days of week header
            HStack(spacing: 4) {
                ForEach(days, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 12, weight: .medium))
                        .frame(width: 44)
                        .foregroundColor(.secondary)
                }
                .offset(x: 3)
            }
            
            // Grid of streak blocks
            LazyVGrid(columns: Array(repeating: GridItem(.fixed(43), spacing: 5), count: 7), spacing: 6) {
                ForEach(0..<30, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(streakData[index].color)
                        .frame(width: 30, height: 30)
                }
            }
        }
        .padding()
        .background(Color("ghost"))
    }
    
    private func legendItem(color: Color, text: String, color1: Color) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            Text(text)
                .font(.caption)
                .foregroundColor(color1)
        }
    }
}

enum StreakStatus {
    case completed
    case missed
    
    var color: Color {
        switch self {
        case .completed:
            return Color("lime")
        case .missed:
            return Color.gray.opacity(0.2)
        }
    }
}

struct MonthlyStreakView_Previews: PreviewProvider {
    static var previews: some View {
        MonthlyStreakView()
    }
}

