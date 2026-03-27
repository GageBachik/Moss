import SwiftUI

struct ContentView: View {
    @EnvironmentObject var scanTracker: ScanTracker
    @State private var showCamera = false
    @State private var showPaywall = false
    @State private var currentSession: SplitSession?
    @State private var showSummary = false
    @State private var recentSessions: [SplitSession] = []

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Color.background
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                            Text("Snap Split")
                                .font(Theme.Font.heading())
                                .foregroundColor(Theme.Color.textOnDark)
                            Text("Scan. Tap. Split.")
                                .font(Theme.Font.caption())
                                .foregroundColor(Theme.Color.textLight)
                        }

                        Spacer()

                        // Premium badge or upgrade button
                        if scanTracker.isPremium {
                            Text("PRO")
                                .font(Theme.Font.caption())
                                .foregroundColor(Theme.Color.primary)
                                .padding(.horizontal, Theme.Spacing.sm)
                                .padding(.vertical, Theme.Spacing.xs)
                                .background(
                                    Capsule()
                                        .stroke(Theme.Color.primary, lineWidth: 1.5)
                                )
                        } else {
                            Button(action: {
                                Theme.Haptic.tap()
                                showPaywall = true
                            }) {
                                Text("Upgrade")
                                    .font(Theme.Font.label())
                                    .foregroundColor(Theme.Color.primary)
                                    .padding(.horizontal, Theme.Spacing.md)
                                    .padding(.vertical, Theme.Spacing.sm)
                                    .background(
                                        Capsule()
                                            .fill(Theme.Color.primary.opacity(0.15))
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, Theme.Spacing.lg)
                    .padding(.top, Theme.Spacing.md)

                    // Recent splits or empty state
                    if recentSessions.isEmpty {
                        Spacer()
                        EmptyStateView(
                            icon: "doc.text.magnifyingglass",
                            title: "No splits yet",
                            subtitle: "Tap the camera to scan your first receipt"
                        )
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: Theme.Spacing.md) {
                                ForEach(recentSessions) { session in
                                    RecentSplitCard(session: session)
                                }
                            }
                            .padding(.horizontal, Theme.Spacing.lg)
                            .padding(.top, Theme.Spacing.lg)
                            .padding(.bottom, 120) // space for scan button
                        }
                    }

                    Spacer(minLength: 0)
                }

                // Floating scan button
                VStack {
                    Spacer()
                    ScanButton(
                        scansRemaining: scanTracker.scansRemaining,
                        isPremium: scanTracker.isPremium
                    ) {
                        if scanTracker.canScan {
                            showCamera = true
                        } else {
                            showPaywall = true
                        }
                    }
                    .padding(.bottom, Theme.Spacing.lg)
                }
            }
            .fullScreenCover(isPresented: $showCamera) {
                CameraView { session in
                    currentSession = session
                    scanTracker.recordScan()
                }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
            .fullScreenCover(item: $currentSession) { session in
                ItemReviewView(session: session) { finalSession in
                    recentSessions.insert(finalSession, at: 0)
                }
            }
        }
    }
}

// MARK: - Recent Split Card
struct RecentSplitCard: View {
    let session: SplitSession

    var body: some View {
        ReceiptCard {
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                HStack {
                    VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                        Text(session.restaurantName)
                            .font(Theme.Font.subheading())
                            .foregroundColor(Theme.Color.text)

                        Text(session.date.formatted(date: .abbreviated, time: .shortened))
                            .font(Theme.Font.caption())
                            .foregroundColor(Theme.Color.textLight)
                    }

                    Spacer()

                    Text(String(format: "$%.2f", session.total))
                        .font(Theme.Font.price())
                        .foregroundColor(Theme.Color.text)
                }

                DashedSeparator()

                HStack(spacing: Theme.Spacing.sm) {
                    Text("\(session.items.count) items")
                        .font(Theme.Font.caption())
                        .foregroundColor(Theme.Color.textLight)

                    Text("*")
                        .foregroundColor(Theme.Color.textLight)

                    HStack(spacing: -8) {
                        ForEach(session.friends.prefix(4)) { friend in
                            Circle()
                                .fill(friend.color)
                                .frame(width: 24, height: 24)
                                .overlay(
                                    Text(friend.initials)
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundColor(.white)
                                )
                        }
                        if session.friends.count > 4 {
                            Circle()
                                .fill(Theme.Color.textLight)
                                .frame(width: 24, height: 24)
                                .overlay(
                                    Text("+\(session.friends.count - 4)")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundColor(.white)
                                )
                        }
                    }
                }
            }
        }
    }
}
