import XCTest

#if os(iOS)
import UIKit
import RxSwift
import RxCocoa
import RxTest
#endif

@testable import RxResponderChain

class RxResponderChainTests: XCTestCase {
    static var allTests : [(String, (RxResponderChainTests) -> () throws -> Void)] {
        return [
        ]
    }

#if os(iOS)
    struct TestEvent: ResponderChainEvent, Equatable {
        let a: Int

        static func == (lhs: TestEvent, rhs: TestEvent) -> Bool {
            return lhs.a == rhs.a
        }
    }

    let disposeBag = DisposeBag()

    func testResponderChainEvent() {
        let viewController = UIViewController()
        let view = viewController.view!
        let subview = UIView()
        view.addSubview(subview)
        

        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(100, TestEvent(a: 1)),
            next(200, TestEvent(a: 2)),
            next(300, TestEvent(a: 3)),
            next(400, TestEvent(a: 4)),
        ])

        let observerForView = scheduler.createObserver(TestEvent.self)
        let observerForVC = scheduler.createObserver(TestEvent.self)

        scheduler.scheduleAt(0) {
            view.rx.responderChain.event(TestEvent.self)
                .subscribe(observerForView)
                .addDisposableTo(self.disposeBag)

            viewController.rx.responderChain.event(TestEvent.self)
                .subscribe(observerForVC)
                .addDisposableTo(self.disposeBag)

            xs.bindTo(viewController.view.rx.responderChain)
                .addDisposableTo(self.disposeBag)
        }

        scheduler.start()

        let expectedEvent = [
            next(100, TestEvent(a: 1)),
            next(200, TestEvent(a: 2)),
            next(300, TestEvent(a: 3)),
            next(400, TestEvent(a: 4)),
        ]

        XCTAssertEqual(observerForView.events, expectedEvent)
        XCTAssertEqual(observerForVC.events, expectedEvent)
    }
#endif
}
