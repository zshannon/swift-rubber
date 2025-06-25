import Foundation

/// Configuration for rubber band spring behavior
public struct RubberBandConfig: Equatable, Sendable {
    /// Controls how quickly resistance builds up (spring stiffness)
    public let response: Double

    /// Controls the shape of the resistance curve
    /// 0.0 = underdamped (bouncy), 1.0 = critically damped (smooth), >1.0 = overdamped (viscous)
    public let dampingFraction: Double

    public init(response: Double = 0.55, dampingFraction: Double = 1.0) {
        self.response = response
        self.dampingFraction = dampingFraction
    }

    // Preset configurations
    public static let bouncy = RubberBandConfig(response: 0.4, dampingFraction: 0.6)
    public static let smooth = RubberBandConfig(response: 0.55, dampingFraction: 1.0)
    public static let snappy = RubberBandConfig(response: 0.8, dampingFraction: 1.0)
    public static let loose = RubberBandConfig(response: 0.3, dampingFraction: 0.8)
    public static let firm = RubberBandConfig(response: 0.7, dampingFraction: 1.2)
    public static let elastic = RubberBandConfig(response: 0.35, dampingFraction: 0.4)
}

public protocol RubberBandable: Comparable {
    /// Apply rubber band effect to this value within the given range
    /// - Parameters:
    ///   - range: The valid range (min...max)
    ///   - config: The rubber band configuration
    /// - Returns: The rubber banded value
    func rubber(_ range: ClosedRange<Self>, _ config: RubberBandConfig) -> Self

    /// Apply rubber band effect to this value within the given range
    /// - Parameters:
    ///   - range: The valid range (min..<max)
    ///   - config: The rubber band configuration
    /// - Returns: The rubber banded value
    func rubber(_ range: Range<Self>, _ config: RubberBandConfig) -> Self
}

public extension RubberBandable where Self: BinaryInteger {
    func rubber(_ range: ClosedRange<Self>, _ config: RubberBandConfig = .smooth) -> Self {
        Self(
            rubberBand(
                value: Double(self),
                min: Double(range.lowerBound),
                max: Double(range.upperBound),
                config: config
            )
        )
    }

    func rubber(_ range: Range<Self>, _ config: RubberBandConfig = .smooth) -> Self {
        Self(
            rubberBand(
                value: Double(self),
                min: Double(range.lowerBound),
                max: Double(range.upperBound),
                config: config
            )
        )
    }
}

public extension RubberBandable where Self: BinaryFloatingPoint {
    func rubber(_ range: ClosedRange<Self>, _ config: RubberBandConfig = .smooth) -> Self {
        Self(
            rubberBand(
                value: Double(self),
                min: Double(range.lowerBound),
                max: Double(range.upperBound),
                config: config
            )
        )
    }

    func rubber(_ range: Range<Self>, _ config: RubberBandConfig = .smooth) -> Self {
        Self(
            rubberBand(
                value: Double(self),
                min: Double(range.lowerBound),
                max: Double(range.upperBound),
                config: config
            )
        )
    }
}

public func rubberBand(value: Double, min: Double, max: Double, config: RubberBandConfig)
    -> Double
{
    if value >= min, value <= max {
        // While we're within range we don't rubber band the value.
        return value
    }

    let distance = value > max ? value - max : min - value
    let resistance = calculateResistance(distance: distance, config: config)

    if value > max {
        return max + resistance
    } else {
        return min - resistance
    }
}

private func calculateResistance(distance: Double, config: RubberBandConfig) -> Double {
    let stiffness = config.response
    let damping = config.dampingFraction

    if damping < 1.0 {
        // Underdamped - bouncy spring with oscillatory character
        let frequency = sqrt(1 - damping * damping)
        return distance * (1 - exp(-stiffness * distance) * cos(frequency * stiffness * distance))
    } else if damping == 1.0 {
        // Critically damped - smooth exponential approach
        return distance * (1 - exp(-stiffness * distance))
    } else {
        // Overdamped - sluggish, viscous feel
        let beta = damping - 1.0
        return distance * (1 - exp(-stiffness * distance) * (1 + beta * stiffness * distance))
    }
}
