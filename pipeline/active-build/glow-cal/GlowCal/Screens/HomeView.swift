import SwiftUI
import SwiftData

struct HomeView: View {
    @Query(sort: \MaintenanceCategory.createdAt) private var categories: [MaintenanceCategory]
    @Environment(\.modelContext) private var modelContext
    @Binding var showPaywall: Bool
    @State private var showAddCategory = false
    @State private var appearAnimations: Set<UUID> = []

    private static let maxFreeCategories = 5

    var body: some View {
        ZStack {
            Theme.Color.background.ignoresSafeArea()

            if categories.isEmpty {
                emptyState
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                        headerSection
                        overdueBanner
                        categoryList
                    }
                    .padding(.horizontal, Theme.Spacing.md)
                    .padding(.bottom, 100)
                }
            }

            addButton
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showAddCategory) {
            AddCategoryView()
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text("Your Glow")
                .font(Theme.Font.heading())
                .foregroundStyle(Theme.Color.text)
            Text(Date(), format: .dateTime.weekday(.wide).month(.wide).day())
                .font(Theme.Font.caption())
                .foregroundStyle(Theme.Color.muted)
        }
        .padding(.top, Theme.Spacing.xl)
    }

    // MARK: - Overdue Banner
    @ViewBuilder
    private var overdueBanner: some View {
        let overdueCount = categories.filter { $0.isOverdue }.count
        if overdueCount > 0 {
            HStack(spacing: Theme.Spacing.sm) {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundStyle(Theme.Color.accent)
                Text("\(overdueCount) routine\(overdueCount == 1 ? "" : "s") overdue")
                    .font(Theme.Font.label())
                    .foregroundStyle(Theme.Color.accent)
                Spacer()
            }
            .padding(Theme.Spacing.md)
            .background(Theme.Color.accent.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.medium))
        }
    }

    // MARK: - Category List
    private var categoryList: some View {
        LazyVStack(spacing: Theme.Spacing.md) {
            ForEach(categories.sorted(by: { $0.daysUntilDue < $1.daysUntilDue })) { category in
                NavigationLink(destination: CategoryDetailView(category: category)) {
                    CategoryCardView(category: category)
                        .scaleEffect(appearAnimations.contains(category.id) ? 1.0 : 0.95)
                        .opacity(appearAnimations.contains(category.id) ? 1.0 : 0.0)
                        .onAppear {
                            withAnimation(Theme.Anim.cardAppear) {
                                _ = appearAnimations.insert(category.id)
                            }
                        }
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Category Card
    struct CategoryCardView: View {
        let category: MaintenanceCategory

        var body: some View {
            GlowCard {
                HStack(spacing: Theme.Spacing.md) {
                    // Icon + Progress Ring
                    ZStack {
                        CategoryProgressRing(
                            progress: category.cycleProgress,
                            accentColor: category.isOverdue ? Theme.Color.accent : category.accentColor,
                            size: 48
                        )
                        Image(systemName: category.icon)
                            .font(.system(size: 18))
                            .foregroundStyle(category.isOverdue ? Theme.Color.accent : category.accentColor)
                    }

                    // Name + Last Done
                    VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                        Text(category.name)
                            .font(Theme.Font.body())
                            .foregroundStyle(Theme.Color.text)
                        if let last = category.lastCompleted {
                            Text("Last: \(last, format: .dateTime.month(.abbreviated).day())")
                                .font(Theme.Font.caption())
                                .foregroundStyle(Theme.Color.muted)
                        } else {
                            Text("No history yet")
                                .font(Theme.Font.caption())
                                .foregroundStyle(Theme.Color.muted)
                        }
                    }

                    Spacer()

                    // Days counter
                    VStack(spacing: 2) {
                        if category.isOverdue {
                            Text("\(abs(category.daysUntilDue))")
                                .font(Theme.Font.data())
                                .foregroundStyle(Theme.Color.accent)
                            Text("overdue")
                                .font(Theme.Font.caption())
                                .foregroundStyle(Theme.Color.accent)
                        } else if category.daysUntilDue == 0 {
                            Text("Today")
                                .font(Theme.Font.data())
                                .foregroundStyle(Theme.Color.primary)
                        } else {
                            Text("\(category.daysUntilDue)")
                                .font(Theme.Font.data())
                                .foregroundStyle(Theme.Color.text)
                            Text("days")
                                .font(Theme.Font.caption())
                                .foregroundStyle(Theme.Color.muted)
                        }
                    }

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Theme.Color.muted)
                }
            }
        }
    }

    // MARK: - Add Button
    private var addButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button {
                    Theme.Haptic.tap()
                    if categories.count >= Self.maxFreeCategories {
                        showPaywall = true
                    } else {
                        showAddCategory = true
                    }
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(Theme.Color.background)
                        .frame(width: 56, height: 56)
                        .background(
                            Circle()
                                .fill(Theme.Color.primary)
                                .shadow(color: Theme.Color.primary.opacity(0.4), radius: 12, y: 4)
                        )
                }
                .padding(.trailing, Theme.Spacing.lg)
                .padding(.bottom, Theme.Spacing.lg)
            }
        }
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Spacer()

            CompactMirrorIcon(size: 120)

            Text("Your Glow Awaits")
                .font(Theme.Font.subheading())
                .foregroundStyle(Theme.Color.text)

            Text("Add your first beauty routine\nto start tracking your glow-up")
                .font(Theme.Font.body())
                .foregroundStyle(Theme.Color.muted)
                .multilineTextAlignment(.center)

            GlowButton("Add First Routine", icon: "plus") {
                showAddCategory = true
            }
            .padding(.horizontal, Theme.Spacing.xl)

            Spacer()
        }
        .padding(Theme.Spacing.md)
    }
}
