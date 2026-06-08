import SwiftUI

// MARK: - Reduce Motion helper

/// Runs `body`, animating the state change with `animation` — unless the system
/// Reduce Motion setting is enabled, in which case the change is applied
/// immediately with no animated transition.
///
/// Callers read Reduce Motion from the environment and pass it in, because a
/// free function cannot access the SwiftUI environment itself:
///
/// ```swift
/// @Environment(\.accessibilityReduceMotion) private var reduceMotion
/// // …
/// withMotion(.easeOut(duration: 0.3), reduceMotion: reduceMotion) {
///     isActive = false
/// }
/// ```
@MainActor
func withMotion(_ animation: Animation, reduceMotion: Bool, _ body: () -> Void) {
    if reduceMotion {
        body()
    } else {
        withAnimation(animation, body)
    }
}

extension View {
    /// Declarative counterpart to `withMotion`: applies `animation` driven by
    /// `value`, but disables it when Reduce Motion is enabled. Drop-in for
    /// `.animation(_:value:)` on views that should honor the setting.
    func motionAware<V: Equatable>(_ animation: Animation, value: V) -> some View {
        modifier(MotionAwareModifier(animation: animation, value: value))
    }
}

private struct MotionAwareModifier<V: Equatable>: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let animation: Animation
    let value: V

    func body(content: Content) -> some View {
        content.animation(reduceMotion ? nil : animation, value: value)
    }
}
