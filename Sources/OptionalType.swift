
public protocol OptionalType {
    typealias Wrapped
    
    var optionalValue: Optional<Wrapped> { get }
}

extension Optional: OptionalType {
    public var optionalValue: Optional<Wrapped> {
        return self
    }
}