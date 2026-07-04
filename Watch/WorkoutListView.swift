import SwiftUI
import SharedCore
import os

private let log = Logger(subsystem: "ca.logolo.z24x4", category: "WorkoutList")

/// Entry screen: pick a session to start.
struct WorkoutListView: View {
    @State private var manager: WorkoutSessionManager
    /// Latest snapshot pushed from the phone; nil until the first sync lands.
    @State private var snapshot: WidgetSnapshot?
    /// Honors `-autostart4x4` to auto-open the 4×4 live screen for UI screenshots.
    @State private var autoStart4x4 = ProcessInfo.processInfo.arguments.contains("-autostart4x4")

    init() {
        // Prefer the profile synced from the phone (real age / max-HR override /
        // zone method); fall back to a sensible default before the first sync.
        let profile = SyncedProfileStore.read() ?? Self.defaultProfile
        let calculator = HRZoneCalculator(profile: profile)
        _manager = State(initialValue: WorkoutSessionManager(
            calculator: calculator,
            warmupMinSec: profile.warmupMinSec,
            hardWallCapSec: profile.hardWallCapSec,
            recoveryMinSec: profile.recoveryMinSec
        ))
    }

    private static let defaultProfile = UserProfile(
        age: 35,
        sex: .male,
        weightKg: 75,
        heightCm: 178
    )

    var body: some View {
        NavigationStack {
            List {
                StatusSection(snapshot: snapshot)
                ForEach(WatchWorkoutKind.allCases) { kind in
                    NavigationLink {
                        LiveWorkoutView(manager: manager, kind: kind)
                    } label: {
                        WorkoutRow(kind: kind)
                    }
                }
            }
            .navigationTitle("Train")
            .navigationDestination(isPresented: $autoStart4x4) {
                LiveWorkoutView(manager: manager, kind: .fourByFour)
            }
            .task {
                snapshot = WidgetSnapshotStore.read()
                do {
                    try await manager.requestAuthorization()
                } catch {
                    log.error("HealthKit authorization request failed: \(error)")
                }
            }
            // Apply zone changes pushed from the phone while this screen is open.
            .onReceive(NotificationCenter.default.publisher(for: .syncedProfileDidChange)) { note in
                if let profile = note.object as? UserProfile {
                    manager.applyProfileIfIdle(profile)
                } else if let profile = SyncedProfileStore.read() {
                    manager.applyProfileIfIdle(profile)
                }
            }
        }
    }
}

/// Weekly-minutes progress synced from the phone. Shows a neutral placeholder until
/// the first snapshot arrives.
private struct StatusSection: View {
    let snapshot: WidgetSnapshot?

    var body: some View {
        Section {
            if let s = snapshot {
                // The section header already says "This week" — one label, not two.
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(s.weekDoneMinutes)/\(s.weekTargetMinutes) min")
                        .font(.footnote.monospacedDigit())
                        .foregroundStyle(.secondary)
                    ProgressView(value: s.weekFraction)
                        .tint(WatchTheme.accent)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("This week: \(s.weekDoneMinutes) of \(s.weekTargetMinutes) minutes")
            } else {
                Text("Waiting for iPhone sync")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("This week")
        }
    }
}

private struct WorkoutRow: View {
    let kind: WatchWorkoutKind

    var body: some View {
        // One brand accent for both rows — the glyphs (heart vs bolt) already
        // distinguish the sessions; extra colors add noise, not information.
        HStack(spacing: 10) {
            Image(systemName: kind == .zone2 ? "heart.fill" : "bolt.heart.fill")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(WatchTheme.accent)
                .frame(width: 30, height: 30)
                .background(WatchTheme.accent.opacity(0.16), in: Circle())
                .accessibilityHidden(true)
            Text(kind.title)
                .font(.headline)
                .fontWeight(.semibold)
            Spacer(minLength: 0)
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(kind.title) workout")
    }
}

#Preview {
    WorkoutListView()
}
