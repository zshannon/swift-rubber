# Swift Rubber

A Swift library that implements rubber band physics for smooth, elastic interactions in iOS and macOS applications using spring-based damping functions.

## Overview

```swift
import Rubber

let smooth = 3.0.rubber(1...2)  // Natural, balanced resistance
// Returns 2.423
```

The rubber band effect provides a smooth, elastic response when values exceed their intended bounds using realistic spring physics. This is commonly seen in iOS scroll views where content bounces back when scrolled beyond its limits.

Unlike traditional rubber band implementations that use arbitrary mathematical functions, this library employs proper spring physics with configurable response and damping characteristics, giving you intuitive control over the elastic behavior.

## Installation

### Swift Package Manager

Add this to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/zshannon/swift-rubber.git", from: "1.0.0")
]
```

## Usage

### Comparable Extensions (Recommended)

The library provides convenient extensions with spring physics presets:

```swift
import Rubber

// Using spring presets
let result = 3.0.rubber(1...2, .bouncy)   // Springy, elastic feel
// Returns 2.364

let smooth = 3.0.rubber(1...2, .smooth)  // Natural, balanced resistance
// Returns 2.423

let snappy = 3.0.rubber(1...2, .snappy)  // Quick, strong resistance
// Returns 2.551

// Value within range is unchanged
let unchanged = 1.5.rubber(1...2, .smooth)
// Returns 1.5

// Works with integers too (returns Int)
let intResult = 5.rubber(1...3, .loose)

// Negative ranges work fine
let negative = (-10.0).rubber(-5...5, .firm)
```

### Available Spring Presets

- **`.bouncy`** - Low damping, springy and elastic feel
- **`.smooth`** - Critically damped, natural and balanced (default)
- **`.snappy`** - High response, quick resistance buildup
- **`.loose`** - Low response, gentle and gradual resistance
- **`.firm`** - High response with high damping, controlled feel
- **`.elastic`** - Very low damping, maximum spring character

### Custom Spring Configuration

For fine-tuned control, create custom spring configurations:

```swift
// Custom spring configuration
let customSpring = RubberBandConfig(
    response: 0.6,        // Spring stiffness (0.1 - 2.0)
    dampingFraction: 0.8  // Damping behavior (0.1 - 3.0)
)

let result = 150.0.rubber(0...100, customSpring)
```

#### Response Parameter
Controls how quickly the spring responds (stiffness):
- **Lower values (0.1 - 0.4)**: Gentle, gradual resistance buildup
- **Medium values (0.4 - 0.7)**: Balanced resistance
- **Higher values (0.7 - 2.0)**: Quick, strong resistance buildup

#### Damping Fraction Parameter
Controls the curve shape and spring behavior:
- **< 1.0 (Underdamped)**: Bouncy, oscillatory character
- **= 1.0 (Critically Damped)**: Smooth, optimal response without overshoot
- **> 1.0 (Overdamped)**: Sluggish, viscous feel

### Supported Types

The fluent API works with:
- `Double` - Returns `Double`
- `Float` - Returns `Float`
- `CGFloat` - Returns `CGFloat`
- `Int` - Returns `Double`

Both `ClosedRange` (`...`) and `Range` (`..<`) are supported.

### Custom Type Support

You can add rubber band support to your own types by implementing the `RubberBandable` protocol:

```swift
extension MyCustomType: RubberBandable {
    func rubber(_ range: ClosedRange<Self>, _ config: RubberBandConfig = .smooth) -> Self {
        // Convert to Double, apply rubber band, convert back
        let doubleValue = self.toDouble() // Your conversion logic
        let result = rubberBand(
            value: doubleValue,
            min: Double(range.lowerBound.toDouble()),
            max: Double(range.upperBound.toDouble()),
            config: config
        )
        return Self.fromDouble(result) // Your conversion logic
    }

    func rubber(_ range: Range<Self>, _ config: RubberBandConfig = .smooth) -> Self {
        // Similar implementation for Range
        let closedRange = range.lowerBound...range.upperBound
        return rubber(closedRange, config)
    }
}
```

**Requirements:**
- Your type must conform to `Comparable`
- You need conversion methods to/from `Double`
- The protocol provides default implementations for numeric types

**Example with a custom Angle type:**

```swift
struct Angle: Comparable, RubberBandable {
    let degrees: Double

    static func < (lhs: Angle, rhs: Angle) -> Bool {
        lhs.degrees < rhs.degrees
    }

    func rubber(_ range: ClosedRange<Angle>, _ config: RubberBandConfig = .smooth) -> Angle {
        let result = rubberBand(
            value: self.degrees,
            min: range.lowerBound.degrees,
            max: range.upperBound.degrees,
            config: config
        )
        return Angle(degrees: result)
    }

    func rubber(_ range: Range<Angle>, _ config: RubberBandConfig = .smooth) -> Angle {
        let closedRange = range.lowerBound...range.upperBound
        return rubber(closedRange, config)
    }
}

// Usage
let angle = Angle(degrees: 180)
let constrained = angle.rubber(Angle(degrees: 0)...Angle(degrees: 90), .bouncy)
```

## Spring Physics Explained

This library uses exponential damping functions based on real spring physics:

### Underdamped Springs (dampingFraction < 1.0)
```
resistance = distance × (1 - e^(-stiffness×distance) × cos(ω×distance))
```
Creates bouncy, oscillatory behavior with spring-like character.

### Critically Damped Springs (dampingFraction = 1.0)
```
resistance = distance × (1 - e^(-stiffness×distance))
```
Provides smooth, optimal response without overshoot or oscillation.

### Overdamped Springs (dampingFraction > 1.0)
```
resistance = distance × (1 - e^(-stiffness×distance) × (1 + β×stiffness×distance))
```
Creates sluggish, viscous behavior like moving through thick fluid.

### Infinite Damping Behavior

Unlike traditional rubber band implementations that use artificial limits, this library employs **infinite damping** - the spring physics naturally prevent extreme values through exponential resistance buildup:

- The exponential functions asymptotically approach their maximum values
- As distance increases, each additional unit of input produces less output displacement
- This creates natural, physically-accurate bounds without arbitrary cutoffs
- Extreme input values are gracefully handled without discontinuities

## Common Use Cases

### Scroll View Bounce Effect

```swift
let scrollPositions = [-50.0, 0.0, 100.0, 250.0, 500.0, 600.0]
let contentRange = 0.0...500.0

for position in scrollPositions {
    let rubberBanded = position.rubber(contentRange, .bouncy)
    // Values outside range get pulled back elastically
}
```

### Animation Constraints

```swift
// Constrain animation values with different spring feels
let gentleConstraint = userDragDistance.rubber(-100...100, .loose)
let snappyConstraint = userDragDistance.rubber(-100...100, .snappy)
```

### UI Element Positioning

```swift
// Keep UI elements within bounds with smooth overshoot
let constrainedX = touchX.rubber(0...screenWidth, .smooth)
let constrainedY = touchY.rubber(0...screenHeight, .firm)
```

### Interactive Gestures

```swift
// Different spring feels for different interaction types
let pullToRefresh = pullDistance.rubber(0...maxPull, .elastic)
let pageOverscroll = scrollOffset.rubber(pageRange, .bouncy)
let sliderOverdrag = sliderValue.rubber(valueRange, .snappy)
```

## How It Works

The rubber band function uses spring physics that:

1. **Passes through unchanged** if the value is within the specified range
2. **Applies exponential resistance** as values move further from the boundary
3. **Uses infinite damping** - no artificial limits, just natural spring physics
4. **Maintains smooth continuity** at the boundary points
5. **Provides intuitive control** through response and damping parameters

The resistance curves ensure that extremely large input values don't result in extremely large outputs, creating the characteristic "rubber band" feel while maintaining mathematical elegance.

## API Reference

### Core Function

```swift
rubberBand(value: Double, min: Double, max: Double, config: RubberBandConfig) -> Double
```

**Parameters:**
- `value`: The input value to potentially rubber band
- `min`: Lower bound of the valid range
- `max`: Upper bound of the valid range
- `config`: Spring configuration (response and damping)

**Returns:** The rubber banded value

### Configuration

```swift
RubberBandConfig(response: Double, dampingFraction: Double)
```

**Parameters:**
- `response`: Spring stiffness (0.1 - 2.0, default: 0.55)
- `dampingFraction`: Damping behavior (0.1 - 3.0, default: 1.0)

### Extension Methods

```swift
// Double
func rubber(_ range: ClosedRange<Double>, _ config: RubberBandConfig = .smooth) -> Double
func rubber(_ range: Range<Double>, _ config: RubberBandConfig = .smooth) -> Double

// Float
func rubber(_ range: ClosedRange<Float>, _ config: RubberBandConfig = .smooth) -> Float
func rubber(_ range: Range<Float>, _ config: RubberBandConfig = .smooth) -> Float

// CGFloat
func rubber(_ range: ClosedRange<CGFloat>, _ config: RubberBandConfig = .smooth) -> CGFloat
func rubber(_ range: Range<CGFloat>, _ config: RubberBandConfig = .smooth) -> CGFloat

// Int
func rubber(_ range: ClosedRange<Int>, _ config: RubberBandConfig = .smooth) -> Double
func rubber(_ range: Range<Int>, _ config: RubberBandConfig = .smooth) -> Double
```

## Testing

The library includes comprehensive tests using Swift Testing:

```bash
swift test
```

Run specific test suites:
```bash
swift test --filter "BasicTests"
swift test --filter "ExtensionTests"
swift test --filter "AdvancedTests"
```

## Requirements

- Swift 6.1+
- iOS 16+, macOS 13+, tvOS 16+, watchOS 9+

## License

MIT License - see LICENSE file for details.
