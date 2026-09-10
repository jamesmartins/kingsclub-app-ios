//
//  HomeView.swift
//  KingsClub
//
//  Home nativa (migração do novoMenu WebView) — layout apenas.
//

import SwiftUI
import UIKit

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel

    private let menuItems = HomeMenuItem.allCases
    @State private var menuWebLink: IdentifiableURL?
    @State private var logoutWebLink: IdentifiableURL?

    var body: some View {
        ZStack(alignment: .top) {
            HomeColors.brandBlue
                .ignoresSafeArea()

            VStack(spacing: 0) {
                navigationBar
                balanceSection
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                summaryRow
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                tokenBanner
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 20)

                menuSheet
            }

            if viewModel.isLoading {
                Color.black.opacity(0.25)
                    .ignoresSafeArea()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.2)
            }
        }
        .environment(\.colorScheme, .light)
        .onAppear {
            viewModel.onOpenURL = { url, _ in
                menuWebLink = IdentifiableURL(url: url)
            }
            viewModel.onLogout = { url in
                logoutWebLink = IdentifiableURL(url: url ?? Links.intro.url)
            }
            viewModel.loadHome()
        }
        .fullScreenCover(item: $menuWebLink) { link in
            WebView(url: link.url, dismissOnFail: false) { errorDescription in
                print(errorDescription)
            }
        }
        .fullScreenCover(item: $logoutWebLink) { link in
            WebView(
                url: link.url,
                dismissOnFail: true,
                closesOnIntroStart: false,
                dismissOnFinish: true,
                onFinished: {
                    logoutWebLink = nil
                    viewModel.onLogoutCompleted?()
                },
                didFail: { error in
                    print("Logout WebView fail:", error)
                    logoutWebLink = nil
                    viewModel.onLogoutCompleted?()
                }
            )
        }
    }

    // MARK: - Header

    private var navigationBar: some View {
        HStack(alignment: .center, spacing: 12) {
            Text(viewModel.greeting)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Spacer(minLength: 8)

            Image("logo_icon")
                .resizable()
                .scaledToFit()
                .frame(width: 44, height: 44)
                .clipShape(Circle())
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    private var balanceSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Saldo disponível")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(HomeColors.secondaryLabel)

            Text(viewModel.formattedCurrency(viewModel.availableBalance))
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var summaryRow: some View {
        HStack(spacing: 12) {
            summaryCard(
                title: "Resgatado",
                value: viewModel.formattedCurrency(viewModel.redeemedBalance)
            )
            summaryCard(
                title: "Expirado",
                value: viewModel.formattedCurrency(viewModel.expiredBalance)
            )
        }
    }

    private func summaryCard(title: String, value: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.white.opacity(0.9))
                Text(value)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
            Spacer(minLength: 4)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(HomeColors.brandBlueSoft.opacity(0.65))
        .cornerRadius(10)
    }

    private var tokenBanner: some View {
        Button(action: { viewModel.openToken() }) {
            HStack(spacing: 10) {
                if viewModel.canGenerateToken {
                    Image(systemName: "qrcode")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(HomeColors.tileForeground)
                }

                Text(viewModel.tokenBannerText)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(HomeColors.tileForeground)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .padding(.horizontal, 12)
            .background(viewModel.canGenerateToken ? Color.white : HomeColors.tileBackground)
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
        .disabled(!viewModel.canGenerateToken)
    }

    // MARK: - Menu

    private var menuSheet: some View {
        VStack(spacing: 0) {
            ScrollView {
                menuGrid
                    .padding(.horizontal, 18)
                    .padding(.top, 22)
                    .padding(.bottom, 28)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(
            Color.white
                .clipShape(RoundedCorner(radius: 28, corners: [.topLeft, .topRight]))
                .ignoresSafeArea(edges: .bottom)
        )
    }

    private var menuGrid: some View {
        let columns = [
            GridItem(.flexible(), spacing: 14),
            GridItem(.flexible(), spacing: 14)
        ]

        return LazyVGrid(columns: columns, spacing: 14) {
            ForEach(menuItems) { item in
                menuTile(item)
            }
        }
    }

    private func menuTile(_ item: HomeMenuItem) -> some View {
        Button(action: { viewModel.openMenuItem(item) }) {
            VStack(spacing: 12) {
                Image(systemName: item.systemImage)
                    .font(.system(size: 28, weight: .regular))
                    .foregroundColor(HomeColors.tileForeground)
                Text(item.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(HomeColors.tileForeground)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 110)
            .background(HomeColors.tileBackground)
            .cornerRadius(14)
        }
        .buttonStyle(.plain)
    }
}

private extension HomeMenuItem {
    var title: String { rawValue }
}

private struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    HomeView(viewModel: HomeViewModel())
}

struct IdentifiableURL: Identifiable {
    let id = UUID()
    let url: URL
}
