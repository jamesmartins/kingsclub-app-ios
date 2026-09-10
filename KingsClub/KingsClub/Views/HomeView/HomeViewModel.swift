//
//  HomeViewModel.swift
//  KingsClub
//
//  Home nativa (padrão Bunker) + APIs dadoscompras / APP.do
//

import Foundation
import SwiftUI

enum HomeColors {
    static let brandBlue = Color(red: 28 / 255, green: 44 / 255, blue: 138 / 255) // #1C2C8A
    static let brandBlueSoft = Color(red: 40 / 255, green: 58 / 255, blue: 160 / 255)
    static let tileBackground = Color(red: 232 / 255, green: 234 / 255, blue: 246 / 255) // #E8EAF6
    static let tileForeground = Color(red: 28 / 255, green: 44 / 255, blue: 138 / 255)
    static let secondaryLabel = Color.white.opacity(0.85)
}

enum HomeMenuItem: String, CaseIterable, Identifiable {
    case offers = "Minhas Ofertas"
    case purchases = "Minhas Compras"
    case profile = "Meus Dados"
    case statement = "Extrato"
    case messages = "Mensagens"
    case addresses = "Endereços"
    case contact = "Fale Conosco"
    case logout = "Sair"

    var id: String { rawValue }

    /// Key em `novoMenu.links` (APP.do).
    var novoMenuLinkKey: String? {
        switch self {
        case .offers: return "ofertas"
        case .purchases: return "minhas_compras"
        case .profile: return "meus_dados"
        case .statement: return "historico"
        case .messages: return "mensagens"
        case .addresses: return "enderecos"
        case .contact: return "fale_conosco"
        case .logout: return "logout"
        }
    }

    var systemImage: String {
        switch self {
        case .offers: return "tag.fill"
        case .purchases: return "bag.fill"
        case .profile: return "person.text.rectangle.fill"
        case .statement: return "doc.text.fill"
        case .messages: return "envelope.fill"
        case .addresses: return "mappin.and.ellipse"
        case .contact: return "headphones"
        case .logout: return "rectangle.portrait.and.arrow.right"
        }
    }
}

final class HomeViewModel: ObservableObject {
    /// `false` = Home nativa pós-login; `true` = menu WebView legado.
    static var legacyWebMenuEnabled = false

    /// Chave curta do app (`intro.do?key=`), não o Base64 do login/APP.do.
    static let bunkerAppKey = "0keurq3V0gU¢"

    /// `tipoToken.do` não vem no APP.do. Só o `t` é fixo; `key` e `idU` vêm da sessão do usuário logado.
    static let tokenURLTemplate =
        "https://adm.bunkerapp.com.br/app/tipoToken.do?t=OVH52RxQp£APz78WQcIhp£Frjhs£rKrp5wZ"

    @Published var firstName: String
    @Published var availableBalance: Decimal
    @Published var redeemedBalance: Decimal
    @Published var expiredBalance: Decimal
    @Published var tokenBannerText: String
    @Published var isLoading = false
    @Published var errorMessage: String?

    var cpf: String?
    var idU: String?
    var appKey: String
    private(set) var menuLinks: [String: String] = [:]

    var onBack: (() -> Void)?
    /// Chamado ao tocar em Sair com a URL do serviço (apresentar WebView de logout).
    var onLogout: ((URL?) -> Void)?
    /// Chamado quando logout local + serviço terminaram (aí sim volta ao login).
    var onLogoutCompleted: (() -> Void)?
    var onOpenURL: ((URL, String) -> Void)?

    init(
        firstName: String = "App",
        cpf: String? = nil,
        idU: String? = nil,
        appKey: String = HomeViewModel.bunkerAppKey,
        availableBalance: Decimal = 0,
        redeemedBalance: Decimal = 0,
        expiredBalance: Decimal = 0,
        tokenBannerText: String = "Ainda não há saldo para gerar tokens"
    ) {
        self.firstName = firstName
        self.cpf = cpf
        self.idU = idU
        self.appKey = appKey
        self.availableBalance = availableBalance
        self.redeemedBalance = redeemedBalance
        self.expiredBalance = expiredBalance
        self.tokenBannerText = tokenBannerText
    }

    var greeting: String {
        "Olá, \(firstName)!"
    }

    var canGenerateToken: Bool {
        availableBalance > 0
    }

    func openToken() {
        guard canGenerateToken else { return }
        if let url = tokenURL() {
            onOpenURL?(url, "Gerar Token")
            return
        }
        errorMessage = "Link de token indisponível."
    }

    func tokenURL() -> URL? {
        let built = Self.buildMenuURL(
            from: Self.tokenURLTemplate,
            appKey: appKey,
            idU: idU
        )
        print("Menu URL [Gerar Token] (tipoToken):", built)
        if let url = URL(string: built) {
            return url
        }
        var allowed = CharacterSet.urlQueryAllowed
        allowed.insert(charactersIn: ":/?#[]@!$&'()*+,;=")
        return built.addingPercentEncoding(withAllowedCharacters: allowed).flatMap(URL.init(string:))
    }

    func configure(cpf: String?, idU: String?, appKey: String = HomeViewModel.bunkerAppKey) {
        self.cpf = cpf
        self.idU = idU
        self.appKey = appKey
    }

    func applyClienteName(primeiroNome: String?, nome: String) {
        let preferred = (primeiroNome ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let full = nome.trimmingCharacters(in: .whitespacesAndNewlines)

        if !preferred.isEmpty {
            firstName = preferred
        } else if !full.isEmpty {
            firstName = Self.extractFirstName(from: full)
        }
    }

    static func extractFirstName(from raw: String) -> String {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "App" }
        return trimmed.split(whereSeparator: { $0.isWhitespace }).first.map(String.init) ?? trimmed
    }

    func formattedCurrency(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: value as NSDecimalNumber) ?? "R$ 0,00"
    }

    func loadHome(pagina: Int = 1) {
        let resolvedCPF = resolvedCPFForRequest()
        guard let cpf = resolvedCPF, !cpf.isEmpty else {
            errorMessage = "CPF do cliente não encontrado para carregar o saldo."
            print("dadoscompras: CPF ausente (configure/UserDefaults/username vazios)")
            return
        }

        self.cpf = cpf
        print("dadoscompras: usando CPF com \(cpf.count) dígitos")

        isLoading = true
        errorMessage = nil
        loadMenuLinks()

        DadosComprasAPI.fetch(cpf: cpf, pagina: pagina) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false

            switch result {
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            case .success(let response):
                guard response.coderro == 200 else {
                    self.errorMessage = response.msgerro
                    return
                }
                if let cliente = response.cliente {
                    self.applyClienteName(primeiroNome: cliente.primeiroNome, nome: cliente.nome)
                    let digits = cliente.numCgcecpf.filter(\.isNumber)
                    if !digits.isEmpty {
                        UserDefaults.standard.set(digits, forKey: "cpf")
                        self.cpf = digits
                    }
                }
                if let saldo = response.saldo {
                    self.availableBalance = Decimal(saldo.disponivel)
                    self.redeemedBalance = Decimal(saldo.resgatado)
                    self.expiredBalance = Decimal(saldo.expirado)
                    self.tokenBannerText = saldo.disponivel > 0
                        ? "Gerar Token"
                        : "Ainda não há saldo para gerar tokens"
                }
            }
        }
    }

    /// Preferência: CPF já configurado → UserDefaults(`cpf`) → username do login.
    private func resolvedCPFForRequest() -> String? {
        let candidates: [String] = [
            cpf?.filter(\.isNumber) ?? "",
            (UserDefaults.standard.string(forKey: "cpf") ?? "").filter(\.isNumber),
            (UserDefaults.standard.string(forKey: "username") ?? "").filter(\.isNumber)
        ]
        return candidates.first(where: { !$0.isEmpty })
    }

    func loadMenuLinks() {
        AppConfigAPI.fetch { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                print("APP.do links error:", error)
            case .success(let response):
                self.menuLinks = response.novoMenu?.links ?? [:]
                print("APP.do menu links loaded:", self.menuLinks.keys.sorted())
            }
        }
    }

    func url(for item: HomeMenuItem) -> URL? {
        guard let linkKey = item.novoMenuLinkKey,
              let raw = menuLinks[linkKey] else {
            return nil
        }
        let built = Self.buildMenuURL(from: raw, appKey: appKey, idU: idU)
        print("Menu URL [\(item.rawValue)] (\(linkKey)):", built)
        if let url = URL(string: built) {
            return url
        }
        var allowed = CharacterSet.urlQueryAllowed
        allowed.insert(charactersIn: ":/?#[]@!$&'()*+,;=")
        return built.addingPercentEncoding(withAllowedCharacters: allowed).flatMap(URL.init(string:))
    }

    /// Padrão: `<path>?key=<appKey>&idU=<idU>&t=<token do APP.do>`
    static func buildMenuURL(from urlString: String, appKey: String, idU: String?) -> String {
        let base = urlString.split(separator: "?", maxSplits: 1, omittingEmptySubsequences: false).first
            .map(String.init) ?? urlString
        let token = queryValue(named: "t", in: urlString)

        var pairs: [(String, String)] = [
            ("key", appKey)
        ]
        if let idU = idU?.trimmingCharacters(in: .whitespacesAndNewlines), !idU.isEmpty {
            pairs.append(("idU", idU))
        }
        if let token = token, !token.isEmpty {
            pairs.append(("t", token))
        }

        let query = pairs
            .map { name, value in
                let encoded = value.addingPercentEncoding(withAllowedCharacters: queryValueAllowed) ?? value
                return "\(name)=\(encoded)"
            }
            .joined(separator: "&")

        return base + "?" + query
    }

    static func queryValue(named name: String, in urlString: String) -> String? {
        let marker = "\(name)="
        guard let range = urlString.range(of: marker, options: .caseInsensitive) else {
            return nil
        }
        let after = urlString[range.upperBound...]
        let end = after.firstIndex(of: "&") ?? after.endIndex
        let raw = String(after[..<end])
        return raw.removingPercentEncoding ?? raw
    }

    private static var queryValueAllowed: CharacterSet {
        var allowed = CharacterSet.alphanumerics
        allowed.insert(charactersIn: "-._~")
        return allowed
    }

    func openMenuItem(_ item: HomeMenuItem) {
        if item == .logout {
            openLogout()
            return
        }
        if let url = url(for: item) {
            onOpenURL?(url, item.rawValue)
            return
        }
        AppConfigAPI.fetch { [weak self] result in
            guard let self = self else { return }
            if case .success(let response) = result {
                self.menuLinks = response.novoMenu?.links ?? [:]
            }
            if let url = self.url(for: item) {
                self.onOpenURL?(url, item.rawValue)
            } else {
                self.errorMessage = "Link indisponível para \(item.rawValue)."
            }
        }
    }

    private func openLogout() {
        if let url = url(for: .logout) {
            onLogout?(url)
            return
        }
        AppConfigAPI.fetch { [weak self] result in
            guard let self = self else { return }
            if case .success(let response) = result {
                self.menuLinks = response.novoMenu?.links ?? [:]
            }
            // Fallback: intro do app se o link logout não estiver disponível.
            self.onLogout?(self.url(for: .logout) ?? Links.intro.url)
        }
    }

    func backTapped() {
        onBack?()
    }
}
