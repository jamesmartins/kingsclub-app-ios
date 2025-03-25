//
//  Links.swift
//  Rede Duque
//
//  Created by Duane de Moura Silva on 18/12/23.
//

import Foundation

enum Links: String {
    case cadastro = "consulta_V2.do?key=0keurq3V0gU¢"
    case faleConosco = "faleConosco.do?key=0keurq3V0gU¢"
    case parceiro = "parceiro.do?key=0keurq3V0gU¢"
    case esqueciMinhaSenha = "recuperacaoSenha.do?key=0keurq3V0gU¢&cpf="
    case login = "https://adm.bunkerapp.com.br/wsjson/authApp.do"
    case novoMenu = "novoMenu.do?key="
    case intro = "intro.do?key=0keurq3V0gU¢"
    case tokenApp = "https://adm.bunker.mk/wsjson/TokenAppPush.do"
    case consultaCli = "https://adm.bunker.mk/wsjson/ConsultaCli.do"
    
    var url: URL {
        let baseURL = "https://adm.bunkerapp.com.br/app/"
        
        if self == .novoMenu {
            
            var key = ""
            var idU = ""
            
            if DataInteractor.shared.authAppkey == "" || DataInteractor.shared.authAppidU == "" {
                guard let authApp = DataInteractor.shared.authApp else {
                    print("Erro ao obter Link: direcionando para o google")
                    return URL(string: "https://www.google.com.br/")!
                }
                key = authApp.key
                idU = authApp.idU
            } else {
                key = DataInteractor.shared.authAppkey
                idU = DataInteractor.shared.authAppidU
            }
            
            let urlString = "https://adm.bunkerapp.com.br/app/intro.do?key=" + key + "&idU=" + idU + "&cds=0"
            //let urlString = "https://adm.bunkerapp.com.br/app/novoMenu.do?key=" + key + "&idU=" + idU + "&cds=0"
            
            if let url = URL(string: urlString) {
                print("Link obtido:\(url.absoluteString)")
                return url
            } else {
                print("Erro ao obter Link: direcionando para o google")
                return URL(string: "https://www.google.com.br/")!
            }
        } else {
            if let url = URL(string:baseURL + self.rawValue) {
                print("Link obtido:\(url.absoluteString)")
                return url
            } else {
                print("Erro ao obter Link: direcionando para o google")
                return URL(string: "https://www.google.com.br/")!
            }
        }
    }
}
