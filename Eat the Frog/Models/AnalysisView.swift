import SwiftUI

struct AnalysisView: View {
    let earthColor: Color
    let onNext: () -> Void
    let selectedAnswers: [Int]
    let hoursPerYear: Double
    
    @State private var showCircles = false
    @State private var showKey = false
    @State private var showAlternatives = false
    @State private var fadeInOpacity: Double = 0
    @State private var currentPage = 0
    @State private var scrollOffset: CGFloat = 0
    @State private var isAutoScrolling = true
    @State private var autoScrollTimer: Timer?

    private var analysisResults: [(String, String, AnalysisStatus)] {
        let sleepScore = 4 - selectedAnswers[0]
        let socialScore = 4 - selectedAnswers[1]
        let guiltScore = 4 - selectedAnswers[2]
        let focusScore = 4 - selectedAnswers[3]
        let morningUrgeScore = 4 - ((selectedAnswers[4] + selectedAnswers[6])/2)
        let limitScore = 4 - ((selectedAnswers[5]+selectedAnswers[6])/2)
        
        return [
            ("moon.zzz.fill", "Sleep", getStatus(score: sleepScore)),
            ("person.2.fill", "Social", getStatus(score: socialScore)),
            ("hand.raised.fill", "Self-Control", getStatus(score: guiltScore)),
            ("brain.head.profile", "Focus", getStatus(score: focusScore)),
            ("clock.fill", "Time", getStatus(score: morningUrgeScore)),
            ("chart.line.uptrend.xyaxis", "Productivity", getStatus(score: limitScore)),
        ]
    }
    
    private func getStatus(score: Int) -> AnalysisStatus {
        switch score {
        case 0...1: return .safe
        case 2: return .average
        default: return .danger
        }
    }
    
    private let alternatives: [(String, String, Color)] = [
        ("graduationcap.fill", "", .blue),
        ("heart.fill", "", .pink),
        ("dollarsign.circle.fill", "", .orange),
        ("globe", "", .purple),
        ("book.fill", "", .green)
    ]

    private func calculateAlternative(index: Int, hours: Double) -> String {
        switch index {
        case 0:
            let semesters = Int(hours / 700)
            return "Complete \(semesters) semesters"
        case 1:
            let dailyHours = Int(hours)
            return "Spend \(dailyHours) hours with family"
        case 2:
            let earnings = Int(hours * 12)
            return "Earn $\(earnings) at $12/hour"
        case 3:
            let languages = Int(hours / 1000)
            return "Learn \(languages) new languages"
        case 4:
            let books = Int(hours * 50)
            return "Read \(books) pages of books"
        default:
            return ""
        }
    }
    
    private func startAutoScrollTimer() {
        autoScrollTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
            if isAutoScrolling {
                withAnimation {
                    currentPage = (currentPage + 1) % alternatives.count
                }
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color("ghost").edgesIgnoringSafeArea(.all)
            VStack(spacing: 25) {
                Text("Your Digital Focus Analysis")
                    .font(.system(size: 23, weight: .bold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.top)
                
                Text("Based on your answers, here's what we found:")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 20) {
                    ForEach(analysisResults.indices, id: \.self) { index in
                        let result = analysisResults[index]
                        AnalysisItem(icon: result.0, label: result.1, status: result.2)
                            .opacity(showCircles ? 1 : 0)
                            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                            .symbolEffect(.pulse.wholeSymbol, options: .nonRepeating)
                            .animation(.easeIn.delay(Double(index) * 0.2), value: showCircles)
                    }
                }
                
                if showKey {
                    HStack(spacing: 20) {
                        ForEach(AnalysisStatus.allCases, id: \.self) { status in
                            HStack {
                                Circle()
                                    .fill(status.color)
                                    .frame(width: 10, height: 10)
                                Text(status.rawValue.capitalized)
                                    .font(.caption)
                            }
                        }
                    }
                    .transition(.opacity)
                }
                
                if showAlternatives {
                    VStack(spacing: 10) {
                        Text("You spend around \(Int(hoursPerYear))hrs\non your phone per year!\nWith that time, you could...")
                            .font(.system(size: 15, weight: .light))
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 10)
                        
                        TabView(selection: $currentPage) {
                            ForEach(0..<alternatives.count, id: \.self) { index in
                                let (icon, _, color) = alternatives[index]
                                TimeAlternativeView(
                                    icon: icon,
                                    title: calculateAlternative(index: index, hours: hoursPerYear),
                                    color: color
                                )
                                .tag(index)
                            }
                        }
                        .frame(height: 140)
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        .onAppear {
                            startAutoScrollTimer()
                        }
                        .gesture(
                            DragGesture()
                                .onChanged { _ in
                                    isAutoScrolling = false
                                }
                                .onEnded { _ in
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        isAutoScrolling = true
                                    }
                                }
                        )
                        
                        HStack(spacing: 8) {
                            ForEach(0..<5) { index in
                                Circle()
                                    .fill(index == currentPage ? Color.black : Color.gray.opacity(0.3))
                                    .frame(width: 8, height: 8)
                            }
                        }
                        .padding(.top, 8)
                    }
                    .transition(.opacity)
                }
                
                Button(action:{
                    triggerHapticFeedback()
                    onNext()
                }) {
                    Text("Let's fix it together")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background( Color("lime"))
                        .cornerRadius(28)
                }
                .padding(.top, 10)
                .transition(.opacity)
            }
        }
        .padding()
        .opacity(fadeInOpacity)
        .onAppear {
            withAnimation(.easeIn(duration: 1.0)) {
                fadeInOpacity = 1
            }
            withAnimation(.easeIn(duration: 0.5)) {
                showCircles = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation {
                    showKey = true
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation {
                    showAlternatives = true
                }
            }
        }
        .onDisappear {
            autoScrollTimer?.invalidate()
        }
    }
}

struct AnalysisItem: View {
    let icon: String
    let label: String
    let status: AnalysisStatus
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)
                .foregroundColor(.white)
                .padding(20)
                .background(status.color)
                .clipShape(Circle())
            
            Text(label)
                .font(.caption)
                .multilineTextAlignment(.center)
        }
    }
}

struct TimeAlternativeView: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 36, height: 36)
                .foregroundColor(color)
            
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .multilineTextAlignment(.center)
                .frame(width: 110)
        }
        .frame(width: 140, height: 110)
        .padding(10)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

enum AnalysisStatus: String, CaseIterable {
    case safe
    case average
    case danger
    
    var color: Color {
        switch self {
        case .safe: return .green
        case .average: return .yellow
        case .danger: return .red
        }
    }
}

#Preview {
    AnalysisView(
        earthColor: .green,
        onNext: { print("Next tapped") },
        selectedAnswers: [2, 1, 3, 0, 2, 1, 3],
        hoursPerYear: 240
    )
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}



private func triggerHapticFeedback() {
    let generator = UIImpactFeedbackGenerator(style: .light)
    generator.impactOccurred()
}
