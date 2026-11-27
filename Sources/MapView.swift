import SwiftUI
import WebKit

/// 互动地图 tab: embeds GamerSky's GTA6 interactive map (mapId=261) in a
/// WKWebView. The app.gamersky.com link redirects to this www.gamersky.com
/// tools URL, so load the redirect target directly. Browsing the map needs
/// no login; only GamerSky's own checklist sync does, and that stays inside
/// the web page. Our own offline 点位 list remains as the fallback.
struct MapView: View {
    static let mapURL = URL(string: "https://www.gamersky.com/tools/map/?mapId=261")!

    @State private var reloadToken = UUID()
    @State private var isLoading = true

    var body: some View {
        NavigationStack {
            ZStack {
                MapWebView(url: Self.mapURL, reloadToken: reloadToken, isLoading: $isLoading)
                    .ignoresSafeArea(edges: .bottom)

                if isLoading {
                    VStack(spacing: 12) {
                        ProgressView()
                        Text("地图加载中，游民的瓦片比较慢，请稍等…")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .padding(20)
                    .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 16))
                }
            }
            .navigationTitle("互动地图")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isLoading = true
                        reloadToken = UUID()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .accessibilityLabel("重新加载地图")
                }
            }
        }
    }
}

private struct MapWebView: UIViewRepresentable {
    let url: URL
    let reloadToken: UUID
    @Binding var isLoading: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(isLoading: $isLoading)
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.scrollView.bounces = false
        context.coordinator.lastToken = reloadToken
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        if context.coordinator.lastToken != reloadToken {
            context.coordinator.lastToken = reloadToken
            webView.load(URLRequest(url: url))
        }
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        @Binding var isLoading: Bool
        var lastToken: UUID?

        init(isLoading: Binding<Bool>) {
            _isLoading = isLoading
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            isLoading = false
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            isLoading = false
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            isLoading = false
        }
    }
}
