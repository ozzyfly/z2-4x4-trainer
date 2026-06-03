import SwiftUI
import SwiftData
import Charts
import SharedCore

/// Charts this week's training minutes by weekday and the recent body-weight trend.
struct HistoryView: View {
    let health: HealthStore
    @Query(sort: \WorkoutLog.date, order: .reverse) private var logs: [WorkoutLog]

    private struct DayMinutes: Identifiable {
        let id: Int          // 0 = Mon … 6 = Sun
        let label: String
        let minutes: Int
    }

    private struct WeightPoint: Identifiable {
        let id = UUID()
        let date: Date
        let kg: Double
    }

    private static let weekdayLabels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    private var weeklyByWeekday: [DayMinutes] {
        let samples = logs.map { ActivitySample(date: $0.date, minutes: $0.durationMin, energyKcal: $0.activeEnergyKcal) }
        let totals = ActivityAggregator.weeklyMinutesByWeekday(in: samples, for: .now)
        return totals.enumerated().map { idx, mins in
            DayMinutes(id: idx, label: Self.weekdayLabels[idx], minutes: mins)
        }
    }

    private var weightPoints: [WeightPoint] {
        health.weightSeries.map { WeightPoint(date: $0.date, kg: $0.kg) }
    }

    private var hasTrainingData: Bool {
        weeklyByWeekday.contains { $0.minutes > 0 }
    }

    var body: some View {
        NavigationStack {
            List {
                Section("This week's training minutes") {
                    if hasTrainingData {
                        Chart(weeklyByWeekday) { day in
                            BarMark(
                                x: .value("Day", day.label),
                                y: .value("Minutes", day.minutes)
                            )
                            .foregroundStyle(.tint)
                        }
                        .frame(height: 200)
                    } else {
                        ContentUnavailableView(
                            "No workouts yet",
                            systemImage: "chart.bar.fill",
                            description: Text("Log a workout or connect Apple Health to see your week.")
                        )
                    }
                }

                Section("Body weight trend") {
                    if weightPoints.count > 1 {
                        Chart(weightPoints) { point in
                            LineMark(
                                x: .value("Date", point.date),
                                y: .value("Weight (kg)", point.kg)
                            )
                            .interpolationMethod(.catmullRom)
                            PointMark(
                                x: .value("Date", point.date),
                                y: .value("Weight (kg)", point.kg)
                            )
                        }
                        .chartYScale(domain: .automatic(includesZero: false))
                        .frame(height: 200)
                    } else {
                        ContentUnavailableView(
                            "No weight data",
                            systemImage: "scalemass.fill",
                            description: Text("Connect Apple Health in Settings to track your weight.")
                        )
                    }
                }
            }
            .navigationTitle("History")
        }
    }
}

#Preview {
    HistoryView(health: HealthStore(provider: PreviewHealthService()))
        .modelContainer(for: [ProfileRecord.self, WorkoutLog.self], inMemory: true)
}
