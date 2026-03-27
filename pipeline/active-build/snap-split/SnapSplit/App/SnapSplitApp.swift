import SwiftUI
import RevenueCat

@main
struct SnapSplitApp: App {
    @StateObject private var scanTracker = ScanTracker()

    init() {
        // RevenueCat configuration -- API key from environment, never hardcoded
        let rcKey = ProcessInfo.processInfo.environment["REVENUECAT_API_KEY"] ?? ""
        if !rcKey.isEmpty {
            Purchases.configure(withAPIKey: rcKey)
        }

        // Set up navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(scanTracker)
        }
    }
}
