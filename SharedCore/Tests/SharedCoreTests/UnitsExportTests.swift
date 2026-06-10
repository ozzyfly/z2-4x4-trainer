import Foundation
import Testing
@testable import SharedCore

@Suite("Unit preference")
struct UnitPreferenceTests {
    @Test("US locale defaults to imperial")
    func usDefaultsImperial() {
        #expect(UnitPreference.defaultValue(for: Locale(identifier: "en_US")) == .imperial)
    }

    @Test("Metric locales default to metric", arguments: ["zh_TW", "de_DE"])
    func metricLocales(identifier: String) {
        #expect(UnitPreference.defaultValue(for: Locale(identifier: identifier)) == .metric)
    }

    @Test("Encodes and decodes by raw value")
    func codableRoundTrip() throws {
        for preference in UnitPreference.allCases {
            let data = try JSONEncoder().encode([preference])
            let decoded = try JSONDecoder().decode([UnitPreference].self, from: data)
            #expect(decoded == [preference])
        }
    }
}

@Suite("Unit conversion")
struct UnitConvertTests {
    @Test("75 kg converts to 165.35 lb and round-trips within 0.01 kg")
    func weightRoundTrip() {
        let lb = UnitConvert.kgToLb(75)
        #expect(abs(lb - 165.35) < 0.01)
        #expect(abs(UnitConvert.lbToKg(lb) - 75) < 0.01)
    }

    @Test("180 cm is 5 ft 11 in")
    func heightToFeetInches() {
        let result = UnitConvert.cmToFeetInches(180)
        #expect(result.feet == 5)
        #expect(result.inches == 11)
    }

    @Test("5 ft 11 in converts back to about 180 cm")
    func feetInchesToCm() {
        let cm = UnitConvert.feetInchesToCm(feet: 5, inches: 11)
        #expect(abs(cm - 180) <= 1)
    }

    @Test("Whole inches carry into feet")
    func inchCarry() {
        // 182.88 cm is exactly 72 in: must render as 6 ft 0 in, never 5 ft 12 in.
        let result = UnitConvert.cmToFeetInches(182.88)
        #expect(result.feet == 6)
        #expect(result.inches == 0)
    }

    @Test("Zero and negative inputs stay at zero")
    func nonPositiveInputs() {
        #expect(UnitConvert.kgToLb(0) == 0)
        #expect(UnitConvert.lbToKg(0) == 0)
        let zero = UnitConvert.cmToFeetInches(0)
        #expect(zero.feet == 0 && zero.inches == 0)
        let negative = UnitConvert.cmToFeetInches(-10)
        #expect(negative.feet == 0 && negative.inches == 0)
        #expect(UnitConvert.feetInchesToCm(feet: 0, inches: 0) == 0)
    }
}

@Suite("Workout export")
struct WorkoutExportTests {
    private let fixedDate = Date(timeIntervalSince1970: 1_700_000_000) // 2023-11-14T22:13:20Z

    private func row(note: String?) -> WorkoutExportRow {
        WorkoutExportRow(
            date: fixedDate,
            type: "zone2",
            durationMin: 40,
            energyKcal: 320,
            note: note,
            source: "manual"
        )
    }

    @Test("Fixed date renders deterministic ISO8601 in CSV")
    func csvISO8601Date() {
        let csv = WorkoutExport(rows: [row(note: nil)]).csv()
        let lines = csv.split(separator: "\n") // file ends with a trailing newline
        #expect(lines.first == "date,type,durationMin,energyKcal,note,source")
        #expect(lines.count == 2)
        #expect(lines[1] == "2023-11-14T22:13:20Z,zone2,40,320,,manual")
    }

    @Test("Notes with comma, quote, and newline escape per RFC 4180")
    func csvEscaping() {
        let csv = WorkoutExport(rows: [row(note: "felt \"great\", then\ntired")]).csv()
        let expectedField = "\"felt \"\"great\"\", then\ntired\""
        #expect(csv.contains(expectedField))
        // Header plus one record; the newline inside the quoted field is preserved.
        #expect(csv.hasPrefix("date,type,durationMin,energyKcal,note,source\n"))
    }

    @Test("Empty history exports header-only CSV and empty JSON array")
    func emptyExport() throws {
        let export = WorkoutExport(rows: [])
        #expect(export.csv() == "date,type,durationMin,energyKcal,note,source\n")
        let json = try JSONSerialization.jsonObject(with: export.json()) as? [Any]
        #expect(json?.isEmpty == true)
    }

    @Test("JSON encodes one element per row with ISO8601 dates")
    func jsonRows() throws {
        let data = WorkoutExport(rows: [row(note: "easy spin")]).json()
        let array = try #require(try JSONSerialization.jsonObject(with: data) as? [[String: Any]])
        #expect(array.count == 1)
        #expect(array[0]["date"] as? String == "2023-11-14T22:13:20Z")
        #expect(array[0]["type"] as? String == "zone2")
        #expect(array[0]["durationMin"] as? Int == 40)
        #expect(array[0]["energyKcal"] as? Int == 320)
        #expect(array[0]["note"] as? String == "easy spin")
        #expect(array[0]["source"] as? String == "manual")
    }
}
