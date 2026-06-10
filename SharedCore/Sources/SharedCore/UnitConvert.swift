import Foundation

/// Pure metric ↔ imperial conversions for body metrics. Display-layer only:
/// stored values remain metric, so these never feed training calculations.
public enum UnitConvert {
    /// Pounds per kilogram (international avoirdupois definition).
    static let lbPerKg = 2.204_622_621_848_776
    /// Centimetres per inch (exact).
    static let cmPerInch = 2.54

    /// Converts kilograms to pounds.
    public static func kgToLb(_ kg: Double) -> Double {
        kg * lbPerKg
    }

    /// Converts pounds to kilograms.
    public static func lbToKg(_ lb: Double) -> Double {
        lb / lbPerKg
    }

    /// Converts centimetres to whole feet and inches, rounding to the nearest
    /// inch and carrying 12 inches into a foot (never returns inches == 12).
    /// Non-positive input maps to (0, 0).
    public static func cmToFeetInches(_ cm: Double) -> (feet: Int, inches: Int) {
        guard cm > 0 else { return (0, 0) }
        let totalInches = Int((cm / cmPerInch).rounded())
        return (feet: totalInches / 12, inches: totalInches % 12)
    }

    /// Converts feet and inches to centimetres.
    public static func feetInchesToCm(feet: Int, inches: Int) -> Double {
        Double(feet * 12 + inches) * cmPerInch
    }
}
