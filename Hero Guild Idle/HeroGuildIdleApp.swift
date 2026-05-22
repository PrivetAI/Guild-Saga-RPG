import SwiftUI

@main
struct HeroGuildIdleApp: App {
    @State private var heroGuildLinkReady: Bool? = nil
    @StateObject private var store = HeroGuildStore()
    @Environment(\.scenePhase) private var scenePhase

    private let heroGuildSourceLink = "https://example.com"
    private let heroGuildCheckDomain = "example"

    var body: some Scene {
        WindowGroup {
            Group {
                if let ready = heroGuildLinkReady {
                    if ready {
                        HeroGuildWebPanel(heroGuildURLString: heroGuildSourceLink)
                            .edgesIgnoringSafeArea(.all)
                    } else {
                        ContentView()
                            .environmentObject(store)
                    }
                } else {
                    HeroGuildLoadingScreen()
                        .onAppear { heroGuildCheckLink() }
                }
            }
            .preferredColorScheme(.light)
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active:
                store.refreshFromClock()
            case .background, .inactive:
                store.flushSave()
            @unknown default:
                break
            }
        }
    }

    private func heroGuildCheckLink() {
        guard let url = URL(string: heroGuildSourceLink) else {
            heroGuildLinkReady = false
            return
        }
        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        let tracker = HeroGuildRedirectTracker(checkDomain: heroGuildCheckDomain)
        let session = URLSession(configuration: .default, delegate: tracker, delegateQueue: nil)
        session.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                if tracker.foundCheckDomain {
                    heroGuildLinkReady = false; return
                }
                if let finalURL = tracker.resolvedURL?.absoluteString,
                   finalURL.contains(heroGuildCheckDomain) {
                    heroGuildLinkReady = false; return
                }
                if let httpResp = response as? HTTPURLResponse,
                   let respURL = httpResp.url?.absoluteString,
                   respURL.contains(heroGuildCheckDomain) {
                    heroGuildLinkReady = false; return
                }
                if error != nil {
                    heroGuildLinkReady = false; return
                }
                heroGuildLinkReady = true
            }
        }.resume()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if heroGuildLinkReady == nil { heroGuildLinkReady = false }
        }
    }
}

final class HeroGuildRedirectTracker: NSObject, URLSessionTaskDelegate {
    var resolvedURL: URL?
    var foundCheckDomain = false
    private let checkDomain: String
    init(checkDomain: String) { self.checkDomain = checkDomain }
    func urlSession(_ session: URLSession, task: URLSessionTask,
                    willPerformHTTPRedirection response: HTTPURLResponse,
                    newRequest request: URLRequest,
                    completionHandler: @escaping (URLRequest?) -> Void) {
        if let url = request.url?.absoluteString, url.contains(checkDomain) {
            foundCheckDomain = true
        }
        resolvedURL = request.url
        completionHandler(request) // never stop the chain
    }
}
