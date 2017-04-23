prefix operator *

public prefix func *<T>(distillate: SecureDistillate<T>) -> T {
    return distillate.value()
}

public prefix func *<T>(distillate: InsecureDistillate<T>) throws -> T {
    return try distillate.value()
}
