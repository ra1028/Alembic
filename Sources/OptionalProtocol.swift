public protocol OptionalProtocol {
    associatedtype Wrapped
    
    var optional: Wrapped? { get }
}

extension Optional: OptionalProtocol {
    public var optional: Wrapped? {
        return self
    }
}
