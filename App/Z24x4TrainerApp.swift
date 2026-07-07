import SwiftUI
import SwiftData
import UIKit

@main
struct Z24x4TrainerApp: App {

    private let container: ModelContainer = {
        try! ModelContainer(for: ProfileRecord.self, WorkoutLog.self, AchievementRecord.self, DeletedWorkout.self)
    }()
    @State private var receiver: PhoneSessionReceiver?
    @State private var proStore = ProStore()
    @Environment(\.scenePhase) private var scenePhase

    init() {
        Self.applyNavigationAppearance()
    }

    /// Hermès-style navigation chrome: serif (New York) titles in espresso ink on
    /// the warm ivory background, no hairline shadow. Colors are dynamic so they
    /// adapt to light/dark.
    private static func applyNavigationAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .dynamic(light: 0xF4EFE4, dark: 0x1A1714)
        appearance.shadowColor = .clear

        let ink = UIColor.dynamic(light: 0x2A2521, dark: 0xF0E9DD)
        if let large = serifFont(.largeTitle, weight: .semibold) {
            appearance.largeTitleTextAttributes = [.font: large, .foregroundColor: ink]
        }
        if let inline = serifFont(.headline, weight: .semibold) {
            appearance.titleTextAttributes = [.font: inline, .foregroundColor: ink]
        }

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = .dynamic(light: 0xDD5A12, dark: 0xF2772E)

        // Matching tab bar: warm ivory chrome, no hairline.
        let tab = UITabBarAppearance()
        tab.configureWithOpaqueBackground()
        tab.backgroundColor = .dynamic(light: 0xF4EFE4, dark: 0x1A1714)
        tab.shadowColor = .clear
        // Unselected items in warm taupe; the selected tint (orange) comes from .tint.
        let taupe = UIColor.dynamic(light: 0x8A7C6A, dark: 0xA89C8A)
        for item in [tab.stackedLayoutAppearance, tab.inlineLayoutAppearance, tab.compactInlineLayoutAppearance] {
            item.normal.iconColor = taupe
            item.normal.titleTextAttributes = [.foregroundColor: taupe]
        }
        UITabBar.appearance().standardAppearance = tab
        UITabBar.appearance().scrollEdgeAppearance = tab
    }

    /// A Dynamic-Type-aware serif (New York) `UIFont` for the given text style.
    private static func serifFont(_ style: UIFont.TextStyle, weight: UIFont.Weight) -> UIFont? {
        let base = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style)
        guard let serif = base.withDesign(.serif) else { return nil }
        let weighted = serif.addingAttributes([
            .traits: [UIFontDescriptor.TraitKey.weight: weight]
        ])
        return UIFont(descriptor: weighted, size: 0)
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(proStore)
                .task {
                    if receiver == nil {
                        receiver = PhoneSessionReceiver(context: container.mainContext)
                    }
                    await proStore.start()
                }
        }
        .modelContainer(container)
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                WidgetSnapshotWriter.update(context: container.mainContext)
            }
        }
    }
}
