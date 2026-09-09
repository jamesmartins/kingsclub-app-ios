//
//  HomeViewModel.swift
//  KingsClub
//
//  Layout nativo da Home (padrão Bunker). APIs serão plugadas depois.
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

    /// Key em `novoMenu.links` (APP.do) — usada quando as APIs forem ligadas.
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

    @Published var firstName: String
    @Published var availableBalance: Decimal
    @Published var redeemedBalance: Decimal
    @Published var expiredBalance: Decimal
    @Published var tokenBannerText: String
    @Published var isLoading = false

    var onBack: (() -> Void)?
    var onLogout: (() -> Void)?
    var onOpenMenuItem: ((HomeMenuItem) -> Void)?

    init(
        firstName: String = "App",
        availableBalance: Decimal = 0,
        redeemedBalance: Decimal = 0,
        expiredBalance: Decimal = 0,
        tokenBannerText: String = "Ainda não há saldo para gerar tokens"
    ) {
        self.firstName = firstName
        self.availableBalance = availableBalance
        self.redeemedBalance = redeemedBalance
        self.expiredBalance = expiredBalance
        self.tokenBannerText = tokenBannerText
    }

    var greeting: String {
        "Olá, \(firstName)!"
    }

    func formattedCurrency(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: value as NSDecimalNumber) ?? "R$ 0,00"
    }

    func openMenuItem(_ item: HomeMenuItem) {
        if item == .logout {
            onLogout?()
            return
        }
        // Placeholder até as novas APIs: cards só logam a intenção.
        print("Home menu stub: \(item.rawValue) → \(item.novoMenuLinkKey ?? "nil")")
        onOpenMenuItem?(item)
    }

    func backTapped() {
        onBack?()
    }
}
