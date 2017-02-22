import PackageDescription

let package = Package(
    name: "RxResponderChain",
    dependencies: [
        .Package(url: "git@github.com:ReactiveX/RxSwift.git", majorVersion: 3)
    ]
)
