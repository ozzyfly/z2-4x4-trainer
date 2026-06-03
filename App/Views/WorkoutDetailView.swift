import SwiftUI
import SharedCore

/// Instructions for a Zone 2 or Norwegian 4×4 session with personalised HR bands.
struct WorkoutDetailView: View {
    let type: SessionType
    let calc: HRZoneCalculator

    var body: some View {
        List {
            switch type {
            case .zone2:
                Section("Zone 2 — aerobic base") {
                    Text("Hold a steady, conversational effort. Stay in your Zone 2 band for the whole session.")
                    ZoneRow(title: "Target HR", range: calc.zone2)
                }
            case .norwegian4x4:
                Section("Norwegian 4×4") {
                    Text("Four 4-minute hard intervals at 85–95% max HR, each followed by 3 minutes of easy recovery. Warm up and cool down properly.")
                    ZoneRow(title: "Hard band", range: calc.fourByFourHard)
                    ZoneRow(title: "Recovery band", range: calc.zone2)
                }
                Section("Structure") {
                    ForEach(Array(Norwegian4x4.build(using: calc).enumerated()), id: \.offset) { _, interval in
                        IntervalRow(interval: interval)
                    }
                }
            case .rest:
                Section { Text("Rest day.") }
            }
        }
        .navigationTitle(type.displayName)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct IntervalRow: View {
    let interval: WorkoutInterval

    var body: some View {
        LabeledContent {
            Text(rangeText)
        } label: {
            Text("\(interval.kind.rawValue.capitalized) · \(interval.durationSec / 60) min")
        }
    }

    private var rangeText: String {
        guard let r = interval.targetHR else { return "—" }
        return "\(r.lower)–\(r.upper) bpm"
    }
}
