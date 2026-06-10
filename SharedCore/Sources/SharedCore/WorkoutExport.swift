import Foundation

/// One workout in an export file: a flat, codec-stable view of a logged workout.
public struct WorkoutExportRow: Codable, Sendable, Equatable {
    public let date: Date
    public let type: String
    public let durationMin: Int
    public let energyKcal: Int?
    public let note: String?
    public let source: String

    public init(
        date: Date,
        type: String,
        durationMin: Int,
        energyKcal: Int?,
        note: String?,
        source: String
    ) {
        self.date = date
        self.type = type
        self.durationMin = durationMin
        self.energyKcal = energyKcal
        self.note = note
        self.source = source
    }
}

/// Renders workout history rows as CSV (RFC 4180) or JSON for the share sheet.
/// Pure and deterministic: dates are ISO 8601 in UTC, rows render in input order.
public struct WorkoutExport: Sendable {
    public let rows: [WorkoutExportRow]

    public init(rows: [WorkoutExportRow]) {
        self.rows = rows
    }

    // MARK: - CSV

    static let csvHeader = "date,type,durationMin,energyKcal,note,source"

    /// CSV with a header row, ISO 8601 dates, and RFC 4180 quoting: fields
    /// containing a comma, double quote, or newline are quoted with inner
    /// quotes doubled. An empty history yields just the header.
    public func csv() -> String {
        var lines = [Self.csvHeader]
        for row in rows {
            let fields = [
                row.date.formatted(Self.iso8601),
                row.type,
                String(row.durationMin),
                row.energyKcal.map(String.init) ?? "",
                row.note ?? "",
                row.source,
            ]
            lines.append(fields.map(Self.escapeCSVField).joined(separator: ","))
        }
        return lines.joined(separator: "\n") + "\n"
    }

    private static func escapeCSVField(_ field: String) -> String {
        guard field.contains(where: { $0 == "," || $0 == "\"" || $0 == "\n" || $0 == "\r" }) else {
            return field
        }
        return "\"" + field.replacingOccurrences(of: "\"", with: "\"\"") + "\""
    }

    // MARK: - JSON

    /// JSON array of the same rows with ISO 8601 dates. An empty history
    /// yields an empty array. Fails soft: encoding problems return `[]`.
    public func json() -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.sortedKeys]
        return (try? encoder.encode(rows)) ?? Data("[]".utf8)
    }

    private static let iso8601 = Date.ISO8601FormatStyle()
}
