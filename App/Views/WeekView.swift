import SwiftUI
import SwiftData
import SharedCore

/// The weekly plan plus progress toward the weekly target.
struct WeekView: View {
    let profile: ProfileRecord
    @Query(sort: \WorkoutLog.date, order: .reverse) private var logs: [WorkoutLog]

    private static let weekdayNames = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    var body: some View {
        let p = profile.domain
        let calc = HRZoneCalculator(profile: p)
        let plan = TrainingPlan.weekly(for: p.goal)
        let weekly = TargetsCalculator.weekly(profile: p, plan: plan)
        let minutesProgress = TargetProgress(done: weekMinutes, target: weekly.trainingMinutes)

        NavigationStack {
            List {
                Section("This week's plan") {
                    ForEach(plan.sessions.sorted { $0.day < $1.day }, id: \.day) { s in
                        if s.type == .rest {
                            LabeledContent(Self.weekdayNames[s.day - 1], value: "Rest")
                                .foregroundStyle(.secondary)
                        } else {
                            NavigationLink {
                                WorkoutDetailView(type: s.type, calc: calc)
                            } label: {
                                LabeledContent("\(Self.weekdayNames[s.day - 1])  ·  \(s.type.displayName)",
                                               value: "\(s.durationMin) min")
                            }
                        }
                    }
                }

                Section("Weekly target") {
                    VStack(alignment: .leading, spacing: 6) {
                        ProgressView(value: minutesProgress.fraction)
                        Text("\(minutesProgress.done) / \(minutesProgress.target) min")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    LabeledContent("Hard (4×4) sessions", value: "\(weekly.hardSessions)/week")
                    if let energy = weekly.activeEnergyKcal {
                        LabeledContent("Exercise energy", value: "\(energy) kcal/week")
                    }
                }
            }
            .navigationTitle("Week")
        }
    }

    private var weekMinutes: Int {
        let cal = Calendar.current
        return logs
            .filter { cal.isDate($0.date, equalTo: .now, toGranularity: .weekOfYear) }
            .reduce(0) { $0 + $1.durationMin }
    }
}
