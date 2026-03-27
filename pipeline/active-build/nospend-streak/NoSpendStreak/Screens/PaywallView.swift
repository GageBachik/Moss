import SwiftUI
import RevenueCat

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var offerings: Offerings?
    @State private var selectedPackage: Package?
    @State private var isLoading = true
    @State private var isPurchasing = false
    @State private var errorMessage: String?
    @State private var starRotation: Double = 0

    var body: some View {
        ZStack {
            Theme.Color.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    // Close button
                    HStack {
                        Spacer()
                        Button {
                            Theme.Haptic.tap()
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(Theme.Color.muted)
                        }
                    }
                    .padding(.horizontal, Theme.Spacing.md)

                    // Hero
                    VStack(spacing: Theme.Spacing.md) {
                        ZStack {
                            Circle()
                                .fill(Theme.Color.primary.opacity(0.15))
                                .frame(width: 120, height: 120)
                                .blur(radius: 20)

                            Image(systemName: "star.fill")
                                .font(.system(size: 56))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Theme.Color.primary, Theme.Color.accent],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .rotationEffect(.degrees(starRotation))
                                .onAppear {
                                    withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                                        starRotation = 10
                                    }
                                }
                        }

                        Text("Go Premium")
                            .font(Theme.Font.heading())
                            .foregroundStyle(.white)

                        Text("Unlock the full NoSpend experience")
                            .font(Theme.Font.body())
                            .foregroundStyle(Theme.Color.muted)
                    }

                    // Benefits
                    benefitsList

                    // Pricing
                    if isLoading {
                        loadingState
                    } else if let error = errorMessage {
                        errorState(error)
                    } else {
                        pricingOptions
                    }

                    // Purchase button
                    if selectedPackage != nil {
                        purchaseButton
                    }

                    // Restore
                    Button {
                        Task { await restorePurchases() }
                    } label: {
                        Text("Restore Purchases")
                            .font(Theme.Font.caption())
                            .foregroundStyle(Theme.Color.muted)
                    }

                    // Legal
                    Text("Payment will be charged to your Apple ID account at confirmation of purchase. Subscription automatically renews unless it is canceled at least 24 hours before the end of the current period.")
                        .font(Theme.Font.caption())
                        .foregroundStyle(Theme.Color.muted.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Theme.Spacing.lg)

                    Spacer(minLength: Theme.Spacing.xl)
                }
            }

            if isPurchasing {
                Color.black.opacity(0.5).ignoresSafeArea()
                ProgressView()
                    .tint(Theme.Color.primary)
                    .scaleEffect(1.5)
            }
        }
        .task {
            await loadOfferings()
        }
    }

    // MARK: - Benefits

    private var benefitsList: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            benefitRow(icon: "calendar.badge.clock", text: "Custom challenge durations (7, 14, 30, 100 days)")
            benefitRow(icon: "target", text: "Savings goal tracker with progress")
            benefitRow(icon: "square.grid.2x2", text: "Home screen widgets")
            benefitRow(icon: "square.and.arrow.up", text: "Shareable streak cards for social")
            benefitRow(icon: "chart.xyaxis.line", text: "Detailed analytics & insights")
        }
        .padding(Theme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.medium)
                .fill(Theme.Color.surface)
        )
        .padding(.horizontal, Theme.Spacing.md)
    }

    private func benefitRow(icon: String, text: String) -> some View {
        HStack(spacing: Theme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(Theme.Color.primary)
                .frame(width: 28)

            Text(text)
                .font(Theme.Font.body())
                .foregroundStyle(.white)
        }
    }

    // MARK: - Pricing Options

    private var pricingOptions: some View {
        VStack(spacing: Theme.Spacing.sm) {
            if let packages = offerings?.current?.availablePackages {
                ForEach(packages, id: \.identifier) { package in
                    pricingCard(for: package)
                }
            } else {
                // Fallback static pricing
                staticPricingCard(title: "Weekly", price: "$1.99/wk", subtitle: "Most Popular", isHighlighted: true)
                staticPricingCard(title: "Monthly", price: "$5.99/mo", subtitle: "Save 25%", isHighlighted: false)
                staticPricingCard(title: "Annual", price: "$29.99/yr", subtitle: "Best Value", isHighlighted: false)
            }
        }
        .padding(.horizontal, Theme.Spacing.md)
    }

    private func pricingCard(for package: Package) -> some View {
        let isSelected = selectedPackage?.identifier == package.identifier
        let isWeekly = package.packageType == .weekly

        return Button {
            Theme.Haptic.tap()
            withAnimation(Theme.Anim.default) {
                selectedPackage = package
            }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    HStack {
                        Text(package.storeProduct.localizedTitle)
                            .font(Theme.Font.body())
                            .foregroundStyle(.white)

                        if isWeekly {
                            Text("Most Popular")
                                .font(Theme.Font.caption())
                                .foregroundStyle(Theme.Color.background)
                                .padding(.horizontal, Theme.Spacing.sm)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule().fill(Theme.Color.primary)
                                )
                        }
                    }

                    Text(package.storeProduct.localizedPriceString)
                        .font(Theme.Font.label())
                        .foregroundStyle(Theme.Color.muted)
                }

                Spacer()

                Circle()
                    .strokeBorder(isSelected ? Theme.Color.primary : Theme.Color.border, lineWidth: 2)
                    .frame(width: 24, height: 24)
                    .overlay {
                        if isSelected {
                            Circle()
                                .fill(Theme.Color.primary)
                                .frame(width: 14, height: 14)
                        }
                    }
            }
            .padding(Theme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.medium)
                    .fill(Theme.Color.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.Radius.medium)
                            .strokeBorder(isSelected ? Theme.Color.primary : .clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private func staticPricingCard(title: String, price: String, subtitle: String, isHighlighted: Bool) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                HStack {
                    Text(title)
                        .font(Theme.Font.body())
                        .foregroundStyle(.white)

                    if isHighlighted {
                        Text(subtitle)
                            .font(Theme.Font.caption())
                            .foregroundStyle(Theme.Color.background)
                            .padding(.horizontal, Theme.Spacing.sm)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(Theme.Color.primary))
                    }
                }

                Text(price)
                    .font(Theme.Font.label())
                    .foregroundStyle(Theme.Color.muted)
            }

            Spacer()
        }
        .padding(Theme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.medium)
                .fill(Theme.Color.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radius.medium)
                        .strokeBorder(isHighlighted ? Theme.Color.primary : .clear, lineWidth: 2)
                )
        )
    }

    // MARK: - Purchase Button

    private var purchaseButton: some View {
        Button {
            Task { await purchase() }
        } label: {
            Text("Continue")
                .font(Theme.Font.body())
                .foregroundStyle(Theme.Color.background)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: Theme.Radius.medium)
                        .fill(Theme.Color.primary)
                        .shadow(color: Theme.Color.primary.opacity(0.4), radius: 12, y: 4)
                )
        }
        .padding(.horizontal, Theme.Spacing.md)
    }

    // MARK: - States

    private var loadingState: some View {
        VStack(spacing: Theme.Spacing.md) {
            ForEach(0..<3, id: \.self) { _ in
                RoundedRectangle(cornerRadius: Theme.Radius.medium)
                    .fill(Theme.Color.surface)
                    .frame(height: 72)
                    .shimmer()
            }
        }
        .padding(.horizontal, Theme.Spacing.md)
    }

    private func errorState(_ message: String) -> some View {
        VStack(spacing: Theme.Spacing.md) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 32))
                .foregroundStyle(Theme.Color.danger)

            Text(message)
                .font(Theme.Font.body())
                .foregroundStyle(Theme.Color.muted)
                .multilineTextAlignment(.center)

            Button {
                Task { await loadOfferings() }
            } label: {
                Text("Try Again")
                    .font(Theme.Font.label())
                    .foregroundStyle(Theme.Color.primary)
            }
        }
        .padding(Theme.Spacing.lg)
    }

    // MARK: - RevenueCat

    private func loadOfferings() async {
        isLoading = true
        errorMessage = nil
        do {
            offerings = try await Purchases.shared.offerings()
            if let weekly = offerings?.current?.availablePackages.first(where: { $0.packageType == .weekly }) {
                selectedPackage = weekly
            } else {
                selectedPackage = offerings?.current?.availablePackages.first
            }
        } catch {
            errorMessage = "Unable to load pricing. Please check your connection."
        }
        isLoading = false
    }

    private func purchase() async {
        guard let package = selectedPackage else { return }
        isPurchasing = true
        do {
            let result = try await Purchases.shared.purchase(package: package)
            if !result.userCancelled {
                Theme.Haptic.stamp()
                dismiss()
            }
        } catch {
            errorMessage = "Purchase failed. Please try again."
        }
        isPurchasing = false
    }

    private func restorePurchases() async {
        isPurchasing = true
        do {
            _ = try await Purchases.shared.restorePurchases()
            Theme.Haptic.stamp()
            dismiss()
        } catch {
            errorMessage = "Restore failed. Please try again."
        }
        isPurchasing = false
    }
}

// MARK: - Shimmer Modifier
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [.clear, Theme.Color.muted.opacity(0.1), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: phase)
                .onAppear {
                    withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                        phase = 300
                    }
                }
            )
            .clipped()
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}
