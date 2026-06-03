import Testing
@testable import SharedCore

@Suite("Plan + targets")
struct PlanAndTargetsTests {
    @Test("maintain plan: 3 Zone 2 sessions + 1 hard")
    func maintainPlan() {
        let plan = TrainingPlan.weekly(for: .maintainHealth)
        #expect(plan.weeklyZone2Minutes == 120)   // 3 × 40
        #expect(plan.weeklyHardSessions == 1)
    }

    @Test("lose-weight plan has more volume than maintain")
    func losePlanVolume() {
        let maintain = TrainingPlan.weekly(for: .maintainHealth)
        let lose = TrainingPlan.weekly(for: .loseWeight(rateKgPerWeek: 0.5))
        #expect(lose.weeklyTrainingMinutes > maintain.weeklyTrainingMinutes)
        #expect(lose.weeklyHardSessions == 2)
    }

    @Test("weekly minutes never fall below the WHO 150-minute floor")
    func whoFloor() {
        let profile = UserProfile(age: 40, sex: .female, weightKg: 65, heightCm: 165)
        let plan = TrainingPlan(sessions: [.init(day: 1, type: .zone2, durationMin: 30)])  // only 30 min
        let target = TargetsCalculator.weekly(profile: profile, plan: plan)
        #expect(target.trainingMinutes == 150)
    }

    @Test("maintain target carries no energy goal")
    func maintainNoEnergy() {
        let profile = UserProfile(age: 30, sex: .male, weightKg: 80, heightCm: 180)
        let plan = TrainingPlan.weekly(for: .maintainHealth)
        #expect(TargetsCalculator.weekly(profile: profile, plan: plan).activeEnergyKcal == nil)
    }

    @Test("lose-weight target sets a weekly exercise energy goal")
    func loseEnergyTarget() {
        let profile = UserProfile(age: 30, sex: .male, weightKg: 90, heightCm: 180,
                                  goal: .loseWeight(rateKgPerWeek: 0.5))
        let plan = TrainingPlan.weekly(for: .loseWeight(rateKgPerWeek: 0.5))
        let target = TargetsCalculator.weekly(profile: profile, plan: plan)
        #expect(target.activeEnergyKcal == 1925)   // 550 * 7 * 0.5
    }

    @Test("daily target divides the week across training days")
    func dailySpread() {
        let profile = UserProfile(age: 30, sex: .male, weightKg: 80, heightCm: 180)
        let plan = TrainingPlan.weekly(for: .maintainHealth)   // 4 non-rest days
        let daily = TargetsCalculator.daily(profile: profile, plan: plan)
        let weekly = TargetsCalculator.weekly(profile: profile, plan: plan)
        #expect(daily.trainingMinutes == Int((Double(weekly.trainingMinutes) / 4.0).rounded()))
    }
}
