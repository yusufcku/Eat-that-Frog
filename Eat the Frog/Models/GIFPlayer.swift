import SwiftUI
import WebKit

struct GIFPlayerView: UIViewRepresentable {
    let gifName: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.isScrollEnabled = false
        webView.contentMode = .scaleAspectFit
        if let path = Bundle.main.path(forResource: gifName, ofType: "gif") {
            let url = URL(fileURLWithPath: path)
            webView.loadFileURL(url, allowingReadAccessTo: url)
        } else {
            print("GIF not found: \(gifName).gif")
        }
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
