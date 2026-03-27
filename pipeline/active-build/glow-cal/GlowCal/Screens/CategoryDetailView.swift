import SwiftUI
import SwiftData

struct CategoryDetailView: View {
    @Bindable var category: MaintenanceCategory
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var showEditSheet = false
    @State private var showDeleteAlert = false

    var body: some View {
        ZStack {
            Theme.Color.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    countdownSection
                    actionSection
                    statsSection
                    historySection
                }
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.bottom, Theme.Spacing.xl)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    Theme.Haptic.tap()
                    dismiss()
                } label: {
                    HStack(spacing: Theme.Spacing.xs) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .font(Theme.Font.label())
                    .foregroundStyle(Theme.Color.primary)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        showEditSheet = true
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 18))
                        .foregroundStyle(Theme.Color.primary)
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            AddCategoryView(editingCategory: category)
        }
        .alert("Delete Category", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                Theme.Haptic.heavy()
                modelContext.delete(category)
                dismiss()
            }
        } message: {
            Text("This will permanently delete \"\(category.name)\" and all its history.")
        }
    }

    // MARK: - Countdown
    private var countdownSection: some View {
        VStack(spacing: Theme.Spacing.md) {
            ZStack {
                CategoryProgressRing(
                    progress: category.cycleProgress,
                    accentColor: category.isOverdue ? Theme.Color.accent : category.accentColor,
                    size: 140
                )
                VStack(spacing: 2) {
                    Image(systemName: category.icon)
                        .font(.system(size: 28))
                        .foregroundStyle(category.isOverdue ? Theme.Color.accent : category.accentColor)
                    if category.isOverdue {
                        Text("\(abs(category.daysUntilDue))d")
                            .font(Theme.Font.dataLarge())
                            .foregroundStyle(Theme.Color.accent)
                        Text("overdue")
                            .font(Theme.Font.caption())
                            .foregroundStyle(Theme.Color.accent)
                    } else if category.daysUntilDue == 0 {
                        Text("Due")
                            .font(Theme.Font.dataLarge())
                            .foregroundStyle(Theme.Color.primary)
                        Text("today")
                            .font(Theme.Font.caption())
                            .foregroundStyle(Theme.Color.primary)
                    } else {
                        Text("\(category.daysUntilDue)")
                            .font(Theme.Font.dataLarge())
                            .foregroundStyle(Theme.Color.text)
                        Text("days left")
                            .font(Theme.Font.caption())
                            .foregroundStyle(Theme.Color.muted)
                    }
                }
            }

            Text(category.name)
                .font(Theme.Font.heading())
                .foregroundStyle(Theme.Color.text)

            Text("Every \(category.frequencyDays) days")
                .font(Theme.Font.label())
                .foregroundStyle(Theme.Color.muted)
        }
        .padding(.top, Theme.Spacing.md)
    }

    // MARK: - Action
    private var actionSection: some View {
        GlowButton("Mark as Done", icon: "checkmark.circle.fill") {
            let completion = Completion(
                date: Date(),
                cost: category.costPerVisit
            )
            category.completions.append(completion)
            Theme.Haptic.success()
        }
    }

    // MARK: - Stats
    private var statsSection: some View {
        GlowCard {
            HStack(spacing: Theme.Spacing.lg) {
                statItem(
                    value: "\(category.completions.count)",
                    label: "Total"
                )
                if let cost = category.costPerVisit, cost > 0 {
                    Divider()
                        .frame(height: 40)
                        .background(Theme.Color.border.opacity(0.3))
                    statItem(
                        value: "$\(Int(cost * Double(category.completions.count)))",
                        label: "Spent"
                    )
                    Divider()
                        .frame(height: 40)
                        .background(Theme.Color.border.opacity(0.3))
                    statItem(
                        value: "$\(Int(cost))",
                        label: "Per Visit"
                    )
                }
                Spacer()
            }
        }
    }

    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: Theme.Spacing.xs) {
            Text(value)
                .font(Theme.Font.data())
                .foregroundStyle(Theme.Color.text)
            Text(label)
                .font(Theme.Font.caption())
                .foregroundStyle(Theme.Color.muted)
        }
    }

    // MARK: - History
    private var historySection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("History")
                .font(Theme.Font.subheading())
                .foregroundStyle(Theme.Color.text)

            if category.completions.isEmpty {
                GlowCard {
                    HStack {
                        Spacer()
                        VStack(spacing: Theme.Spacing.sm) {
                            Image(systemName: "clock")
                                .font(.system(size: 24))
                                .foregroundStyle(Theme.Color.muted)
                            Text("No history yet")
                                .font(Theme.Font.body())
                                .foregroundStyle(Theme.Color.muted)
                            Text("Tap \"Done\" after your next appointment")
                                .font(Theme.Font.caption())
                                .foregroundStyle(Theme.Color.muted.opacity(0.7))
                        }
                        Spacer()
                    }
                    .padding(.vertical, Theme.Spacing.md)
                }
            } else {
                ForEach(category.completions.sorted(by: { $0.date > $1.date })) { completion in
                    HStack(spacing: Theme.Spacing.md) {
                        Circle()
                            .fill(category.accentColor)
                            .frame(width: 8, height: 8)
                        Text(completion.date, format: .dateTime.month(.abbreviated).day().year())
                            .font(Theme.Font.body())
                            .foregroundStyle(Theme.Color.text)
                        Spacer()
                        if let cost = completion.cost, cost > 0 {
                            Text("$\(Int(cost))")
                                .font(Theme.Font.label())
                                .foregroundStyle(Theme.Color.muted)
                        }
                    }
                    .padding(.vertical, Theme.Spacing.sm)
                }
            }
        }
    }
}
