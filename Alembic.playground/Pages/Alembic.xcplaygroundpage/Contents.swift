/*:
 ## Welcome to `Alembic` Playground!!
 ----
 > 1. Open Alembic.xcworkspace.
 > 2. Build the Alembic for Mac.
 > 3. Open Alembic playground in project navigator.
 > 4. Enjoy the Alembic!
*/
import Alembic
import Foundation

let object: [String: Any] = ["key": "value"]

let json = JSON(object)
do {
    let decoded: ThrowDecoded<Date> = json.decodeValue(for: "key", as: String.self).map { _ in Date() }
    
    let value1 = try decoded*
    
    print(value1)
    sleep(1)
    
    let value2 = try decoded*
    
    print(value2)
} catch let e {
    print(e)
}
