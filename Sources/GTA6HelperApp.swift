import SwiftUI

@main
struct GTA6HelperApp: App {
    @StateObject private var store = GuideStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
