import SwiftUI
import SwiftData

struct AddCategoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var editingCategory: MaintenanceCategory?

    @State private var name: String = ""
    @State private var selectedIcon: String = "sparkles"
    @State private var frequencyDays: Int = 21
    @State private var costPerVisit: String = ""
    @State private var selectedAccentHex: String = "#E8A87C"

    private let icons = [
        "sparkles", "scissors", "drop.fill", "flame.fill",
        "leaf.fill", "paintbrush.fill", "comb.fill", "eyebrow",
        "mouth.fill", "hand.raised.fill", "heart.fill", "star.fill"
    ]

    private let accentColors: [(name: String, hex: String)] = [
        ("Rose Gold", "#E8A87C"),
        ("Coral", "#F4726C"),
        ("Lavender", "#B68FD1"),
        ("Sage", "#8FB09B"),
        ("Sky", "#7CADE8"),
        ("Peach", "#F0B497")
    ]

    private let frequencyPresets: [(label: String, days: Int)] = [
        ("Weekly", 7),
        ("2 Weeks", 14),
        ("3 Weeks", 21),
        ("Monthly", 30),
        ("6 Weeks", 42),
        ("2 Months", 60),
        ("3 Months", 90)
    ]

    private var isEditing: Bool { editingCategory != nil }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Color.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Theme.Spacing.lg) {
                        nameSection
                        iconSection
                        frequencySection
                        costSection
                        colorSection
                    }
                    .padding(.horizontal, Theme.Spacing.md)
                    .padding(.vertical, Theme.Spacing.lg)
                }
            }
            .navigationTitle(isEditing ? "Edit Routine" : "New Routine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        Theme.Haptic.tap()
                        dismiss()
                    }
                    .font(Theme.Font.label())
                    .foregroundStyle(Theme.Color.muted)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Save" : "Add") {
                        save()
                    }
                    .font(Theme.Font.label())
                    .foregroundStyle(name.isEmpty ? Theme.Color.muted : Theme.Color.primary)
                    .disabled(name.isEmpty)
                }
            }
            .onAppear {
                if let cat = editingCategory {
                    name = cat.name
                    selectedIcon = cat.icon
                    frequencyDays = cat.frequencyDays
                    costPerVisit = cat.costPerVisit.map { String(Int($0)) } ?? ""
                    selectedAccentHex = cat.accentHex
                }
            }
        }
    }

    // MARK: - Name
    private var nameSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("Name")
                .font(Theme.Font.label())
                .foregroundStyle(Theme.Color.muted)
            TextField("e.g., Nails, Hair Color, Brows", text: $name)
                .font(Theme.Font.body())
                .foregroundStyle(Theme.Color.text)
                .padding(Theme.Spacing.md)
                .background(Theme.Color.surface)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.medium))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radius.medium)
                        .stroke(Theme.Color.border.opacity(0.3), lineWidth: 0.5)
                )
        }
    }

    // MARK: - Icons
    private var iconSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("Icon")
                .font(Theme.Font.label())
                .foregroundStyle(Theme.Color.muted)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: Theme.Spacing.md) {
                ForEach(icons, id: \.self) { icon in
                    Button {
                        Theme.Haptic.tap()
                        selectedIcon = icon
                    } label: {
                        Image(systemName: icon)
                            .font(.system(size: 20))
                            .foregroundStyle(
                                selectedIcon == icon ? Theme.Color.background : Theme.Color.muted
                            )
                            .frame(width: 44, height: 44)
                            .background(
                                selectedIcon == icon
                                    ? AnyShapeStyle(Theme.Color.primary)
                                    : AnyShapeStyle(Theme.Color.surface)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.small))
                    }
                }
            }
        }
    }

    // MARK: - Frequency
    private var frequencySection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("Frequency")
                .font(Theme.Font.label())
                .foregroundStyle(Theme.Color.muted)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Theme.Spacing.sm) {
                    ForEach(frequencyPresets, id: \.days) { preset in
                        Button {
                            Theme.Haptic.tap()
                            frequencyDays = preset.days
                        } label: {
                            Text(preset.label)
                                .font(Theme.Font.caption())
                                .foregroundStyle(
                                    frequencyDays == preset.days ? Theme.Color.background : Theme.Color.text
                                )
                                .padding(.horizontal, Theme.Spacing.md)
                                .padding(.vertical, Theme.Spacing.sm)
                                .background(
                                    frequencyDays == preset.days
                                        ? Theme.Color.primary
                                        : Theme.Color.surface
                                )
                                .clipShape(Capsule())
                        }
                    }
                }
            }

            Text("Every \(frequencyDays) days")
                .font(Theme.Font.caption())
                .foregroundStyle(Theme.Color.muted)
        }
    }

    // MARK: - Cost
    private var costSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("Cost per Visit (optional)")
                .font(Theme.Font.label())
                .foregroundStyle(Theme.Color.muted)

            HStack(spacing: Theme.Spacing.sm) {
                Text("$")
                    .font(Theme.Font.body())
                    .foregroundStyle(Theme.Color.muted)
                TextField("0", text: $costPerVisit)
                    .font(Theme.Font.body())
                    .foregroundStyle(Theme.Color.text)
                    .keyboardType(.numberPad)
            }
            .padding(Theme.Spacing.md)
            .background(Theme.Color.surface)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.medium))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.medium)
                    .stroke(Theme.Color.border.opacity(0.3), lineWidth: 0.5)
            )
        }
    }

    // MARK: - Color
    private var colorSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("Accent Color")
                .font(Theme.Font.label())
                .foregroundStyle(Theme.Color.muted)

            HStack(spacing: Theme.Spacing.md) {
                ForEach(accentColors, id: \.hex) { color in
                    Button {
                        Theme.Haptic.tap()
                        selectedAccentHex = color.hex
                    } label: {
                        Circle()
                            .fill(Color(hex: color.hex))
                            .frame(width: 36, height: 36)
                            .overlay(
                                Circle()
                                    .stroke(
                                        selectedAccentHex == color.hex
                                            ? Theme.Color.text
                                            : .clear,
                                        lineWidth: 2
                                    )
                                    .padding(-3)
                            )
                    }
                }
            }
        }
    }

    // MARK: - Save
    private func save() {
        Theme.Haptic.success()
        let cost = Double(costPerVisit)

        if let cat = editingCategory {
            cat.name = name
            cat.icon = selectedIcon
            cat.frequencyDays = frequencyDays
            cat.costPerVisit = cost
            cat.accentHex = selectedAccentHex
        } else {
            let newCategory = MaintenanceCategory(
                name: name,
                icon: selectedIcon,
                frequencyDays: frequencyDays,
                costPerVisit: cost,
                accentHex: selectedAccentHex
            )
            modelContext.insert(newCategory)
        }

        dismiss()
    }
}
