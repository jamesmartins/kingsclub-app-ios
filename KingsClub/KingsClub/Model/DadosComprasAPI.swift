//
//  DadosComprasAPI.swift
//  KingsClub
//

import Foundation

enum DadosComprasAPI {
    static let url = "https://adm.bunker.mk/wsjson/dadoscompras.php"

    static func fetch(cpf: String, pagina: Int = 1, completion: @escaping (Result<DadosComprasResponse, Error>) -> Void) {
        let digits = cpf.filter(\.isNumber)
        let parameters: [String: Any] = [
            "NUM_CGCECPF": digits,
            "pagina": pagina
        ]
        print("DadosComprasAPI NUM_CGCECPF length: \(digits.count)")

        Task {
            do {
                let response: DadosComprasResponse = try await APIManager().performRequest(
                    urlString: url,
                    method: .post(body: parameters),
                    authorizationCode: AppSecrets.authorizationCode
                )
                DispatchQueue.main.async {
                    completion(.success(response))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}
