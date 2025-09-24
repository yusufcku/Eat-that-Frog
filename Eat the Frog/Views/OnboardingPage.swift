import SwiftUI

struct OnboardingPage: Identifiable {
    let id = UUID()
    let image: String
    let title: String
    let subtitle: String
}

let onboardingPages = [
    OnboardingPage(
        image: "onboarding-1",
        title: "It's simple just\nset a frog",
        subtitle: "Tackle your most important task first\nthing and take control of your days"
    ),
    OnboardingPage(
        image: "onboarding-2",
        title: "Block apps that\nhold you back",
        subtitle: "Select apps to block and stay\nfocused on what truly matters"
    ),
    OnboardingPage(
        image: "onboarding-3",
        title: "Build healthy habits\nevery day",
        subtitle: "Create streaks, stay consistent,\nand enjoy your productivity boost"
    )
]

