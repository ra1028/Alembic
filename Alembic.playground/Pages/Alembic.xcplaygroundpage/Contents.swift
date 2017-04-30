/*:
 ## Welcome to `Alembic` Playground!!
 ----
 > 1. Open Alembic.xcworkspace.
 > 2. Build the Alembic for Mac.
 > 3. Open Alembic playground in project navigator.
 > 4. Enjoy the Alembic!
*/
import Alembic

let object: [String: Any] = ["key": "value"]

let json = JSON(object)
do {
    let value: Int = try json.decodeValue(for: "key", as: String.self).map { _ in 100 }
    print(value)
} catch let e {
    print(e)
}
