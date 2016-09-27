import Foundation
import Alembic

final class User: InitDistillable {
    let name: String
    let birthday: Date
    let job: String?

    init(j: JSON) throws {
        try name = j.distil("name")
        try birthday = j.distil("birthday")
            .flatMap {
                let fmt = DateFormatter()
                fmt.dateFormat = "M/d/yyyy"
                return fmt.date(from: $0)
            }
        try job = j.option("job")
    }
}

let object = [
    "user": [
        "name": "Robert",
        "birthday": "4/4/1965",
        "job": NSNull()
    ]
]

let j = JSON(object)

let name: String = try! j <| ["user", "name"]
print(name)
let job: String? = try! j <|? ["user", "job"]
print(job)
let user: User = try! j <| "user"
print(user)
