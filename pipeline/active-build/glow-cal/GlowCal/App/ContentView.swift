import SwiftUI

struct ContentView: View {
    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            HomeView(showPaywall: $showPaywall)
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }
}
