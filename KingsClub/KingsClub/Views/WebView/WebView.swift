//
//  WebView.swift
//  KingsClub
//

import SafariServices
import SwiftUI

struct WebView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("authAppidU") var authAppidU = ""

    @State var url: URL
    var didFail: (String) -> Void
    /// Se `false`, mantém a tela aberta e oferece "Tentar novamente" (melhor para cards da Home).
    var dismissOnFail: Bool

    @State var isLoading = true
    @State private var safariURL: URL?
    @State private var showSafari = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var reloadToken = 0

    init(url: URL, dismissOnFail: Bool = true, didFail: @escaping (String) -> Void) {
        self._url = State(initialValue: url)
        self.dismissOnFail = dismissOnFail
        self.didFail = didFail
    }

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            if isLoading {
                LoadingView(text: "Carregando...")
                    .zIndex(1.5)
            }
            WebViewModel(url: url) {
                isLoading = true
            } didFinish: {
                isLoading = false

                if url.absoluteString.localizedCaseInsensitiveContains("novoMenu.do") {
                    DataInteractor.shared.consultaCli(idU: DataInteractor.shared.authAppidU) { result in
                        print(result)
                    }
                }

            } didFail: { error in
                isLoading = false
                errorMessage = error
                if dismissOnFail {
                    didFail(error)
                    presentationMode.wrappedValue.dismiss()
                } else {
                    showErrorAlert = true
                }
            } callMainView: {
                presentationMode.wrappedValue.dismiss()
            } openSafari: { url in
                isLoading = false
                safariURL = url
                showSafari = true
            }
            .id(reloadToken)
            .zIndex(1.0)
            .ignoresSafeArea(.all, edges: .bottom)
        }
        .sheet(isPresented: $showSafari) {
            if let safariURL {
                SafariView(url: safariURL)
                    .ignoresSafeArea()
            }
        }
        .alert("Falha ao carregar", isPresented: $showErrorAlert) {
            Button("Tentar novamente") {
                isLoading = true
                reloadToken += 1
            }
            Button("Fechar", role: .cancel) {
                didFail(errorMessage)
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text(errorMessage)
        }
        .environment(\.colorScheme, .light)
    }
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
    }
}

#Preview {
    WebView(url: Links.novoMenu.url) { _ in }
}
