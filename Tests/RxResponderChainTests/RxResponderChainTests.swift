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
            Recorded.next(100, TestEvent(a: 1)),
            Recorded.next(200, TestEvent(a: 2)),
            Recorded.next(300, TestEvent(a: 3)),
            Recorded.next(400, TestEvent(a: 4)),
        ])

        let observerForView = scheduler.createObserver(TestEvent.self)
        let observerForVC = scheduler.createObserver(TestEvent.self)

        let observerForSubview = scheduler.createObserver(TestEvent.self)
        let observerForTestEvent2 = scheduler.createObserver(TestEvent2.self)

        scheduler.scheduleAt(0) {
            view.rx.responderChain.event(TestEvent.self)
                .subscribe(observerForView)
                .disposed(by: self.disposeBag)

            viewController.rx.responderChain.event(TestEvent.self)
                .subscribe(observerForVC)
                .disposed(by:self.disposeBag)

            subview2.rx.responderChain.event(TestEvent.self)
                .subscribe(observerForSubview)
                .disposed(by:self.disposeBag)

            view.rx.responderChain.event(TestEvent2.self)
                .subscribe(observerForTestEvent2)
                .disposed(by:self.disposeBag)

            xs.bind(to:viewController.view.rx.responderChain)
                .disposed(by:self.disposeBag)
        }

        scheduler.start()

        let expectedEvent = [
            Recorded.next(100, TestEvent(a: 1)),
            Recorded.next(200, TestEvent(a: 2)),
            Recorded.next(300, TestEvent(a: 3)),
            Recorded.next(400, TestEvent(a: 4)),
        ]

        XCTAssertEqual(observerForView.events, expectedEvent)
        XCTAssertEqual(observerForVC.events, expectedEvent)
        XCTAssertEqual(observerForSubview.events, [])
        XCTAssertEqual(observerForTestEvent2.events, [])

    }
#endif
}
