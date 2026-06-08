import SwiftUI

/// A lightweight, self-contained celebration overlay: a brief confetti-like burst of
/// SF Symbols plus success haptics, auto-dismissing after ~1.5s. No external deps.
private struct CelebrationModifier: ViewModifier {
    @Binding var isActive: Bool
    @State private var trigger = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .overlay {
                // Confetti is pure motion — skip it entirely under Reduce Motion.
                if isActive && !reduceMotion {
                    ConfettiBurst(reduceMotion: reduceMotion)
                        .allowsHitTesting(false)
                        .transition(.opacity)
                }
            }
            .sensoryFeedback(.success, trigger: trigger)
            .onChange(of: isActive) { _, active in
                guard active else { return }
                trigger.toggle()  // haptic still fires; it isn't motion
                if reduceMotion {
                    // Reach the final state immediately, no animated transition.
                    isActive = false
                } else {
                    // Auto-dismiss after the burst plays out.
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withMotion(.easeOut(duration: 0.3), reduceMotion: reduceMotion) {
                            isActive = false
                        }
                    }
                }
            }
    }
}

extension View {
    /// Shows a brief celebration burst (confetti + success haptic) whenever `isActive`
    /// becomes true, then resets the binding to false automatically.
    func celebration(isActive: Binding<Bool>) -> some View {
        modifier(CelebrationModifier(isActive: isActive))
    }
}

// MARK: - Confetti

/// A handful of symbols that fan out and fade — cheap and dependency-free.
private let confettiSymbols = ["star.fill", "sparkle", "party.popper.fill", "flame.fill", "checkmark.seal.fill"]
private let confettiPalette: [Color] = [.yellow, .orange, .pink, Theme.accent, .green, .purple]

private struct ConfettiBurst: View {
    var reduceMotion: Bool = false

    private let pieces: [Piece] = (0..<18).map { _ in Piece() }

    @State private var animate = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(pieces) { piece in
                    Image(systemName: piece.symbol)
                        .font(.system(size: piece.size))
                        .foregroundStyle(piece.color)
                        .rotationEffect(.degrees(animate ? piece.rotation : 0))
                        .position(
                            x: geo.size.width / 2 + (animate ? piece.dx : 0),
                            y: geo.size.height / 2 + (animate ? piece.dy : 0)
                        )
                        .opacity(animate ? 0 : 1)
                        .scaleEffect(animate ? 1 : 0.2)
                }
            }
            .onAppear {
                // Belt-and-braces: the overlay is already gated on reduceMotion,
                // but guard the internal animation too so the burst never animates.
                withMotion(.easeOut(duration: 1.3), reduceMotion: reduceMotion) {
                    animate = true
                }
            }
        }
        .ignoresSafeArea()
    }

    private struct Piece: Identifiable {
        let id = UUID()
        let symbol = confettiSymbols.randomElement()!
        let color = confettiPalette.randomElement()!
        let size = CGFloat.random(in: 16...30)
        let rotation = Double.random(in: -220...220)
        let dx = CGFloat.random(in: -160...160)
        let dy = CGFloat.random(in: -260 ... -40)
    }
}

#Preview {
    struct Demo: View {
        @State private var active = false
        var body: some View {
            Button("Celebrate") { active = true }
                .buttonStyle(PrimaryButton())
                .padding()
                .celebration(isActive: $active)
        }
    }
    return Demo()
}
