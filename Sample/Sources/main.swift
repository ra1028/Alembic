import Foundation
import Alembic

final class User: InitDistillable {
    let name: String
    let birthday: Date
    let job: String?

    init(json j: JSON) throws {
        name = try j.distil("name")
        birthday = try j.distil("birthday", to: String.self)
            .flatMap { date -> Date? in
                let fmt = DateFormatter()
                fmt.dateFormat = "M/d/yyyy"
                return fmt.date(from: date)
            }
        job = try j.option("job")
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
print("Name: \(user.name), Birthday: \(user.birthday), Job: \(user.job ?? "Unknown")")
