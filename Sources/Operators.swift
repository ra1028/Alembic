prefix operator *

public prefix func *<T>(decoded: Decoded<T>) -> T {
    return decoded.value()
}

public prefix func *<T>(decoded: ThrowableDecoded<T>) throws -> T {
    return try decoded.value()
}
