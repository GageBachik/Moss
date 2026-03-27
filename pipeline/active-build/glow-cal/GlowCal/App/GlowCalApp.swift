import SwiftUI
import SwiftData
import RevenueCat

@main
struct GlowCalApp: App {
    init() {
        Theme.Font.registerFonts()
        let rcKey = ProcessInfo.processInfo.environment["REVENUECAT_API_KEY"] ?? ""
        if !rcKey.isEmpty {
            Purchases.configure(withAPIKey: rcKey)
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(for: [MaintenanceCategory.self, Completion.self])
    }
}
