public final class LazyJSON {
    fileprivate let rootJSON: JSON
    fileprivate let currentPath: Path
    
    public subscript(element: Path.Element...) -> LazyJSON {
        return .init(rootJSON: rootJSON, currentPath: currentPath + .init(elements: element))
    }
    
    init(rootJSON: JSON, currentPath: Path) {
        self.rootJSON = rootJSON
        self.currentPath = currentPath
    }
}

// MARK: - JSONProtocol

extension LazyJSON: JSONProtocol {
    public func distil<T: Decodable>(_ path: Path, as: T.Type) -> ThrowableDecoded<T> {
        return rootJSON.distil(currentPath + path)
    }
    
    public func option<T: Decodable>(_ path: Path, as: T?.Type) -> ThrowableDecoded<T?> {
        return rootJSON.option(currentPath + path)
    }
}

// MARK: - CustomStringConvertible

extension LazyJSON: CustomStringConvertible {
    public var description: String {
        return "LazyJSON(rootJSON: \(rootJSON), currentPath: \(currentPath))"
    }
}

// MARK: - CustomDebugStringConvertible

extension LazyJSON: CustomDebugStringConvertible {
    public var debugDescription: String {
        return description
    }
}
