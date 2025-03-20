//
//  ContentView.swift
//  KingsClub
//
//  Created by Duane de Moura Silva on 20/03/25.
//

import SwiftUI

struct ContentView: View {
    
    let primaryColor = Color(red: 28/255, green: 44/255, blue: 138/255) // #1C2C8A
    
    var body: some View {
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
                print("Ação do botão Entrar")
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
                print("Ação do botão Cadastrar-se")
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
                print("Fale Conosco pressionado")
            }) {
                Text("Fale Conosco")
                    .foregroundColor(primaryColor)
                    .font(.system(size: 16, weight: .bold))
            }
            .padding(.top, 20)
            
            Button(action: {
                print("Seja nosso parceiro pressionado")
            }) {
                Text("Seja nosso parceiro")
                    .foregroundColor(primaryColor)
                    .font(.system(size: 16, weight: .bold))
            }
            .padding(.top, 20)
            
            Spacer()

        }
        .padding(.vertical)
    }
}

#Preview {
    ContentView()
}
