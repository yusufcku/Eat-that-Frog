import SwiftUI

// TimelineItem and TimelineItemView remain unchanged
struct TimelineItem: Identifiable {
    let id = UUID()
    let icon: String
    let iconBackground: Color
    let title: String
    let description: String
    let isCompleted: Bool
}

struct TimelineItemView: View {
    let item: TimelineItem
    let isLast: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            // Icon column with connecting line
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(item.isCompleted ? Color("lime") : .secondary.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: item.icon)
                        .foregroundColor(item.isCompleted ? .white : .secondary)
                        .font(.system(size: 16, weight: .bold))
                }
                
                if !isLast {
                    Rectangle()
                        .fill(Color.secondary.opacity(0.2))
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                        .padding(.vertical, 8)
                }
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.system(size: 17, weight: .semibold))
                
                Text(item.description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                
                if !isLast {
                    Spacer()
                        .frame(height: 20)
                }
            }
            .padding(.top, 8)
            
            Spacer()
        }
    }
}

struct PaywallView: View {
    @State private var isYearlyBilling = true
    @State private var showFinalPage = false
    @State private var isOnBoardingComplete = false
    
    private let monthlyPrice = 3.99
    private let yearlyPrice = 34.99
    
    let hoursPerYear: Double
    let onComplete: () -> Void
    
    private let features = [
        "Unlock access to all features",
        "Be the first to experience updates",
        "Enjoy unrestricted customization",
        "Support an indie dev trying to pay for college :)",
        "... and more"
    ]
    
    private let timelineItems = [
        TimelineItem(
            icon: "checkmark",
            iconBackground: Color("lime"),
            title: "Get your Digital Focus Diagnosis",
            description: "You successfully started your journey",
            isCompleted: true
        ),
        TimelineItem(
            icon: "lock",
            iconBackground: .secondary,
            title: "Today: Improve Your Focus",
            description: "Block Apps automatically, customize your settings and your experience",
            isCompleted: false
        ),
        TimelineItem(
            icon: "bell",
            iconBackground: .secondary,
            title: "Day 6: See initial results",
            description: "We'll send you a notification to remind you of your trial and to check first results.",
            isCompleted: false
        ),
        TimelineItem(
            icon: "brain.head.profile",
            iconBackground: .secondary,
            title: "Day 7: Take your next step",
            description: "Continue improving your productivity by taking advantage of more features",
            isCompleted: false
        )
    ]
    
    var currentPrice: Double {
        isYearlyBilling ? yearlyPrice : monthlyPrice
    }
    
    var monthlyEquivalent: Double {
        isYearlyBilling ? yearlyPrice / 12 : monthlyPrice
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            ZStack(alignment: .bottom) {
                // Scrollable content
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 16) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 85))
                                .foregroundColor(Color("lime"))
                            
                            Text("Start your free trial and save \(Int(hoursPerYear/200))+ hours this week")
                                .font(.system(size: 28, weight: .bold))
                                .padding(.horizontal, 19)
                            
                            Text("Hello if you are a beta tester/test flight just click the X you will have premium anyways!")
                                .font(.system(size: 16))
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                                .fontWeight(.bold)
                        }
                        
                        // Timeline Journey
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(Array(timelineItems.enumerated()), id: \.element.id) { index, item in
                                TimelineItemView(
                                    item: item,
                                    isLast: index == timelineItems.count - 1
                                )
                            }
                        }
                        .padding(.horizontal)
                        
                        // Pricing Toggle
                        HStack(spacing: 16) {
                            Text("Monthly")
                                .foregroundColor(isYearlyBilling ? .secondary : .primary)
                            
                            Toggle("", isOn: $isYearlyBilling)
                                .labelsHidden()
                                .tint(Color("lime"))
                            
                            Text("Yearly (Save 27%)")
                                .foregroundColor(isYearlyBilling ? .primary : .secondary)
                        }
                        
                        // Price
                        VStack(spacing: 8) {
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text("$\(String(format: "%.2f", currentPrice))")
                                    .font(.system(size: 36, weight: .bold))
                                
                                Text("/" + (isYearlyBilling ? "year" : "month"))
                                    .font(.system(size: 16))
                                    .foregroundColor(.secondary)
                            }
                            
                            if isYearlyBilling {
                                Text("Just $\(String(format: "%.2f", monthlyEquivalent))/month, billed annually")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // Features
                        VStack(alignment: .leading, spacing: 16) {
                            ForEach(features, id: \.self) { feature in
                                HStack(spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(Color("lime").opacity(0.05))
                                            .frame(width: 30, height: 30)
                                        
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 14, weight: .black))
                                            .foregroundColor(Color("lime"))
                                    }
                                    
                                    Text(feature)
                                        .font(.system(size: 16))
                                    
                                    Spacer()
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Extra space for the fixed bottom content
                        Spacer()
                            .frame(height: 140)
                    }
                    .padding(.vertical, 32)
                }
                
                // Fixed bottom content
                VStack(spacing: 16) {
                    Button(action: {
                        triggerHapticFeedback()
                        // Handle subscription
                    }) {
                        Text("Start Free Week")
                            .font(.system(size: 17, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color("lime"))
                            .foregroundColor(.white)
                            .cornerRadius(28)
                    }
                    
                    VStack(spacing: 4) {
                        Text("No payment due now!")
                        Text("7-day free trial. Cancel anytime.")
                    }
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                }
                .padding(.horizontal)
                .padding(.top, 30)
                .padding(.bottom, 30)
                .background(
                    Rectangle()
                        .fill(.background)
                        .edgesIgnoringSafeArea(.bottom)
                )
            }
            
            // Fixed X button in the top right
            Button(action: {
                onComplete()
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.secondary)
                    .padding(12)
                    .background(Color.gray.opacity(0.4))
                    .clipShape(Circle())
            }
            .padding([.top, .trailing], 16)
        }
    }
}

// MARK: - Preview
struct PaywallView_Previews: PreviewProvider {
    static var previews: some View {
        PaywallView(hoursPerYear: 8760, onComplete: {
            // Action when 'X' is tapped or user completes paywall
        })
        .previewLayout(.sizeThatFits)
    }
}

// MARK: - Haptic
private func triggerHapticFeedback() {
    let generator = UIImpactFeedbackGenerator(style: .light)
    generator.impactOccurred()
}
