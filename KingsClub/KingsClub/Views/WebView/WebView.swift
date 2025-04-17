//
//  WebView.swift
//  Rede Duque
//
//  Created by Duane de Moura Silva on 18/12/23.
//

import SwiftUI

struct WebView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("authAppidU") var authAppidU    = ""
    
    @State var url : URL
    var didFail: (String) -> Void
    
    @State var isLoading = true
    
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
            }
            .zIndex(1.0)
            .ignoresSafeArea(.all, edges: .bottom)
        }
        .environment(\.colorScheme, .light)
    }
}

#Preview {
    WebView(url: Links.novoMenu.url) {_ in 
    }
}
