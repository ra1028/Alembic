postfix operator *

public postfix func *<T>(decoded: Decoded<T>) -> T {
    return decoded.value()
}

public postfix func *<T: DecodedProtocol>(decoded: T) throws -> T.Value {
    return try decoded.value()
}
