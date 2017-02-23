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

    struct TestEvent2: ResponderChainEvent, Equatable {
        let a: Int

        static func == (lhs: TestEvent2, rhs: TestEvent2) -> Bool {
            return lhs.a == rhs.a
        }
    }

    let disposeBag = DisposeBag()

    func testResponderChainEvent() {
        let viewController = UIViewController()
        let view = viewController.view!
        let subview1 = UIView()
        let subview2 = UIView()
        view.addSubview(subview1)
        view.addSubview(subview2)
        

        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(100, TestEvent(a: 1)),
            next(200, TestEvent(a: 2)),
            next(300, TestEvent(a: 3)),
            next(400, TestEvent(a: 4)),
        ])

        let observerForView = scheduler.createObserver(TestEvent.self)
        let observerForVC = scheduler.createObserver(TestEvent.self)

        let observerForSubview = scheduler.createObserver(TestEvent.self)
        let observerForTestEvent2 = scheduler.createObserver(TestEvent2.self)

        scheduler.scheduleAt(0) {
            view.rx.responderChain.event(TestEvent.self)
                .subscribe(observerForView)
                .addDisposableTo(self.disposeBag)

            viewController.rx.responderChain.event(TestEvent.self)
                .subscribe(observerForVC)
                .addDisposableTo(self.disposeBag)

            subview2.rx.responderChain.event(TestEvent.self)
                .subscribe(observerForSubview)
                .addDisposableTo(self.disposeBag)

            view.rx.responderChain.event(TestEvent2.self)
                .subscribe(observerForTestEvent2)
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
        XCTAssertEqual(observerForSubview.events, [])
        XCTAssertEqual(observerForTestEvent2.events, [])

    }
#endif
}
