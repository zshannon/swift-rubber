// MARK: - Floating Point Types

extension Double: RubberBandable {}
extension Float: RubberBandable {}

// MARK: - Signed Integer Types

extension Int: RubberBandable {}
extension Int8: RubberBandable {}
extension Int16: RubberBandable {}
extension Int32: RubberBandable {}
extension Int64: RubberBandable {}

// MARK: - Unsigned Integer Types

extension UInt: RubberBandable {}
extension UInt8: RubberBandable {}
extension UInt16: RubberBandable {}
extension UInt32: RubberBandable {}
extension UInt64: RubberBandable {}

// MARK: - Core Graphics Types

#if canImport(CoreGraphics)
    import CoreGraphics

    extension CGFloat: RubberBandable {}
#endif
