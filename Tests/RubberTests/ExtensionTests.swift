import Foundation
import Testing

@testable import Rubber

@Suite("Rubber Band Extension Tests")
struct ExtensionTests {
    @Test("Double extension with closed range using default config")
    func doubleExtensionClosedRangeDefault() {
        let result = 3.0.rubber(1.0 ... 2.0)
        #expect(result > 2.0)

        // Value within range should be unchanged
        let withinRange = 1.5.rubber(1.0 ... 2.0)
        #expect(withinRange == 1.5)
    }

    @Test("Double extension with closed range using preset config")
    func doubleExtensionClosedRangePreset() {
        let result = 3.0.rubber(1.0 ... 2.0, .bouncy)
        #expect(result > 2.0)

        // Different configs should produce different results
        let bouncyResult = 3.0.rubber(1.0 ... 2.0, .bouncy)
        let smoothResult = 3.0.rubber(1.0 ... 2.0, .smooth)
        let snappyResult = 3.0.rubber(1.0 ... 2.0, .snappy)

        #expect(bouncyResult != smoothResult)
        #expect(smoothResult != snappyResult)
    }

    @Test("Double extension with open range")
    func doubleExtensionOpenRange() {
        let result = 3.0.rubber(1.0 ..< 2.0, .smooth)
        #expect(result > 2.0)

        // Value within range should be unchanged
        let withinRange = 1.5.rubber(1.0 ..< 2.0, .smooth)
        #expect(withinRange == 1.5)
    }

    @Test("Double extension with custom config")
    func doubleExtensionCustomConfig() {
        let customConfig = RubberBandConfig(response: 0.3, dampingFraction: 0.7)
        let result = 3.0.rubber(1.0 ... 2.0, customConfig)
        #expect(result > 2.0)
    }

    @Test("Float extension with closed range")
    func floatExtensionClosedRange() {
        let result = Float(3.0).rubber(Float(1.0) ... Float(2.0), .smooth)
        #expect(result > Float(2.0))

        // Value within range should be unchanged
        let withinRange = Float(1.5).rubber(Float(1.0) ... Float(2.0), .smooth)
        #expect(withinRange == Float(1.5))
    }

    @Test("Float extension with open range")
    func floatExtensionOpenRange() {
        let result = Float(3.0).rubber(Float(1.0) ..< Float(2.0), .smooth)
        #expect(result > Float(2.0))
    }

    @Test("Float extension with different presets")
    func floatExtensionDifferentPresets() {
        let bouncyResult = Float(3.0).rubber(Float(1.0) ... Float(2.0), .bouncy)
        let firmResult = Float(3.0).rubber(Float(1.0) ... Float(2.0), .firm)

        #expect(bouncyResult > Float(2.0))
        #expect(firmResult > Float(2.0))
        #expect(bouncyResult != firmResult)
    }

    @Test("CGFloat extension with closed range")
    func cgfloatExtensionClosedRange() {
        let result = CGFloat(3.0).rubber(CGFloat(1.0) ... CGFloat(2.0), .smooth)
        #expect(result > CGFloat(2.0))

        // Value within range should be unchanged
        let withinRange = CGFloat(1.5).rubber(CGFloat(1.0) ... CGFloat(2.0), .smooth)
        #expect(withinRange == CGFloat(1.5))
    }

    @Test("CGFloat extension with open range")
    func cgfloatExtensionOpenRange() {
        let result = CGFloat(3.0).rubber(CGFloat(1.0) ..< CGFloat(2.0), .smooth)
        #expect(result > CGFloat(2.0))
    }

    @Test("CGFloat extension with elastic preset")
    func cgfloatExtensionElastic() {
        let result = CGFloat(3.0).rubber(CGFloat(1.0) ... CGFloat(2.0), .elastic)
        #expect(result > CGFloat(2.0))

        // Elastic should be different from smooth
        let smoothResult = CGFloat(3.0).rubber(CGFloat(1.0) ... CGFloat(2.0), .smooth)
        #expect(result != smoothResult)
    }

    @Test("Int extension with closed range")
    func intExtensionClosedRange() {
        let result = 4.rubber(1 ... 2, .smooth)
        #expect(result > 2)

        // Value within range should be unchanged
        let withinRange = 1.rubber(1 ... 2, .smooth)
        #expect(withinRange == 1)
    }

    @Test("Int extension with open range")
    func intExtensionOpenRange() {
        let result = 4.rubber(1 ..< 2, .smooth)
        #expect(result > 2)
    }

    @Test("Int extension with loose preset")
    func intExtensionLoose() {
        // Use input value that produces meaningfully different results
        let result = 20.rubber(1 ... 2, .loose)
        let snappyResult = 20.rubber(1 ... 2, .snappy)

        #expect(result > 2)
        #expect(snappyResult > 2)
        #expect(result != snappyResult, "Loose and snappy should produce different results")
    }

    @Test("Negative values work correctly")
    func negativeValues() {
        let result = (-3.0).rubber(-2.0 ... -1.0, .smooth)
        #expect(result < -2.0)
    }

    @Test("Zero range handling")
    func zeroRangeHandling() {
        let result = 5.0.rubber(0.0 ... 0.0, .smooth)
        #expect(result > 0.0)
    }

    @Test("Extensions produce same results as original function")
    func consistencyWithOriginalFunction() {
        let value = 150.0
        let min = 0.0
        let max = 100.0
        let config = RubberBandConfig.smooth

        let originalResult = rubberBand(value: value, min: min, max: max, config: config)
        let extensionResult = value.rubber(min ... max, config)

        #expect(originalResult == extensionResult)
    }

    @Test("Type conversion accuracy for different configs")
    func typeConversionAccuracy() {
        let doubleValue = 3.0
        let floatValue = Float(3.0)
        let cgfloatValue = CGFloat(3.0)

        let config = RubberBandConfig(response: 0.5, dampingFraction: 1.0)

        let doubleResult = doubleValue.rubber(1.0 ... 2.0, config)
        let floatResult = floatValue.rubber(Float(1.0) ... Float(2.0), config)
        let cgfloatResult = cgfloatValue.rubber(CGFloat(1.0) ... CGFloat(2.0), config)

        // Results should be very close (within floating point precision)
        #expect(abs(doubleResult - Double(floatResult)) < 0.01)
        #expect(abs(doubleResult - Double(cgfloatResult)) < 0.01)
    }

    @Test("All preset configurations work with extensions")
    func allPresetConfigurations() {
        let presets: [RubberBandConfig] = [
            .bouncy, .smooth, .snappy, .loose, .firm, .elastic,
        ]

        for preset in presets {
            let result = 3.0.rubber(1.0 ... 2.0, preset)
            #expect(result > 2.0)
            #expect(result.isFinite)
            #expect(!result.isNaN)
        }
    }

    @Test("Default parameter uses smooth preset")
    func defaultParameterUsesSmooth() {
        let defaultResult = 3.0.rubber(1.0 ... 2.0)
        let explicitSmoothResult = 3.0.rubber(1.0 ... 2.0, .smooth)

        #expect(defaultResult == explicitSmoothResult)
    }

    @Test("Spring characteristics are preserved in extensions")
    func springCharacteristicsPreserved() {
        let testValue = 5.0
        let range = 1.0 ... 2.0

        // Test that different damping fractions produce different results
        let underdamped = RubberBandConfig(response: 0.5, dampingFraction: 0.5)
        let overdamped = RubberBandConfig(response: 0.5, dampingFraction: 1.5)

        let underdampedResult = testValue.rubber(range, underdamped)
        let overdampedResult = testValue.rubber(range, overdamped)

        #expect(underdampedResult != overdampedResult)
        #expect(underdampedResult > 2.0)
        #expect(overdampedResult > 2.0)
    }
}
