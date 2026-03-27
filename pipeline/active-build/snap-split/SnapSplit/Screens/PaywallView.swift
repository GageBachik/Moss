import SwiftUI
import RevenueCat

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var scanTracker: ScanTracker
    @State private var offerings: Offerings?
    @State private var isLoading = true
    @State private var selectedPlan: PlanType = .annual
    @State private var isPurchasing = false
    @State private var errorMessage: String?
    @State private var appeared = false

    enum PlanType {
        case monthly, annual
    }

    var body: some View {
        ZStack {
            Theme.Color.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Close button
                HStack {
                    Spacer()
                    Button(action: {
                        Theme.Haptic.tap()
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Theme.Color.textLight)
                            .frame(width: 36, height: 36)
                            .background(Circle().fill(.white.opacity(0.1)))
                    }
                }
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.top, Theme.Spacing.md)

                ScrollView {
                    VStack(spacing: Theme.Spacing.lg) {
                        // Header
                        VStack(spacing: Theme.Spacing.md) {
                            Image(systemName: "infinity")
                                .font(.system(size: 48, weight: .thin))
                                .foregroundColor(Theme.Color.primary)
                                .opacity(appeared ? 1 : 0)
                                .scaleEffect(appeared ? 1 : 0.5)
                                .animation(Theme.Anim.spring.delay(0.1), value: appeared)

                            Text("Unlimited Splits")
                                .font(Theme.Font.heading())
                                .foregroundColor(Theme.Color.textOnDark)
                                .opacity(appeared ? 1 : 0)
                                .animation(Theme.Anim.default.delay(0.2), value: appeared)

                            Text("Never count free scans again")
                                .font(Theme.Font.marketing())
                                .foregroundColor(Theme.Color.textLight)
                                .opacity(appeared ? 1 : 0)
                                .animation(Theme.Anim.default.delay(0.3), value: appeared)
                        }
                        .padding(.top, Theme.Spacing.lg)

                        // Value props
                        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                            ValuePropRow(icon: "camera.fill", text: "Unlimited receipt scans")
                            ValuePropRow(icon: "clock.arrow.circlepath", text: "Full receipt history")
                            ValuePropRow(icon: "person.3.fill", text: "Save group presets")
                            ValuePropRow(icon: "arrow.up.right.square.fill", text: "Venmo & PayPal deep links")
                            ValuePropRow(icon: "sparkles", text: "Priority OCR improvements")
                        }
                        .padding(.horizontal, Theme.Spacing.lg)

                        // Pricing cards
                        if isLoading {
                            // Skeleton loading
                            VStack(spacing: Theme.Spacing.md) {
                                SkeletonPriceCard()
                                SkeletonPriceCard()
                            }
                            .padding(.horizontal, Theme.Spacing.md)
                        } else {
                            VStack(spacing: Theme.Spacing.md) {
                                // Annual plan
                                PriceCard(
                                    title: "Annual",
                                    price: "$19.99/year",
                                    subtitle: "Just $1.67/month",
                                    badge: "Save 44%",
                                    isSelected: selectedPlan == .annual,
                                    onTap: {
                                        Theme.Haptic.tap()
                                        selectedPlan = .annual
                                    }
                                )

                                // Monthly plan
                                PriceCard(
                                    title: "Monthly",
                                    price: "$2.99/month",
                                    subtitle: "Cancel anytime",
                                    badge: nil,
                                    isSelected: selectedPlan == .monthly,
                                    onTap: {
                                        Theme.Haptic.tap()
                                        selectedPlan = .monthly
                                    }
                                )
                            }
                            .padding(.horizontal, Theme.Spacing.md)
                        }

                        // Subscribe button
                        Button(action: {
                            purchase()
                        }) {
                            HStack {
                                if isPurchasing {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Subscribe Now")
                                        .font(Theme.Font.subheading())
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Theme.Spacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: Theme.Radius.medium)
                                    .fill(Theme.Color.primary)
                            )
                            .shadow(color: Theme.Color.primary.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .disabled(isPurchasing)
                        .padding(.horizontal, Theme.Spacing.md)

                        // Error message
                        if let error = errorMessage {
                            Text(error)
                                .font(Theme.Font.caption())
                                .foregroundColor(Theme.Color.danger)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, Theme.Spacing.lg)
                        }

                        // Restore purchases
                        Button(action: {
                            restorePurchases()
                        }) {
                            Text("Restore Purchases")
                                .font(Theme.Font.label())
                                .foregroundColor(Theme.Color.textLight)
                        }

                        // Legal links
                        HStack(spacing: Theme.Spacing.md) {
                            Text("Terms of Use")
                                .font(Theme.Font.caption())
                                .foregroundColor(Theme.Color.textLight.opacity(0.6))
                            Text("|")
                                .foregroundColor(Theme.Color.textLight.opacity(0.3))
                            Text("Privacy Policy")
                                .font(Theme.Font.caption())
                                .foregroundColor(Theme.Color.textLight.opacity(0.6))
                        }
                        .padding(.bottom, Theme.Spacing.lg)
                    }
                }
            }
        }
        .onAppear {
            appeared = true
            fetchOfferings()
        }
    }

    private func fetchOfferings() {
        Purchases.shared.getOfferings { offerings, error in
            isLoading = false
            if let offerings = offerings {
                self.offerings = offerings
            }
            // If RevenueCat not configured, we still show the UI with default prices
        }
    }

    private func purchase() {
        isPurchasing = true
        errorMessage = nil

        // Get the appropriate package from offerings
        guard let offering = offerings?.current else {
            // Fallback: simulate purchase for demo
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                isPurchasing = false
                scanTracker.isPremium = true
                Theme.Haptic.success()
                dismiss()
            }
            return
        }

        let package: Package?
        switch selectedPlan {
        case .annual:
            package = offering.annual
        case .monthly:
            package = offering.monthly
        }

        guard let pkg = package else {
            isPurchasing = false
            errorMessage = "Package not available"
            return
        }

        Purchases.shared.purchase(package: pkg) { _, purchaserInfo, error, userCancelled in
            isPurchasing = false
            if userCancelled {
                return
            }
            if let error = error {
                errorMessage = error.localizedDescription
                Theme.Haptic.warning()
                return
            }
            if purchaserInfo?.entitlements.all["pro"]?.isActive == true {
                scanTracker.isPremium = true
                Theme.Haptic.success()
                dismiss()
            }
        }
    }

    private func restorePurchases() {
        isPurchasing = true
        Purchases.shared.restorePurchases { purchaserInfo, error in
            isPurchasing = false
            if let error = error {
                errorMessage = error.localizedDescription
                return
            }
            if purchaserInfo?.entitlements.all["pro"]?.isActive == true {
                scanTracker.isPremium = true
                Theme.Haptic.success()
                dismiss()
            } else {
                errorMessage = "No active subscription found"
            }
        }
    }
}

// MARK: - Value Prop Row
struct ValuePropRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(Theme.Color.primary)
                .frame(width: 28)

            Text(text)
                .font(Theme.Font.marketing())
                .foregroundColor(Theme.Color.textOnDark)

            Spacer()
        }
    }
}

// MARK: - Price Card
struct PriceCard: View {
    let title: String
    let price: String
    let subtitle: String
    let badge: String?
    var isSelected: Bool
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    HStack {
                        Text(title)
                            .font(Theme.Font.subheading())
                            .foregroundColor(Theme.Color.text)

                        if let badge = badge {
                            Text(badge)
                                .font(Theme.Font.smallLabel())
                                .foregroundColor(.white)
                                .padding(.horizontal, Theme.Spacing.sm)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(Theme.Color.accent)
                                )
                        }
                    }

                    Text(subtitle)
                        .font(Theme.Font.caption())
                        .foregroundColor(Theme.Color.textLight)
                }

                Spacer()

                Text(price)
                    .font(Theme.Font.price())
                    .foregroundColor(Theme.Color.text)
            }
            .padding(Theme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.medium)
                    .fill(Theme.Color.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.Radius.medium)
                            .stroke(
                                isSelected ? Theme.Color.primary : Color.clear,
                                lineWidth: 2.5
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Skeleton Price Card
struct SkeletonPriceCard: View {
    @State private var shimmer = false

    var body: some View {
        RoundedRectangle(cornerRadius: Theme.Radius.medium)
            .fill(Theme.Color.surface.opacity(0.3))
            .frame(height: 80)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.medium)
                    .fill(
                        LinearGradient(
                            colors: [.clear, .white.opacity(0.1), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .offset(x: shimmer ? 300 : -300)
            )
            .clipped()
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    shimmer = true
                }
            }
    }
}
