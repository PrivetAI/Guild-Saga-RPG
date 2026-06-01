import Foundation

// MARK: - Deterministic seeded RNG (SplitMix64)
// All procedural generation (recruit pools, loot rolls, quest rewards) uses this.
// Never String.hashValue / Hasher().

struct HGSplitMix64 {
    private var state: UInt64
    init(seed: UInt64) { self.state = seed }

    mutating func next() -> UInt64 {
        state = state &+ 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        z = z ^ (z >> 31)
        return z
    }

    // Uniform integer in 0..<bound
    mutating func int(_ bound: Int) -> Int {
        guard bound > 0 else { return 0 }
        return Int(next() % UInt64(bound))
    }

    // Inclusive range [lo, hi]
    mutating func range(_ lo: Int, _ hi: Int) -> Int {
        guard hi > lo else { return lo }
        return lo + int(hi - lo + 1)
    }

    // Double in 0..<1
    mutating func double() -> Double {
        return Double(next() >> 11) * (1.0 / 9007199254740992.0)
    }

    mutating func bool() -> Bool { next() & 1 == 0 }

    /// One-shot SplitMix64 finalizer — turns an arbitrary integer into a well-distributed seed.
    static func mix(_ x: UInt64) -> UInt64 {
        var z = x &+ 0x9E3779B97F4A7C15
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
}
