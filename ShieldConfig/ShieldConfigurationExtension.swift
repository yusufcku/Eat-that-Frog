import ManagedSettings
import ManagedSettingsUI
import UIKit

class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        return ShieldConfiguration(
            backgroundBlurStyle: .systemUltraThinMaterial, // Greenish blurry background
            backgroundColor: UIColor(red: 0.6, green: 0.9, blue: 0.6, alpha: 0.7), // Light green background color
            icon: UIImage(named: "frog"), // Use a custom frog image or SF Symbol as fallback
            title: ShieldConfiguration.Label(
                text: "This app is locked", // Title text
                color: .white // Title color
            ),
            subtitle: ShieldConfiguration.Label(
                text: "Eat your frog to unlock!", // Subtitle text
                color: .white.withAlphaComponent(0.8) // Subtitle color with slight transparency
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "Eat Your Frog!", // Primary button text
                color: UIColor(ciColor: .white) // Button text color (custom or green)
            ),
            primaryButtonBackgroundColor: UIColor(named: "frogcolor"), // Button background color
            secondaryButtonLabel: ShieldConfiguration.Label(
                text: "Close App", // Secondary button text
                color: .white // Secondary button text color
            )
        )
    }
    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        // Reuse or customize the shield for categories if needed
        return ShieldConfiguration(
            backgroundBlurStyle: .systemUltraThinMaterial,
            backgroundColor: UIColor(red: 0.6, green: 0.9, blue: 0.6, alpha: 0.7),
            icon: UIImage(named: "frog") ?? UIImage(systemName: "leaf.fill"),
            title: ShieldConfiguration.Label(
                text: "Blocked Category",
                color: .white
            ),
            subtitle: ShieldConfiguration.Label(
                text: "This app belongs to a restricted category.",
                color: .white.withAlphaComponent(0.8)
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "Unlock for Focus",
                color: UIColor(named: "frogColor") ?? .systemGreen
            ),
            primaryButtonBackgroundColor: UIColor(named: "frogColor") ?? .systemGreen,
            secondaryButtonLabel: ShieldConfiguration.Label(
                text: "Close",
                color: .white
            )
        )
    }
}
