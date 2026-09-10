//
//  AppConfigAPI.swift
//  KingsClub
//

import Foundation

enum AppConfigAPI {
    static let url = "https://adm.bunkerapp.com.br/wsjson/APP.do"

    static func fetch(completion: @escaping (Result<AppConfigResponse, Error>) -> Void) {
        Task {
            do {
                let response: AppConfigResponse = try await APIManager().performRequest(
                    urlString: url,
                    method: .get,
                    authorizationCode: AppSecrets.authorizationCodePadded
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
