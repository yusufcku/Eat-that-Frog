import SwiftUI
import StoreKit

struct AboutView: View {
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack(alignment: .top) {
                    // Background Color
                    Color("ghost").edgesIgnoringSafeArea(.all)
                    
                    // Content
                    ScrollView {
                        ZStack {
                            // Dashed Line Background
                            dashedLineBackground()
                                .padding(.top, 90)
                            
                            VStack(spacing: 30) {
                                aboutBlock(
                                    title: "The Mission",
                                    content: """
                                    Eat that Frog is designed to help you focus on your most important task by eliminating distractions and motivating you. Take control of your day!
                                    
                                    "If it's your job to eat a frog, it's best to do it first thing in the morning. And if it's your job to eat two frogs, it's best to eat the biggest one first." - Mark Twain
                                    """,
                                    icon: "checkmark.seal.fill"
                                )
                                .padding(.top, -157)

                                aboutBlock(
                                    title: "Our Story",
                                    content: """
                                    Seeing my own and others addiction to their phones, during high school I built 'Eat that Frog' to help myself and others focus on what truly matters in their lives.
                                    
                                    
                                    """,
                                    icon: "book.fill"
                                )

                                aboutBlock(
                                    title: "Visit Our Website",
                                    content: """
                                    Learn more about us and our future!
                                    """,
                                    icon: "link.circle.fill",
                                    action: {
                                        if let url = URL(string: "https://eatthatfrog.carrd.co/#") {
                                            UIApplication.shared.open(url)
                                        }
                                    }
                                )

                                aboutBlock(
                                    title: "Next Update",
                                    content: """
                                    1: Dark mode compatibility and new fun modes! 2: Frog UI changes. 3: History tab to track and plan your tasks.
                                    """,
                                    icon: "list.bullet.rectangle.fill"
                                )

                                aboutBlock(
                                    title: "Feedback & Support",
                                    content: """
                                    Have suggestions or need help? We're here for you. Let us know how we can make your experience better!
                                    """,
                                    icon: "bubble.left.and.bubble.right.fill"
                                )

                                
                                Button(action: {
                                    requestAppStoreReview()
                                    print("Review Tapped")
                                }) {
                                    Text("Give Us a Review")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color("lime"))
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                                .padding(.horizontal)
                                
                                Button(action: {
                                    print("Visit Website Button Tapped")
                                }) {
                                    Text("Give Feedback")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                                .padding(.horizontal)
                            }
                            .padding(.horizontal)
                            .padding(.top, geometry.safeAreaInsets.top + 120)
                        }
                    }
                    .zIndex(2)
                    
                    // Top Header Bar
                    ZStack {
                        Color("earth")
                            .ignoresSafeArea(edges: .horizontal)
                            .frame(height: 120)
                    }
                    .zIndex(1)
                    
                    // Smaller Fixed Header
                    ZStack {
                        Color("earth")
                            .ignoresSafeArea(edges: .top)
                            .frame(height: 40)
                        
                        HStack(spacing: 4) {
                            Text("About")
                                .font(.system(size: 22, weight: .regular, design: .monospaced))
                                .foregroundColor(.white)
                        }
                    }
                    .zIndex(3)
                }
            }
        }
    }
    
    // MARK: - About Block
    @ViewBuilder
    private func aboutBlock(title: String, content: String, icon: String, action: (() -> Void)? = nil) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(Color("lime"))
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            Text(content)
                .font(.body)
                .multilineTextAlignment(.leading)
            
            if let action = action {
                Button(action: action) {
                    Text("Visit Now")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("lime"))
                        .cornerRadius(10)
                }
                .padding(.top, 10)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 2)
    }
    
    private func requestAppStoreReview() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            AppStore.requestReview(in: windowScene)
        }
    }
    
    // MARK: - Dashed Line Background
    @ViewBuilder
    private func dashedLineBackground() -> some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width / 2
                let itemHeight: CGFloat = 200 // Approximate height of each block
                let spacing: CGFloat = 40 // Space between blocks
                let totalHeight = CGFloat(4) * (itemHeight + spacing)
                
                // Create a dashed line vertically in the center
                path.move(to: CGPoint(x: width, y: 0))
                path.addLine(to: CGPoint(x: width, y: totalHeight))
            }
            .stroke(
                Color.gray.opacity(0.5),
                style: StrokeStyle(lineWidth: 4, lineCap: .round, dash: [10])
            )
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
            .preferredColorScheme(.light)
    }
}
