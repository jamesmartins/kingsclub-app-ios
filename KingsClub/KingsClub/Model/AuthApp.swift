//
//  AuthApp.swift
//  Rede Duque
//
//  Created by Duane de Moura Silva on 18/12/23.
//


/*
 {
     "cod_cliente": "1533070",
     "auth": true,
     "key": "MGtldXJxM1YwZ1XCog==",
     "idU": "QhHM3Pjvmlfw8ItzWus\u00a3oVA\u00a2\u00a2",
     "idL": "UWhITTNQanZtbGZ3OEl0eld1c8Kjb1ZBwqLConxtYlhETzZuR1Fwa8Ki",
     "entidade": null,
     "veiculos": []
 }
 
 */

import Foundation

// MARK: - AuthApp
struct AuthApp: Codable {
    let codCliente: String
    let auth: Bool
    let key, idU, idL: String
    let entidade: String?
    let veiculos: [Veiculo]

    enum CodingKeys: String, CodingKey {
        case codCliente = "cod_cliente"
        case auth, key, idU, idL, entidade, veiculos
    }
}

// MARK: - Veiculo
struct Veiculo: Codable {
    let placas: String

    enum CodingKeys: String, CodingKey {
        case placas = "PLACAS"
    }
}
