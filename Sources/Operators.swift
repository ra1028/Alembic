prefix operator *

public prefix func *<T>(distillate: Decoded<T>) -> T {
    return distillate.value()
}

public prefix func *<T>(distillate: InDecoded<T>) throws -> T {
    return try distillate.value()
}
