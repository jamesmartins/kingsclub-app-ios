//
//  WebView.swift
//  Rede Duque
//
//  Created by Duane de Moura Silva on 18/12/23.
//

import SafariServices
import SwiftUI

struct WebView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("authAppidU") var authAppidU    = ""
    
    @State var url : URL
    var didFail: (String) -> Void
    
    @State var isLoading = true
    @State private var safariURL: URL?
    @State private var showSafari = false
    
    var body: some View {
        ZStack{
            Color.white
                .ignoresSafeArea()
            if isLoading {
                LoadingView(text:"Carregando...")
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
                self.didFail(error)
                isLoading = false
                presentationMode.wrappedValue.dismiss()
            } callMainView: {
                presentationMode.wrappedValue.dismiss()
            } openSafari: { url in
                isLoading = false
                safariURL = url
                showSafari = true
            }
            .zIndex(1.0)
            .ignoresSafeArea(.all, edges: .bottom)
        }
        .sheet(isPresented: $showSafari) {
            if let safariURL {
                SafariView(url: safariURL)
                    .ignoresSafeArea()
            }
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
    WebView(url: Links.novoMenu.url) {_ in 
    }
}
