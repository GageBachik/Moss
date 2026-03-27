import SwiftUI

struct ContentView: View {
    @Bindable var settings: UserSettings
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(settings: settings)
                .tabItem {
                    Image(systemName: "star.fill")
                    Text("Streak")
                }
                .tag(0)

            StatsView(settings: settings)
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Stats")
                }
                .tag(1)

            SettingsView(settings: settings)
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
                .tag(2)
        }
        .tint(Theme.Color.primary)
        .onAppear {
            configureTabBarAppearance()
        }
    }

    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Theme.Color.background)

        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.normal.iconColor = UIColor(Theme.Color.muted)
        itemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(Theme.Color.muted)]
        itemAppearance.selected.iconColor = UIColor(Theme.Color.primary)
        itemAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(Theme.Color.primary)]

        appearance.stackedLayoutAppearance = itemAppearance
        appearance.inlineLayoutAppearance = itemAppearance
        appearance.compactInlineLayoutAppearance = itemAppearance

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}
