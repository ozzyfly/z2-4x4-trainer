import SwiftUI
import SwiftData
import SharedCore

/// Today's prescribed workout, personalised zones, and progress toward the daily target.
struct TodayView: View {
    let profile: ProfileRecord
    @Query(sort: \WorkoutLog.date, order: .reverse) private var logs: [WorkoutLog]

    var body: some View {
        let p = profile.domain
        let calc = HRZoneCalculator(profile: p)
        let plan = TrainingPlan.weekly(for: p.goal)
        let today = plan.session(on: .now)
        let daily = TargetsCalculator.daily(profile: p, plan: plan)
        let progress = TargetProgress(done: todaysMinutes, target: daily.trainingMinutes)

        NavigationStack {
            List {
                Section("Today's session") {
                    if today.type == .rest {
                        Label("Rest day — recover well.", systemImage: "moon.zzz.fill")
                    } else {
                        NavigationLink {
                            WorkoutDetailView(type: today.type, calc: calc)
                        } label: {
                            SessionRow(type: today.type, durationMin: today.durationMin)
                        }
                    }
                }

                Section("Your zones") {
                    ZoneRow(title: "Zone 2 (aerobic)", range: calc.zone2)
                    ZoneRow(title: "4×4 hard", range: calc.fourByFourHard)
                    LabeledContent("Max HR", value: "\(calc.maxHR) bpm")
                }

                Section("Daily target") {
                    VStack(alignment: .leading, spacing: 6) {
                        ProgressView(value: progress.fraction)
                        Text("\(progress.done) / \(progress.target) min"
                             + (progress.isMet ? " ✓" : " · \(progress.remaining) to go"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Section {
                    NavigationLink {
                        ManualEntryView(defaultType: today.type == .rest ? .zone2 : today.type)
                    } label: {
                        Label("Log a workout", systemImage: "plus.circle.fill")
                    }
                }
            }
            .navigationTitle("Today")
        }
    }

    private var todaysMinutes: Int {
        let cal = Calendar.current
        return logs.filter { cal.isDateInToday($0.date) }.reduce(0) { $0 + $1.durationMin }
    }
}

/// Display helpers shared by the workout screens.
extension SessionType {
    var displayName: String {
        switch self {
        case .zone2: return "Zone 2"
        case .norwegian4x4: return "Norwegian 4×4"
        case .rest: return "Rest"
        }
    }

    var systemImage: String {
        switch self {
        case .zone2: return "figure.run"
        case .norwegian4x4: return "bolt.heart.fill"
        case .rest: return "moon.zzz.fill"
        }
    }
}

struct SessionRow: View {
    let type: SessionType
    let durationMin: Int

    var body: some View {
        Label {
            VStack(alignment: .leading) {
                Text(type.displayName).font(.headline)
                Text("\(durationMin) min").font(.caption).foregroundStyle(.secondary)
            }
        } icon: {
            Image(systemName: type.systemImage)
        }
    }
}

struct ZoneRow: View {
    let title: String
    let range: HRRange

    var body: some View {
        LabeledContent(title, value: "\(range.lower)–\(range.upper) bpm")
    }
}
