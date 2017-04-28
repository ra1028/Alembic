prefix operator *

public prefix func *<T>(decoded: Decoded<T>) -> T {
    return decoded.value()
}

public prefix func *<T: DecodedProtocol>(decoded: T) throws -> T.Value {
    return try decoded.value()
}
