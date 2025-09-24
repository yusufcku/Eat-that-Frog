import SwiftUI

struct OnboardingPageView: View {
    let page: OnboardingPage
    @State private var contentOpacity = 0.0
    
    var body: some View {
        VStack(spacing: 40) {
            Image(page.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 300) // Increased image size
                .cornerRadius(24)
                .shadow(color: Color.black.opacity(0.7), radius: 10, x: 0, y: 5)
                .padding(.horizontal)
                .padding(.top, 40) // Increased top padding to bring image down
            
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                
                Text(page.subtitle)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .opacity(contentOpacity)
        .onAppear {
            withAnimation(.easeIn(duration: 0.6)) {
                contentOpacity = 1.0
            }
        }
    }
}

