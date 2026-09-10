//
//  WebViewModel.swift
//  KingsClub
//

import SwiftUI
import WebKit

enum WebViewTuning {
    /// Páginas Bunker costumam demorar; default do iOS (~60s) estoura fácil.
    static let requestTimeout: TimeInterval = 120
    static let maxTimeoutRetries = 2
    static let sharedProcessPool = WKProcessPool()
}

struct WebViewModel: UIViewRepresentable {
    typealias UIViewType = WKWebView

    let url: URL
    var didStart: () -> Void
    var didFinish: () -> Void
    var didFail: (String) -> Void
    var callMainView: () -> Void
    var openSafari: (URL) -> Void

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.processPool = WebViewTuning.sharedProcessPool
        config.websiteDataStore = .default()
        config.allowsInlineMediaPlayback = true

        let webView = WKWebView(frame: .zero, configuration: config)
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        }
        webView.navigationDelegate = context.coordinator
        context.coordinator.attach(webView: webView, url: url)
        context.coordinator.load(url)
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Evita reload duplicado quando o SwiftUI reavalia a view.
        context.coordinator.didStart = didStart
        context.coordinator.didFinish = didFinish
        context.coordinator.didFail = didFail
        context.coordinator.callMainView = callMainView
        context.coordinator.openSafari = openSafari
    }

    func makeCoordinator() -> WebViewCoordinator {
        WebViewCoordinator(
            didStart: didStart,
            didFinish: didFinish,
            didFail: didFail,
            callMainView: callMainView,
            openSafari: openSafari
        )
    }
}

final class WebViewCoordinator: NSObject, WKNavigationDelegate {
    var didStart: () -> Void
    var didFinish: () -> Void
    var didFail: (String) -> Void
    var callMainView: () -> Void
    var openSafari: (URL) -> Void

    private weak var webView: WKWebView?
    private var currentURL: URL?
    private var timeoutRetryCount = 0

    init(
        didStart: @escaping () -> Void,
        didFinish: @escaping () -> Void,
        didFail: @escaping (String) -> Void,
        callMainView: @escaping () -> Void,
        openSafari: @escaping (URL) -> Void
    ) {
        self.didStart = didStart
        self.didFinish = didFinish
        self.didFail = didFail
        self.callMainView = callMainView
        self.openSafari = openSafari
    }

    func attach(webView: WKWebView, url: URL) {
        self.webView = webView
        self.currentURL = url
        self.timeoutRetryCount = 0
    }

    func load(_ url: URL) {
        currentURL = url
        var request = URLRequest(
            url: url,
            cachePolicy: .reloadRevalidatingCacheData,
            timeoutInterval: WebViewTuning.requestTimeout
        )
        request.allowsCellularAccess = true
        webView?.load(request)
    }

    func reloadCurrent() {
        guard let url = currentURL else {
            webView?.reload()
            return
        }
        load(url)
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }

        if url.absoluteString.range(of: "https://www.lojakings.com.br", options: [.anchored, .caseInsensitive]) != nil {
            openSafari(url)
            decisionHandler(.cancel)
            return
        }

        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        didStart()
        print("didStart url:\(webView.url?.absoluteString ?? currentURL?.absoluteString ?? "-")")
        if let url = webView.url, url.absoluteString.localizedCaseInsensitiveContains("intro.do") {
            webView.stopLoading()
            callMainView()
        } else if let url = webView.url, url.absoluteString.localizedCaseInsensitiveContains("intro.php") {
            webView.stopLoading()
            callMainView()
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        timeoutRetryCount = 0
        didFinish()
        print("didFinish url:\(webView.url?.absoluteString ?? "-")")
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        handleLoadFailure(error)
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        handleLoadFailure(error)
    }

    private func handleLoadFailure(_ error: Error) {
        let nsError = error as NSError

        // Cancelamento por navegação nova / stopLoading — ignorar.
        if nsError.domain == NSURLErrorDomain, nsError.code == NSURLErrorCancelled {
            return
        }

        let isTimeout = nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorTimedOut
        if isTimeout, timeoutRetryCount < WebViewTuning.maxTimeoutRetries {
            timeoutRetryCount += 1
            print("Carregamento expirou — retry \(timeoutRetryCount)/\(WebViewTuning.maxTimeoutRetries)")
            didStart()
            reloadCurrent()
            return
        }

        print("didFail url:\(webView?.url?.absoluteString ?? currentURL?.absoluteString ?? "-")\nerror:\(error.localizedDescription)")
        didFail(error.localizedDescription)
    }
}
