import SwiftUI
import RevenueCat

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var offerings: Offerings?
    @State private var selectedPackage: Package?
    @State private var isLoading = true
    @State private var isPurchasing = false
    @State private var errorMessage: String?
    @State private var purchaseSuccess = false

    private let benefits = [
        ("infinity", "Unlimited beauty categories"),
        ("chart.bar.fill", "Spend analytics & insights"),
        ("bell.badge.fill", "Smart reminder notifications"),
        ("square.grid.2x2.fill", "Home screen widgets"),
        ("arrow.down.doc.fill", "Export appointment history")
    ]

    var body: some View {
        ZStack {
            Theme.Color.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    closeButton
                    heroSection
                    benefitsSection
                    pricingSection
                    restoreButton
                    termsSection
                }
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.bottom, Theme.Spacing.xl)
            }

            if isPurchasing {
                purchasingOverlay
            }

            if purchaseSuccess {
                successOverlay
            }
        }
        .task {
            await loadOfferings()
        }
    }

    // MARK: - Close
    private var closeButton: some View {
        HStack {
            Spacer()
            Button {
                Theme.Haptic.tap()
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Theme.Color.muted)
                    .frame(width: 32, height: 32)
                    .background(Theme.Color.surface)
                    .clipShape(Circle())
            }
        }
        .padding(.top, Theme.Spacing.md)
    }

    // MARK: - Hero
    private var heroSection: some View {
        VStack(spacing: Theme.Spacing.md) {
            CompactMirrorIcon(size: 100, useGradient: true)

            Text("Unlock Your\nFull Glow")
                .font(Theme.Font.heading())
                .foregroundStyle(Theme.Color.text)
                .multilineTextAlignment(.center)

            Text("Get unlimited categories, spend tracking,\nand smart reminders")
                .font(Theme.Font.body())
                .foregroundStyle(Theme.Color.muted)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Benefits
    private var benefitsSection: some View {
        VStack(spacing: Theme.Spacing.md) {
            ForEach(benefits, id: \.0) { icon, text in
                HStack(spacing: Theme.Spacing.md) {
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundStyle(Theme.Color.primary)
                        .frame(width: 28)
                    Text(text)
                        .font(Theme.Font.body())
                        .foregroundStyle(Theme.Color.text)
                    Spacer()
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Theme.Color.primary)
                }
            }
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Color.surface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.medium))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.medium)
                .stroke(Theme.Color.border.opacity(0.3), lineWidth: 0.5)
        )
    }

    // MARK: - Pricing
    private var pricingSection: some View {
        VStack(spacing: Theme.Spacing.md) {
            if isLoading {
                ForEach(0..<3, id: \.self) { _ in
                    shimmerCard
                }
            } else if let offerings = offerings, let current = offerings.current {
                ForEach(current.availablePackages, id: \.identifier) { package in
                    pricingCard(for: package)
                }
            } else {
                // Fallback pricing when RevenueCat is unavailable
                fallbackPricing
            }

            if let error = errorMessage {
                Text(error)
                    .font(Theme.Font.caption())
                    .foregroundStyle(Theme.Color.accent)
                    .multilineTextAlignment(.center)
            }

            if selectedPackage != nil || offerings == nil {
                GlowButton("Continue", icon: "arrow.right") {
                    Task { await purchase() }
                }
                .padding(.top, Theme.Spacing.sm)
            }
        }
    }

    private func pricingCard(for package: Package) -> some View {
        let isSelected = selectedPackage?.identifier == package.identifier
        return Button {
            Theme.Haptic.tap()
            selectedPackage = package
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text(package.storeProduct.localizedTitle)
                        .font(Theme.Font.label())
                        .foregroundStyle(Theme.Color.text)
                    Text(package.storeProduct.localizedDescription)
                        .font(Theme.Font.caption())
                        .foregroundStyle(Theme.Color.muted)
                }
                Spacer()
                Text(package.storeProduct.localizedPriceString)
                    .font(Theme.Font.subheading())
                    .foregroundStyle(isSelected ? Theme.Color.primary : Theme.Color.text)
            }
            .padding(Theme.Spacing.md)
            .background(Theme.Color.surface)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.medium))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.medium)
                    .stroke(
                        isSelected ? Theme.Color.primary : Theme.Color.border.opacity(0.3),
                        lineWidth: isSelected ? 2 : 0.5
                    )
            )
        }
    }

    private var fallbackPricing: some View {
        VStack(spacing: Theme.Spacing.md) {
            fallbackPricingRow(title: "Weekly", subtitle: "Billed weekly", price: "$2.99/wk", tag: nil)
            fallbackPricingRow(title: "Annual", subtitle: "Best value", price: "$49.99/yr", tag: "SAVE 68%")
            fallbackPricingRow(title: "Lifetime", subtitle: "One-time purchase", price: "$79.99", tag: nil)
        }
    }

    private func fallbackPricingRow(title: String, subtitle: String, price: String, tag: String?) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                HStack(spacing: Theme.Spacing.sm) {
                    Text(title)
                        .font(Theme.Font.label())
                        .foregroundStyle(Theme.Color.text)
                    if let tag {
                        Text(tag)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Theme.Color.background)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Theme.Color.primary)
                            .clipShape(Capsule())
                    }
                }
                Text(subtitle)
                    .font(Theme.Font.caption())
                    .foregroundStyle(Theme.Color.muted)
            }
            Spacer()
            Text(price)
                .font(Theme.Font.subheading())
                .foregroundStyle(Theme.Color.text)
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Color.surface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.medium))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.medium)
                .stroke(Theme.Color.border.opacity(0.3), lineWidth: 0.5)
        )
    }

    private var shimmerCard: some View {
        RoundedRectangle(cornerRadius: Theme.Radius.medium)
            .fill(Theme.Color.surface)
            .frame(height: 72)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.medium)
                    .fill(
                        LinearGradient(
                            colors: [
                                Theme.Color.surface,
                                Theme.Color.muted.opacity(0.1),
                                Theme.Color.surface
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
    }

    // MARK: - Restore
    private var restoreButton: some View {
        Button {
            Theme.Haptic.tap()
            Task {
                do {
                    let info = try await Purchases.shared.restorePurchases()
                    if info.entitlements.active.isEmpty {
                        errorMessage = "No active subscriptions found"
                    } else {
                        Theme.Haptic.success()
                        purchaseSuccess = true
                    }
                } catch {
                    errorMessage = "Restore failed: \(error.localizedDescription)"
                }
            }
        } label: {
            Text("Restore Purchases")
                .font(Theme.Font.caption())
                .foregroundStyle(Theme.Color.muted)
        }
    }

    // MARK: - Terms
    private var termsSection: some View {
        VStack(spacing: Theme.Spacing.xs) {
            Text("Payment will be charged to your Apple ID. Subscriptions auto-renew unless cancelled at least 24 hours before the end of the current period.")
                .font(Theme.Font.caption())
                .foregroundStyle(Theme.Color.muted.opacity(0.7))
                .multilineTextAlignment(.center)

            HStack(spacing: Theme.Spacing.md) {
                Link("Privacy Policy", destination: URL(string: "https://example.com/privacy")!)
                    .font(Theme.Font.caption())
                    .foregroundStyle(Theme.Color.muted)
                Link("Terms of Use", destination: URL(string: "https://example.com/terms")!)
                    .font(Theme.Font.caption())
                    .foregroundStyle(Theme.Color.muted)
            }
        }
        .padding(.top, Theme.Spacing.sm)
    }

    // MARK: - Overlays
    private var purchasingOverlay: some View {
        ZStack {
            Theme.Color.background.opacity(0.8).ignoresSafeArea()
            VStack(spacing: Theme.Spacing.md) {
                ProgressView()
                    .tint(Theme.Color.primary)
                    .scaleEffect(1.5)
                Text("Processing...")
                    .font(Theme.Font.label())
                    .foregroundStyle(Theme.Color.text)
            }
        }
    }

    private var successOverlay: some View {
        ZStack {
            Theme.Color.background.opacity(0.9).ignoresSafeArea()
            VStack(spacing: Theme.Spacing.md) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(Theme.Color.primary)
                Text("Welcome to Glow Pro!")
                    .font(Theme.Font.heading())
                    .foregroundStyle(Theme.Color.text)
                GlowButton("Let's Go") {
                    dismiss()
                }
                .padding(.horizontal, Theme.Spacing.xl)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                dismiss()
            }
        }
    }

    // MARK: - Logic
    private func loadOfferings() async {
        do {
            offerings = try await Purchases.shared.offerings()
            isLoading = false
        } catch {
            isLoading = false
            // Fallback pricing will show
        }
    }

    private func purchase() async {
        guard let package = selectedPackage else { return }
        isPurchasing = true
        do {
            let result = try await Purchases.shared.purchase(package: package)
            isPurchasing = false
            if !result.userCancelled {
                Theme.Haptic.success()
                purchaseSuccess = true
            }
        } catch {
            isPurchasing = false
            errorMessage = "Purchase failed: \(error.localizedDescription)"
        }
    }
}
