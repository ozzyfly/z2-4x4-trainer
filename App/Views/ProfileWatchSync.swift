import SwiftUI
import SwiftData
import SharedCore

/// Pushes the profile (and a freshly computed snapshot) to the paired Apple Watch
/// shortly after any zone-affecting field changes, so edits reach the watch right
/// away instead of waiting for the next app activation.
///
/// Debounced (~400 ms) so a burst of stepper taps coalesces into a single push.
/// `WidgetSnapshotWriter.update` always sends snapshot + profile together, and the
/// watch applies each key independently, so this never clobbers cached state.
private struct ProfileWatchSyncModifier: ViewModifier {
    let profile: ProfileRecord
    let context: ModelContext
    @State private var pushTask: Task<Void, Never>?

    /// Compact fingerprint of every field the watch's zone math depends on.
    private var signature: String {
        "\(profile.age)|\(profile.maxHROverride ?? -1)|\(profile.restingHR ?? -1)|\(profile.zoneMethodRaw)|\(profile.customZoneLowers ?? [])|\(profile.customZoneUppers ?? [])|\(profile.hardEffortStrict)|\(profile.warmupMinSec)|\(profile.hardWallCapSec)|\(profile.recoveryMinSec)"
    }

    func body(content: Content) -> some View {
        content.onChange(of: signature) { _, _ in
            pushTask?.cancel()
            pushTask = Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(400))
                guard !Task.isCancelled else { return }
                WidgetSnapshotWriter.update(context: context)
            }
        }
    }
}

extension View {
    /// Syncs the profile to the watch immediately (debounced) whenever a
    /// zone-affecting field changes.
    func syncsProfileToWatch(_ profile: ProfileRecord, context: ModelContext) -> some View {
        modifier(ProfileWatchSyncModifier(profile: profile, context: context))
    }
}
