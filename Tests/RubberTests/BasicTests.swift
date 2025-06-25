import Testing

@testable import Rubber

@Suite("Rubber Band Function Tests")
struct RubberBandTests {
    @Test("Values within range are not modified")
    func valuesWithinRange() {
        let min = 0.0
        let max = 100.0
        let config = RubberBandConfig(response: 0.55, dampingFraction: 1.0)

        #expect(rubberBand(value: 25.0, min: min, max: max, config: config) == 25.0)
        #expect(rubberBand(value: 0.0, min: min, max: max, config: config) == 0.0)
        #expect(rubberBand(value: 100.0, min: min, max: max, config: config) == 100.0)
        #expect(rubberBand(value: 50.0, min: min, max: max, config: config) == 50.0)
    }

    @Test("Values above maximum are rubber banded")
    func valuesAboveMaximum() {
        let min = 0.0
        let max = 100.0
        let config = RubberBandConfig.smooth

        let result1 = rubberBand(value: 150.0, min: min, max: max, config: config)
        let result2 = rubberBand(value: 200.0, min: min, max: max, config: config)

        // Results should be above max
        #expect(result1 > max)
        #expect(result2 > max)

        // Higher input values should produce higher output values (monotonic)
        #expect(result2 > result1)
    }

    @Test("Values below minimum are rubber banded")
    func valuesBelowMinimum() {
        let min = 0.0
        let max = 100.0
        let config = RubberBandConfig.smooth

        let result1 = rubberBand(value: -50.0, min: min, max: max, config: config)
        let result2 = rubberBand(value: -100.0, min: min, max: max, config: config)

        // Results should be below min
        #expect(result1 < min)
        #expect(result2 < min)

        // Lower input values should produce lower output values (monotonic)
        #expect(result2 < result1)
    }

    @Test("Different spring configurations produce different results")
    func differentSpringConfigurations() {
        let min = 0.0
        let max = 100.0
        let testValue = 150.0

        let bouncyResult = rubberBand(value: testValue, min: min, max: max, config: .bouncy)
        let smoothResult = rubberBand(value: testValue, min: min, max: max, config: .smooth)
        let snappyResult = rubberBand(value: testValue, min: min, max: max, config: .snappy)

        // All should be above max but produce different results
        #expect(bouncyResult > max)
        #expect(smoothResult > max)
        #expect(snappyResult > max)

        // Results should be different due to different spring characteristics
        #expect(bouncyResult != smoothResult)
        #expect(smoothResult != snappyResult)
        #expect(bouncyResult != snappyResult)
    }

    @Test("Spring response affects resistance buildup")
    func springResponseEffect() {
        let min = 0.0
        let max = 100.0
        let testValue = 150.0

        let lowResponse = RubberBandConfig(response: 0.2, dampingFraction: 1.0)
        let highResponse = RubberBandConfig(response: 0.8, dampingFraction: 1.0)

        let lowResult = rubberBand(value: testValue, min: min, max: max, config: lowResponse)
        let highResult = rubberBand(value: testValue, min: min, max: max, config: highResponse)

        // Both should be above max but with different resistance characteristics
        #expect(lowResult > max)
        #expect(highResult > max)
        #expect(lowResult != highResult)
    }

    @Test("Damping fraction affects curve shape")
    func dampingFractionEffect() {
        let min = 0.0
        let max = 100.0
        let testValue = 150.0

        let underdamped = RubberBandConfig(response: 0.5, dampingFraction: 0.5)
        let criticallyDamped = RubberBandConfig(response: 0.5, dampingFraction: 1.0)
        let overdamped = RubberBandConfig(response: 0.5, dampingFraction: 1.5)

        let underdampedResult = rubberBand(
            value: testValue, min: min, max: max, config: underdamped
        )
        let criticalResult = rubberBand(
            value: testValue, min: min, max: max, config: criticallyDamped
        )
        let overdampedResult = rubberBand(value: testValue, min: min, max: max, config: overdamped)

        // All should be above max but with different curve characteristics
        #expect(underdampedResult > max)
        #expect(criticalResult > max)
        #expect(overdampedResult > max)

        // Results should be different due to different damping
        #expect(underdampedResult != criticalResult)
        #expect(criticalResult != overdampedResult)
        #expect(underdampedResult != overdampedResult)
    }

    @Test("Edge cases with very small values")
    func edgeCasesSmallValues() {
        let min = 0.0
        let max = 1.0
        let config = RubberBandConfig(response: 0.5, dampingFraction: 1.0)

        let result = rubberBand(value: 2.0, min: min, max: max, config: config)
        #expect(result > max)
    }

    @Test("Edge cases with very large values")
    func edgeCasesLargeValues() {
        let min = 0.0
        let max = 1_000_000.0
        let config = RubberBandConfig.smooth

        let result = rubberBand(value: 2_000_000.0, min: min, max: max, config: config)
        #expect(result > max)
    }

    @Test("Symmetry test")
    func symmetryTest() {
        let min = -50.0
        let max = 50.0
        let config = RubberBandConfig.smooth

        let positiveOvershoot = rubberBand(value: 75.0, min: min, max: max, config: config)
        let negativeOvershoot = rubberBand(value: -75.0, min: min, max: max, config: config)

        // Due to symmetry, the distances from the boundaries should be similar
        let positiveDistance = positiveOvershoot - max
        let negativeDistance = min - negativeOvershoot

        #expect(abs(positiveDistance - negativeDistance) < 1.0) // Relaxed tolerance for new physics
    }

    @Test(
        "Parameterized test with different spring presets",
        arguments: [
            RubberBandConfig.bouncy,
            RubberBandConfig.smooth,
            RubberBandConfig.snappy,
            RubberBandConfig.loose,
            RubberBandConfig.firm,
            RubberBandConfig.elastic,
        ]
    )
    func differentSpringPresets(config: RubberBandConfig) {
        let min = 0.0
        let max = 100.0
        let testValue = 150.0

        let result = rubberBand(value: testValue, min: min, max: max, config: config)
        #expect(result > max)
    }

    @Test("Monotonic behavior verification")
    func monotonicBehavior() {
        let min = 0.0
        let max = 100.0
        let config = RubberBandConfig.smooth

        let values = [110.0, 120.0, 130.0, 140.0, 150.0]
        let results = values.map {
            rubberBand(value: $0, min: min, max: max, config: config)
        }

        // Verify that results are in ascending order (monotonic)
        for i in 1 ..< results.count {
            #expect(results[i] > results[i - 1])
        }
    }

    @Test("Preset configurations have expected characteristics")
    func presetCharacteristics() {
        // Test that bouncy has lower damping than smooth
        #expect(RubberBandConfig.bouncy.dampingFraction < RubberBandConfig.smooth.dampingFraction)

        // Test that snappy has higher response than smooth
        #expect(RubberBandConfig.snappy.response > RubberBandConfig.smooth.response)

        // Test that loose has lower response than firm
        #expect(RubberBandConfig.loose.response < RubberBandConfig.firm.response)

        // Test that elastic has the lowest damping
        #expect(RubberBandConfig.elastic.dampingFraction < RubberBandConfig.bouncy.dampingFraction)
    }
}
