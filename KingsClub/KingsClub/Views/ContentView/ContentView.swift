//
//  ContentView.swift
//  KingsClub
//
//  Created by Duane de Moura Silva on 20/03/25.
//

import SwiftUI

struct ContentView: View {
    
    let primaryColor = Color(red: 28/255, green: 44/255, blue: 138/255) // #1C2C8A
    @State var callLogin: Bool = false
    @State var isLoading = false
    @State var erroRequest = false
    @State var showWebView = false
    @State var destinationWebView = WebViewDestination.cadastro
    
    var body: some View {
        ZStack{
            if isLoading {
                LoadingView(text:"Carregando...")
                    .zIndex(1.5)
            }
            VStack {
                Spacer()
                
                // Logo
                Image("kings_sneakers_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 50)
                
                // Kings Club Banner
                Image("kings_club_banner")
                    .resizable()
                    .scaledToFit()
                    .padding()
                    .frame(width: .infinity)
                
                
                // Entrar Button
                Button(action: {
                    callLogin = true
                }) {
                    Text("Entrar")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(primaryColor)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal, 20)
                
                // Cadastrar-se Button
                Button(action: {
                    showWebView = true
                    destinationWebView = .cadastro
                }) {
                    Text("Cadastrar-se")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(primaryColor, lineWidth: 2)
                        )
                        .foregroundColor(primaryColor)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                Button(action: {
                    showWebView = true
                    destinationWebView = .faleConosco
                }) {
                    Text("Fale Conosco")
                        .foregroundColor(primaryColor)
                        .font(.system(size: 16, weight: .bold))
                }
                .padding(.top, 20)
                
                Button(action: {
                    showWebView = true
                    destinationWebView = .parceiro
                }) {
                    Text("Seja nosso parceiro")
                        .foregroundColor(primaryColor)
                        .font(.system(size: 16, weight: .bold))
                }
                .padding(.top, 20)
                
                Spacer()
                
            }
            .zIndex(1.0)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(.vertical)
        .fullScreenCover(isPresented: $callLogin) {
            LoginView()
        }
        .alert("Erro no Request\nTente novamente!", isPresented: $erroRequest) {
            Button("OK", role: .cancel) {
                //fetchData()
            }
        }
        .fullScreenCover(isPresented: $showWebView){
            WebView(url: DataInteractor.getURL(destinationWebView)) { errorDescription in
                print(errorDescription)
            }
        }
    }
}

#Preview {
    ContentView()
}
