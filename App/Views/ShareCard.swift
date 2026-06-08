import SwiftUI

/// A branded, fixed-size weekly summary image suitable for sharing to social.
///
/// Pure presentation: it takes plain values so callers can render it off any
/// data source via `ImageRenderer`. The fixed `Self.size` (1080×1350 logical
/// points, a 4:5 portrait card) guarantees a crisp, well-composed export.
struct ShareCard: View {
    let weekStart: Date
    let minutes: Int
    let sessions: Int
    let streakWeeks: Int

    init(weekStart: Date, minutes: Int, sessions: Int, streakWeeks: Int) {
        self.weekStart = weekStart
        self.minutes = minutes
        self.sessions = sessions
        self.streakWeeks = streakWeeks
    }

    /// Logical export size — a clean 4:5 portrait card that shares well.
    static let size = CGSize(width: 1080, height: 1350)

    private var weekRange: String {
        let cal = Calendar.current
        let interval = cal.dateInterval(of: .weekOfYear, for: weekStart)
        let start = interval?.start ?? weekStart
        let end = cal.date(byAdding: .day, value: 6, to: start) ?? weekStart

        let fmt = DateFormatter()
        fmt.dateFormat = "MMM d"
        let endFmt = DateFormatter()
        // Show the year only once, on the end date, for a compact range.
        endFmt.dateFormat = "MMM d, yyyy"
        return "\(fmt.string(from: start)) – \(endFmt.string(from: end))"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            Spacer(minLength: 0)
            statsBlock
            Spacer(minLength: 0)
            footer
        }
        .padding(96)
        .frame(width: Self.size.width, height: Self.size.height, alignment: .topLeading)
        .background(backgroundGradient)
        .environment(\.colorScheme, .dark)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "This week on Z2/4×4 Trainer: \(minutes) \(minutes == 1 ? "minute" : "minutes") trained across "
            + "\(sessions) \(sessions == 1 ? "session" : "sessions"), \(streakWeeks)-week streak"
        )
    }

    // MARK: - Pieces

    private var header: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 20) {
                ZStack {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(Theme.accent)
                        .frame(width: 96, height: 96)
                    Image(systemName: "bolt.heart.fill")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(.white)
                }
                Text("Z2/4×4 Trainer")
                    .font(.rounded(.largeTitle, weight: .heavy))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }

            Text(weekRange.uppercased())
                .font(.rounded(.title3, weight: .semibold))
                .tracking(2)
                .foregroundStyle(Theme.accent)
        }
    }

    private var statsBlock: some View {
        VStack(alignment: .leading, spacing: 56) {
            bigStat(value: "\(minutes)", unit: minutes == 1 ? "minute" : "minutes", caption: "Trained this week")

            HStack(spacing: 64) {
                smallStat(value: "\(sessions)", label: sessions == 1 ? "Session" : "Sessions")
                smallStat(value: "\(streakWeeks)", label: streakWeeks == 1 ? "Week streak" : "Weeks streak")
            }
        }
    }

    private func bigStat(value: String, unit: String, caption: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(caption.uppercased())
                .font(.rounded(.headline, weight: .semibold))
                .tracking(1.5)
                .foregroundStyle(.white.opacity(0.6))
            HStack(alignment: .firstTextBaseline, spacing: 16) {
                Text(value)
                    .font(.system(size: 200, weight: .heavy, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.white)
                Text(unit)
                    .font(.rounded(.title, weight: .bold))
                    .foregroundStyle(Theme.accent)
            }
        }
    }

    private func smallStat(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.system(size: 96, weight: .heavy, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.white)
            Text(label.uppercased())
                .font(.rounded(.headline, weight: .semibold))
                .tracking(1.5)
                .foregroundStyle(.white.opacity(0.6))
        }
    }

    private var footer: some View {
        HStack {
            Capsule()
                .fill(Theme.accent)
                .frame(width: 64, height: 8)
            Spacer()
            Text("Zone 2 · Norwegian 4×4")
                .font(.rounded(.title3, weight: .semibold))
                .foregroundStyle(.white.opacity(0.7))
        }
    }

    private var backgroundGradient: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.09, blue: 0.12),
                    Color(red: 0.02, green: 0.04, blue: 0.06)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            // Subtle accent glow in the corner for brand polish.
            RadialGradient(
                colors: [Theme.accent.opacity(0.35), .clear],
                center: .topTrailing,
                startRadius: 0,
                endRadius: 720
            )
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ShareCard(weekStart: .now, minutes: 120, sessions: 3, streakWeeks: 4)
        .scaleEffect(0.3)
}
