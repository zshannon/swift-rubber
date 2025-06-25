import Foundation
import Testing

@testable import Rubber

@Suite("Advanced Rubber Band Tests")
struct AdvancedRubberBandTests {
    // MARK: - Performance Tests

    @Test("Performance test for rubber band function")
    func performanceTest() async {
        let min = 0.0
        let max = 100.0
        let config = RubberBandConfig.smooth

        let startTime = CFAbsoluteTimeGetCurrent()

        // Perform many calculations
        for i in 0 ..< 100_000 {
            let value = Double(i) * 0.01
            _ = rubberBand(value: value, min: min, max: max, config: config)
        }

        let executionTime = CFAbsoluteTimeGetCurrent() - startTime

        // Should complete within reasonable time (adjust threshold as needed)
        #expect(executionTime < 1.0, "Performance regression detected: \(executionTime)s")
    }

    // MARK: - Property-Based Testing Concepts

    @Test(
        "Property: Output is always finite",
        arguments: [
            (value: 1000.0, min: 0.0, max: 100.0, config: RubberBandConfig.smooth),
            (value: -1000.0, min: 0.0, max: 100.0, config: RubberBandConfig.bouncy),
            (
                value: Double.greatestFiniteMagnitude / 2, min: 0.0, max: 100.0,
                config: RubberBandConfig.snappy
            ),
            (value: 0.0, min: -100.0, max: 100.0, config: RubberBandConfig.loose),
        ]
    )
    func outputIsAlwaysFinite(value: Double, min: Double, max: Double, config: RubberBandConfig) {
        let result = rubberBand(value: value, min: min, max: max, config: config)
        #expect(result.isFinite, "Result should always be finite")
        #expect(!result.isNaN, "Result should never be NaN")
        #expect(!result.isInfinite, "Result should never be infinite")
    }

    @Test(
        "Property: Identity within bounds",
        arguments: [
            (min: 0.0, max: 100.0, config: RubberBandConfig.smooth),
            (min: -50.0, max: 50.0, config: RubberBandConfig.bouncy),
            (min: 10.0, max: 20.0, config: RubberBandConfig.firm),
        ]
    )
    func identityWithinBounds(min: Double, max: Double, config: RubberBandConfig) {
        let midpoint = (min + max) / 2
        let quarterPoint = min + (max - min) / 4
        let threeQuarterPoint = min + 3 * (max - min) / 4

        #expect(rubberBand(value: min, min: min, max: max, config: config) == min)
        #expect(rubberBand(value: max, min: min, max: max, config: config) == max)
        #expect(rubberBand(value: midpoint, min: min, max: max, config: config) == midpoint)
        #expect(
            rubberBand(value: quarterPoint, min: min, max: max, config: config)
                == quarterPoint
        )
        #expect(
            rubberBand(value: threeQuarterPoint, min: min, max: max, config: config)
                == threeQuarterPoint
        )
    }

    @Test("Property: Bounded output for values outside range")
    func boundedOutputForValuesOutsideRange() {
        let min = 0.0
        let max = 100.0
        let config = RubberBandConfig.smooth

        // Test extreme positive values
        let extremePositive = [150.0, 1000.0, 10000.0, 100_000.0]
        for value in extremePositive {
            let result = rubberBand(value: value, min: min, max: max, config: config)
            #expect(result > max, "Result should be greater than max for values above range")
        }

        // Test extreme negative values
        let extremeNegative = [-50.0, -1000.0, -10000.0, -100_000.0]
        for value in extremeNegative {
            let result = rubberBand(value: value, min: min, max: max, config: config)
            #expect(result < min, "Result should be less than min for values below range")
        }
    }

    // MARK: - Edge Cases and Boundary Conditions

    @Test("Edge case: Min equals max")
    func minEqualsMax() {
        let minMax = 50.0
        let config = RubberBandConfig.smooth

        // Value at the point should remain unchanged
        #expect(
            rubberBand(value: minMax, min: minMax, max: minMax, config: config) == minMax
        )

        // Values above should be rubber banded
        let aboveResult = rubberBand(
            value: minMax + 10, min: minMax, max: minMax, config: config
        )
        #expect(aboveResult > minMax)

        // Values below should be rubber banded
        let belowResult = rubberBand(
            value: minMax - 10, min: minMax, max: minMax, config: config
        )
        #expect(belowResult < minMax)
    }

    @Test("Edge case: Very low response")
    func veryLowResponse() {
        let min = 0.0
        let max = 100.0
        let config = RubberBandConfig(response: 0.01, dampingFraction: 1.0)

        let result = rubberBand(value: 200.0, min: min, max: max, config: config)
        #expect(result > max)

        // Low response should create less resistance (less displacement from boundary)
        let normalConfig = RubberBandConfig.smooth
        let normalResult = rubberBand(value: 200.0, min: min, max: max, config: normalConfig)
        #expect(result < normalResult) // Low response creates less displacement
    }

    @Test("Edge case: Very high response")
    func veryHighResponse() {
        let min = 0.0
        let max = 100.0
        let config = RubberBandConfig(response: 2.0, dampingFraction: 1.0)

        let result = rubberBand(value: 150.0, min: min, max: max, config: config)
        #expect(result > max)

        // High response should create stronger resistance (more displacement from boundary)
        let normalConfig = RubberBandConfig.smooth
        let normalResult = rubberBand(value: 150.0, min: min, max: max, config: normalConfig)
        #expect(result > normalResult) // High response creates more displacement
    }

    // MARK: - Spring Physics Tests

    @Test("Underdamped spring behavior")
    func underdampedSpringBehavior() {
        let min = 0.0
        let max = 100.0
        let underdamped = RubberBandConfig(response: 0.5, dampingFraction: 0.3)

        let result = rubberBand(value: 150.0, min: min, max: max, config: underdamped)
        #expect(result > max)
        #expect(result.isFinite)
    }

    @Test("Critically damped spring behavior")
    func criticallyDampedSpringBehavior() {
        let min = 0.0
        let max = 100.0
        let critical = RubberBandConfig(response: 0.5, dampingFraction: 1.0)

        let result = rubberBand(value: 150.0, min: min, max: max, config: critical)
        #expect(result > max)
        #expect(result.isFinite)
    }

    @Test("Overdamped spring behavior")
    func overdampedSpringBehavior() {
        let min = 0.0
        let max = 100.0
        let overdamped = RubberBandConfig(response: 0.5, dampingFraction: 2.0)

        let result = rubberBand(value: 150.0, min: min, max: max, config: overdamped)
        #expect(result > max)
        #expect(result.isFinite)
    }

    @Test("Different damping fractions produce different curves")
    func differentDampingFractions() {
        let min = 0.0
        let max = 100.0
        let testValue = 150.0

        let underdamped = RubberBandConfig(response: 0.5, dampingFraction: 0.5)
        let critical = RubberBandConfig(response: 0.5, dampingFraction: 1.0)
        let overdamped = RubberBandConfig(response: 0.5, dampingFraction: 1.5)

        let underdampedResult = rubberBand(
            value: testValue, min: min, max: max, config: underdamped
        )
        let criticalResult = rubberBand(value: testValue, min: min, max: max, config: critical)
        let overdampedResult = rubberBand(value: testValue, min: min, max: max, config: overdamped)

        // All should produce different results
        #expect(underdampedResult != criticalResult)
        #expect(criticalResult != overdampedResult)
        #expect(underdampedResult != overdampedResult)
    }

    // MARK: - Regression Tests

    @Test("Regression: Preset configurations produce consistent results")
    func regressionPresetConfigurations() {
        let min = 0.0
        let max = 100.0
        let testValue = 150.0

        // Test that preset configurations produce expected relative ordering
        let bouncyResult = rubberBand(value: testValue, min: min, max: max, config: .bouncy)
        let smoothResult = rubberBand(value: testValue, min: min, max: max, config: .smooth)
        let snappyResult = rubberBand(value: testValue, min: min, max: max, config: .snappy)
        let looseResult = rubberBand(value: testValue, min: min, max: max, config: .loose)
        let firmResult = rubberBand(value: testValue, min: min, max: max, config: .firm)
        let elasticResult = rubberBand(value: testValue, min: min, max: max, config: .elastic)

        // All should be greater than max
        let results = [
            bouncyResult, smoothResult, snappyResult, looseResult, firmResult, elasticResult,
        ]
        for result in results {
            #expect(result > max)
            #expect(result.isFinite)
            #expect(!result.isNaN)
        }
    }

    // MARK: - Stress Tests

    @Test("Stress test: Random values with random configs")
    func stressTestRandomValuesAndConfigs() {
        var generator = SystemRandomNumberGenerator()

        for _ in 0 ..< 1000 {
            let min = Double.random(in: -1000 ... 1000, using: &generator)
            let max = min + Double.random(in: 1 ... 1000, using: &generator)
            let response = Double.random(in: 0.1 ... 2.0, using: &generator)
            let dampingFraction = Double.random(in: 0.1 ... 3.0, using: &generator)
            let config = RubberBandConfig(response: response, dampingFraction: dampingFraction)
            let value = Double.random(in: -2000 ... 2000, using: &generator)

            let result = rubberBand(value: value, min: min, max: max, config: config)

            // Basic sanity checks
            #expect(result.isFinite)
            #expect(!result.isNaN)

            if value >= min, value <= max {
                #expect(result == value, "Value within range should be unchanged")
            } else if value > max {
                #expect(result > max, "Value above max should be rubber banded above max")
            } else {
                #expect(result < min, "Value below min should be rubber banded below min")
                #expect(result.isFinite, "Result should be finite even for extreme values")
            }
        }
    }

    // MARK: - Mathematical Properties

    @Test("Mathematical property: Continuity at boundaries")
    func continuityAtBoundaries() {
        let min = 0.0
        let max = 100.0
        let config = RubberBandConfig.smooth
        let epsilon = 0.0001

        // Test continuity at max boundary
        let justBelowMax = rubberBand(
            value: max - epsilon, min: min, max: max, config: config
        )
        let justAboveMax = rubberBand(
            value: max + epsilon, min: min, max: max, config: config
        )
        let atMax = rubberBand(value: max, min: min, max: max, config: config)

        #expect(abs(justBelowMax - atMax) < 0.001, "Function should be continuous at max boundary")
        #expect(
            abs(justAboveMax - atMax) < 1.0,
            "Function should be approximately continuous at max boundary"
        )

        // Test continuity at min boundary
        let justBelowMin = rubberBand(
            value: min - epsilon, min: min, max: max, config: config
        )
        let justAboveMin = rubberBand(
            value: min + epsilon, min: min, max: max, config: config
        )
        let atMin = rubberBand(value: min, min: min, max: max, config: config)

        #expect(abs(justAboveMin - atMin) < 0.001, "Function should be continuous at min boundary")
        #expect(
            abs(justBelowMin - atMin) < 1.0,
            "Function should be approximately continuous at min boundary"
        )
    }

    @Test("Mathematical property: Monotonic behavior for all spring types")
    func monotonicBehaviorAllSpringTypes() {
        let min = 0.0
        let max = 100.0
        let values = [110.0, 120.0, 130.0, 140.0, 150.0, 160.0]

        let configs = [
            RubberBandConfig.bouncy,
            RubberBandConfig.smooth,
            RubberBandConfig.snappy,
            RubberBandConfig.loose,
            RubberBandConfig.firm,
            RubberBandConfig.elastic,
        ]

        for config in configs {
            let results = values.map {
                rubberBand(value: $0, min: min, max: max, config: config)
            }

            // Verify monotonic behavior
            for i in 1 ..< results.count {
                #expect(
                    results[i] > results[i - 1],
                    "Results should be monotonically increasing for \(config)"
                )
            }
        }
    }
}

// MARK: - Helper Extensions for Testing

extension Double {
    /// Helper to check if two doubles are approximately equal
    func isApproximatelyEqual(to other: Double, tolerance: Double = 0.0001) -> Bool {
        abs(self - other) < tolerance
    }
}

extension RubberBandConfig: CustomStringConvertible {
    public var description: String {
        "RubberBandConfig(response: \(response), dampingFraction: \(dampingFraction))"
    }
}

// MARK: - Test Tags and Organization

@Suite("Boundary Value Analysis", .tags(.boundary))
struct BoundaryValueTests {
    @Test("Boundary values comprehensive test", .tags(.comprehensive))
    func boundaryValuesComprehensive() {
        let configurations = [
            (min: 0.0, max: 100.0, config: RubberBandConfig.smooth),
            (min: -50.0, max: 50.0, config: RubberBandConfig.bouncy),
            (min: 1.0, max: 2.0, config: RubberBandConfig.firm),
        ]

        for config in configurations {
            // Test exact boundaries
            #expect(
                rubberBand(
                    value: config.min, min: config.min, max: config.max,
                    config: config.config
                ) == config.min
            )
            #expect(
                rubberBand(
                    value: config.max, min: config.min, max: config.max,
                    config: config.config
                ) == config.max
            )

            // Test just outside boundaries
            let justAbove = rubberBand(
                value: config.max + 0.1, min: config.min, max: config.max,
                config: config.config
            )
            let justBelow = rubberBand(
                value: config.min - 0.1, min: config.min, max: config.max,
                config: config.config
            )

            #expect(justAbove > config.max)
            #expect(justBelow < config.min)
        }
    }

    @Test("Spring preset boundary behavior", .tags(.presets))
    func springPresetBoundaryBehavior() {
        let min = 0.0
        let max = 100.0
        let testValue = 150.0

        let presets: [RubberBandConfig] = [
            .bouncy, .smooth, .snappy, .loose, .firm, .elastic,
        ]

        for preset in presets {
            let result = rubberBand(value: testValue, min: min, max: max, config: preset)
            #expect(result > max, "Preset \(preset) should produce result above max")
            #expect(result.isFinite, "Preset \(preset) should produce finite result")
        }
    }
}

// MARK: - Custom Test Tags

extension Tag {
    @Tag static var boundary: Self
    @Tag static var comprehensive: Self
    @Tag static var performance: Self
    @Tag static var regression: Self
    @Tag static var presets: Self
}
