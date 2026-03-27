import SwiftUI
import SwiftData
import RevenueCat

@main
struct NoSpendStreakApp: App {
    @State private var settings = UserSettings()

    init() {
        let rcKey = ProcessInfo.processInfo.environment["REVENUECAT_API_KEY"] ?? ""
        if !rcKey.isEmpty {
            Purchases.configure(withAPIKey: rcKey)
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView(settings: settings)
        }
        .modelContainer(for: SpendDay.self)
    }
}
