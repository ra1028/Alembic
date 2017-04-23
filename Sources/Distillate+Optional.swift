public extension Distillate where Value: OptionalProtocol {
    func filterNil() throws -> Value.Wrapped {
        return try filter { $0.optional != nil }.optional!
    }
    
    func filterNil() -> InsecureDistillate<Value.Wrapped> {
        return .init(filterNil)
    }
}
