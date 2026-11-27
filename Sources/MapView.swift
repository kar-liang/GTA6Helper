import SwiftUI
import WebKit

/// 互动地图 tab: embeds a community interactive map in a WKWebView, with a
/// source picker. All sources were verified on 2026-11-27 to load without
/// login and to save found-progress locally in the web view:
/// - oplay.cc (default): Traditional Chinese, 6,691 pins, no ads, 攻略站
///   built for phones; Discord login only for cross-device sync.
/// - FullSweep: Simplified Chinese, trophy/100% tracker, local progress;
///   some pins are pre-release predictions marked 未验证.
/// - Sixth Star: Traditional Chinese on Rockstar's official base map,
///   3,869 pins, progress stored in the browser only.
/// - GamerSky: biggest Chinese guide coverage, but some features push
///   their official app and checklist sync needs an account.
/// Browsing/filtering/searching needs no account on any of them.
struct MapView: View {
    struct Source: Identifiable {
        let id: String
        let name: String
        let url: URL
    }

    static let sources: [Source] = [
        Source(id: "oplay", name: "oplay 繁中",
               url: URL(string: "https://oplay.cc/gta6/map")!),
        Source(id: "fullsweep", name: "FullSweep 简中",
               url: URL(string: "https://www.fullsweepmap.com/?view=map&lang=zh")!),
        Source(id: "sixthstar", name: "第六颗星 繁中",
               url: URL(string: "https://sixthstar.net/zh-tw/locations/gta-6-interactive-map/")!),
        Source(id: "gamersky", name: "游民星空",
               url: URL(string: "https://www.gamersky.com/tools/map/?mapId=261")!),
    ]

    @AppStorage("mapSourceID") private var sourceID = "oplay"
    @State private var reloadToken = UUID()
    @State private var isLoading = true

    private var source: Source {
        Self.sources.first { $0.id == sourceID } ?? Self.sources[0]
    }

    var body: some View {
        NavigationStack {
            ZStack {
                MapWebView(url: source.url, reloadToken: reloadToken, isLoading: $isLoading)
                    .ignoresSafeArea(edges: .bottom)

                if isLoading {
                    VStack(spacing: 12) {
                        ProgressView()
                        Text("地图加载中，瓦片比较慢，请稍等…")
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
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        ForEach(Self.sources) { item in
                            Button {
                                if sourceID != item.id {
                                    sourceID = item.id
                                    isLoading = true
                                    reloadToken = UUID()
                                }
                            } label: {
                                if item.id == sourceID {
                                    Label(item.name, systemImage: "checkmark")
                                } else {
                                    Text(item.name)
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "globe")
                            Text(source.name)
                                .font(.subheadline)
                        }
                    }
                }
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
