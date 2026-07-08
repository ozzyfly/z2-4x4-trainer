import Foundation
import StoreKit
import Observation
import os

private let log = Logger(subsystem: "ca.logolo.z24x4", category: "ProStore")

/// The one-time "Pro" unlock: StoreKit 2, a single non-consumable, verified
/// entirely on-device (`Transaction.currentEntitlements`) — no server, no
/// account, in keeping with the app's local-only promise.
///
/// Early adopters ride free: anyone whose first launch predates
/// `grandfatherCutoff` is treated as Pro forever (the v1.0 "free while we earn
/// reviews" cohort). The check is pure and unit-tested (`isGrandfathered`).
@Observable
@MainActor
final class ProStore {
    /// Non-consumable product id — must match App Store Connect and Z24x4.storekit.
    static let productID = "ca.logolo.z24x4.pro.lifetime"
    /// First launches before this date are Pro for free (launch-cohort thank-you).
    nonisolated static let grandfatherCutoff = ISO8601DateFormatter().date(from: "2026-08-01T00:00:00Z")!
    private static let firstLaunchKey = "firstLaunchDate"

    /// Whether Pro features are unlocked (purchase, grandfathering, or `-pro`).
    private(set) var isPro = false
    /// The store product, once loaded (nil offline — purchase button hides).
    private(set) var product: Product?
    /// True while a purchase/restore is in flight.
    private(set) var isPurchasing = false

    @ObservationIgnored private var updatesTask: Task<Void, Never>?
    /// `-nogrand` disables launch-cohort grandfathering so the paywall and
    /// gates are visible on dev machines whose first launch predates the
    /// cutoff — otherwise the free-user experience is untestable in the sim.
    @ObservationIgnored private let grandfatherDisabled =
        ProcessInfo.processInfo.arguments.contains("-nogrand")

    init() {
        // Stamp the first launch exactly once; the value never changes after.
        if UserDefaults.standard.object(forKey: Self.firstLaunchKey) == nil {
            UserDefaults.standard.set(Date.now, forKey: Self.firstLaunchKey)
        }
        // UI-test/screenshot override, mirrors -mockHealth's spirit.
        if ProcessInfo.processInfo.arguments.contains("-pro") {
            isPro = true
        }
    }

    /// Pure grandfathering rule, unit-tested: first launch strictly before the
    /// cutoff unlocks Pro forever.
    nonisolated static func isGrandfathered(firstLaunch: Date?, cutoff: Date = grandfatherCutoff) -> Bool {
        guard let firstLaunch else { return false }
        return firstLaunch < cutoff
    }

    /// Call once at startup: applies grandfathering, checks current
    /// entitlements, loads the product, and starts listening for updates
    /// (purchases on other devices, refunds, Ask to Buy approvals).
    func start() async {
        if !grandfatherDisabled,
           Self.isGrandfathered(firstLaunch: UserDefaults.standard.object(forKey: Self.firstLaunchKey) as? Date) {
            isPro = true
        }
        await refreshEntitlement()
        updatesTask = Task { [weak self] in
            for await update in Transaction.updates {
                guard let self else { break }
                if case .verified(let transaction) = update {
                    await transaction.finish()
                    await self.refreshEntitlement()
                }
            }
        }
        do {
            product = try await Product.products(for: [Self.productID]).first
        } catch {
            log.error("product load failed: \(error)")
        }
    }

    /// Buys the lifetime unlock. Returns true when Pro ended up unlocked.
    @discardableResult
    func purchase() async -> Bool {
        guard let product, !isPurchasing else { return isPro }
        isPurchasing = true
        defer { isPurchasing = false }
        do {
            switch try await product.purchase() {
            case .success(.verified(let transaction)):
                await transaction.finish()
                isPro = true
            case .success(.unverified(_, let error)):
                log.error("purchase verification failed: \(error)")
            case .pending, .userCancelled:
                break
            @unknown default:
                break
            }
        } catch {
            log.error("purchase failed: \(error)")
        }
        return isPro
    }

    /// Restores purchases (also runs implicitly via entitlements, but the
    /// review guidelines require an explicit button).
    func restore() async {
        try? await AppStore.sync()
        await refreshEntitlement()
    }

    private func refreshEntitlement() async {
        // Grandfathered / -pro users stay unlocked regardless of the store.
        guard !isPro else { return }
        for await entitlement in Transaction.currentEntitlements {
            if case .verified(let transaction) = entitlement,
               transaction.productID == Self.productID,
               transaction.revocationDate == nil {
                isPro = true
                return
            }
        }
    }
}
