import PackageDescription

let package = Package(
    name: "Alembic-Sample",
    dependencies: [
        .Package(url: "https://github.com/ra1028/Alembic.git", majorVersion: 2),
    ]
)
