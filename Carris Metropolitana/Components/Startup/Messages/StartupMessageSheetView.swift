//
//  StartupMessageSheetView.swift
//  Carris Metropolitana
//
//  Created by João Pereira on 13/09/2024.
//

import SwiftUI
import WebKit

struct StartupMessageSheetView: View {
    @Environment(\.presentationMode) var presentationMode
    
    let url: URL
    var body: some View {
        StartupMessageWebView(
            url: url,
            onExternalURLOpen: { externalURL in},
            onSelfDismiss: {
                presentationMode.wrappedValue.dismiss()
            }
        )
    }
}

struct StartupMessageWebView: UIViewRepresentable {
    let url: URL
    let onExternalURLOpen: (_ externalURL : URL) -> Void
    let onSelfDismiss: () -> Void

    func makeUIView(context: Context) -> WKWebView { 
        let configuration = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        
        contentController.add(context.coordinator, name: "closeButtonClicked")
        configuration.userContentController = contentController
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.underPageBackgroundColor = .clear
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: StartupMessageWebView
        
        init(_ parent: StartupMessageWebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url, url != parent.url {
                self.parent.onExternalURLOpen(url)
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "closeButtonClicked" {
                parent.onSelfDismiss()
            }
        }
    }
}

func addLocaleAndBuild(host: String, path: String) -> URL? {
    let url = URL(string: "\(host)\(Locale.current.languageCode ?? "pt")\(path)")!
    if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) {
        var queryItems = urlComponents.queryItems ?? []
        queryItems.append(URLQueryItem(name: "build", value: Bundle.main.buildVersionNumber ?? "UNKNOWN"))

        urlComponents.queryItems = queryItems
        
        if let finalURL = urlComponents.url {
            return finalURL
        }
    }
    return nil
}

#Preview {
    VStack {}
        .sheet(isPresented: .constant(true)) {
            StartupMessageSheetView(url: URL(string: "https://carrismetropolitana.pt/")!)
                .ignoresSafeArea()
        }
}
