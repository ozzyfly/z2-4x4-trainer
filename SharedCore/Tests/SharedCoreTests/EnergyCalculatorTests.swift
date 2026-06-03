import Testing
@testable import SharedCore

@Suite("Energy")
struct EnergyCalculatorTests {
    let male = UserProfile(age: 30, sex: .male, weightKg: 80, heightCm: 180, activityLevel: .moderate)
    let female = UserProfile(age: 30, sex: .female, weightKg: 80, heightCm: 180, activityLevel: .moderate)

    @Test("Mifflin–St Jeor BMR (male)")
    func bmrMale() {
        #expect(EnergyCalculator.bmr(profile: male) == 1780)   // 800+1125-150+5
    }

    @Test("Mifflin–St Jeor BMR (female)")
    func bmrFemale() {
        #expect(EnergyCalculator.bmr(profile: female) == 1614)  // 800+1125-150-161
    }

    @Test("TDEE scales BMR by activity factor")
    func tdee() {
        #expect(EnergyCalculator.tdee(profile: male) == 1780 * 1.55)
    }

    @Test("0.5 kg/week needs a 550 kcal/day deficit")
    func deficit() {
        #expect(EnergyCalculator.dailyDeficit(rateKgPerWeek: 0.5) == 550)  // 0.5*7700/7
    }

    @Test("maintain goal has zero deficit")
    func maintainEnergy() {
        let e = EnergyCalculator.dailyEnergy(profile: male)
        #expect(e.deficit == 0)
        #expect(e.intakeTarget == e.tdee)
    }

    @Test("lose-weight goal subtracts the deficit from intake")
    func loseEnergy() {
        var p = male
        p.goal = .loseWeight(rateKgPerWeek: 0.5)
        let e = EnergyCalculator.dailyEnergy(profile: p)
        #expect(e.deficit == 550)
        #expect(e.intakeTarget == e.tdee - 550)
    }
}
