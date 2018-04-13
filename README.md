# RxResponderChain
  `RxResponderChain` is an extension of `RxSwift`, `RxCocoa`.
  It provides the way to notify Rx events via responder chain.

## Usage
First, you have to create struct / class / enum represents event you want  to notify using `ResponderChainEvent` protocol.

```swift
import RxResponder

struct LikeTweetEvent: ResponderChainEvent {
    let tweetID: Int64
}
```

Generate  event object and pass it to `bindTo` (or, `on`, `onNext` … ).

```swift
final class TweetCell: UITableViewCell {
    ...

    override func awakeFromNib() {
        super.awakeFromNib()

        likeButton.rx.tap
            .map { _ in LikeTweetEvent(tweetID: self.tweet.id) }
            .bind(to: self.rx.responderChain)
            .disposed(by: disposeBag)
    }
}
```

Then you can receive events in classes that are on  responder chain of the class sends events.
For example, if you send event in `UITableViewCell` then you can receive them in `tableView`, `viewController.view`, `viewController`,  `viewController.navigationController`,  and so on.

```swift
final class TweetListViewController: UIViewController {
    ...

    override func viewDidLoad() {
        super.viewDidLoad()

        self.rx.responderChain.event(LikeTweetEvent.self)
            .flatMapFirst { e in twitterService.like(tweetID: e.tweetID) }
            .subscribe()
            .disposed(by:disposeBag)
    }
}
```

## Requirements

`RxResponderChain` requires / supports the following environments:

+ Swift 4.1 / Xcode 9.3
+ iOS 9.0 or later
+ RxSwift / RxCocoa ~> 4.1

## Installation

### Carthage

```ruby
github “ukitaka/RxResponderChain” ~> 2.0
```


### CocoaPods

```ruby
use_frameworks!
pod "RxResponderChain", "~> 2.0"
```

