import Foundation
import Testing
@testable import SharedCore

@Suite("Smart coach")
struct SmartCoachTests {
    private let calendar = Calendar(identifier: .gregorian)
    private let now = Date(timeIntervalSince1970: 1_700_000_000) // fixed reference

    private let profile = UserProfile(age: 30, sex: .male, weightKg: 80, heightCm: 180)
    private var base: TrainingPlan { TrainingPlan.weekly(for: .maintainHealth) }
    private var weeklyTarget: Int {
        TargetsCalculator.weekly(profile: profile, plan: base).trainingMinutes
    }

    /// A record placed `weeksAgo` weeks before `now`, carrying `minutes` of training.
    private func record(weeksAgo: Int, minutes: Int, type: SessionType = .zone2) -> WorkoutRecord {
        let date = calendar.date(byAdding: .weekOfYear, value: -weeksAgo, to: now)!
        return WorkoutRecord(date: date, type: type, durationMin: minutes)
    }

    /// History meeting the target for each of the given past-week offsets.
    private func metWeeks(_ offsets: [Int]) -> [WorkoutRecord] {
        offsets.map { record(weeksAgo: $0, minutes: weeklyTarget) }
    }

    @Test("Progress after 3 consecutive met weeks adds volume")
    func progressAfterConsistency() {
        let history = metWeeks([1, 2, 3])
        let adjusted = PlanProgression.adjust(
            base: base, history: history, profile: profile, now: now, calendar: calendar
        )
        #expect(adjusted.weeklyTrainingMinutes > base.weeklyTrainingMinutes)
    }

    @Test("Hold when the most recent week missed the target")
    func holdAfterMiss() {
        // Weeks 2,3,4 met but the most recent completed week (1) missed.
        var history = metWeeks([2, 3, 4])
        history.append(record(weeksAgo: 1, minutes: 10)) // far below target
        let adjusted = PlanProgression.adjust(
            base: base, history: history, profile: profile, now: now, calendar: calendar
        )
        #expect(adjusted.weeklyTrainingMinutes == base.weeklyTrainingMinutes)
    }

    @Test("Deload on the 4th consecutive progression week reduces volume")
    func deloadEveryFourth() {
        let history = metWeeks([1, 2, 3, 4]) // 4 consecutive met weeks → deload
        let adjusted = PlanProgression.adjust(
            base: base, history: history, profile: profile, now: now, calendar: calendar
        )
        #expect(adjusted.weeklyTrainingMinutes < base.weeklyTrainingMinutes)
    }

    @Test("Hold with fewer than 3 met weeks")
    func holdUntilConsistent() {
        let history = metWeeks([1, 2])
        let adjusted = PlanProgression.adjust(
            base: base, history: history, profile: profile, now: now, calendar: calendar
        )
        #expect(adjusted.weeklyTrainingMinutes == base.weeklyTrainingMinutes)
    }

    @Test("FitnessTrend reports latest value and delta from first")
    func fitnessTrend() {
        let day: TimeInterval = 86_400
        let samples = [
            VO2MaxSample(date: now, value: 44),
            VO2MaxSample(date: now.addingTimeInterval(-2 * day), value: 40),
            VO2MaxSample(date: now.addingTimeInterval(-1 * day), value: 42),
        ]
        let trend = try! #require(FitnessTrend.from(samples))
        #expect(trend.latest == 44)
        #expect(trend.deltaFromFirst == 4) // 44 − 40
        #expect(trend.samples.first?.value == 40) // sorted oldest first
        #expect(trend.samples.last?.value == 44)
    }

    @Test("FitnessTrend is nil for no samples")
    func fitnessTrendEmpty() {
        #expect(FitnessTrend.from([]) == nil)
    }
}
