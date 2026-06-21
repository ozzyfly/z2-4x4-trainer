import Foundation
import SwiftData
import SharedCore

/// Records a completed on-iPhone guided session as a `WorkoutLog`.
///
/// The decision of whether (and for how long) to log is kept in `durationToLog`
/// so it stays unit-testable without a SwiftUI view. A normally-completed session
/// inserts one log tagged `.guided` and refreshes the widget snapshot; a session
/// ended before its prescribed duration records nothing.
@MainActor
struct GuidedSessionLogger {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    /// Minutes to log for a finished/ended guided session, or `nil` when the
    /// session does not qualify (cancelled early, or a rest day).
    ///
    /// - `.norwegian4x4`: the structured session only counts as complete when the
    ///   engine reports `isFinished`; it always logs the full structured duration.
    /// - `.zone2`: open-ended, so it logs the actual elapsed minutes only once they
    ///   reach the prescribed duration. Below that the session is treated as cancelled.
    static func durationToLog(type: SessionType,
                              isFinished: Bool,
                              elapsedSec: Int,
                              prescribedMinutes: Int) -> Int? {
        switch type {
        case .norwegian4x4:
            return isFinished ? Norwegian4x4.totalDurationSec / 60 : nil
        case .zone2:
            let minutes = elapsedSec / 60
            return minutes >= prescribedMinutes ? minutes : nil
        case .rest:
            return nil
        }
    }

    /// Inserts a `WorkoutLog` for a qualifying guided session and refreshes the
    /// widget snapshot. Returns true when a log was created.
    @discardableResult
    func log(type: SessionType,
             isFinished: Bool,
             elapsedSec: Int,
             prescribedMinutes: Int) -> Bool {
        guard let durationMin = Self.durationToLog(
            type: type, isFinished: isFinished,
            elapsedSec: elapsedSec, prescribedMinutes: prescribedMinutes) else { return false }
        context.insert(WorkoutLog(type: type, durationMin: durationMin, source: .guided))
        WidgetSnapshotWriter.update(context: context)
        return true
    }
}
