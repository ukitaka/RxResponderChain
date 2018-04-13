//
//  UIResponder+Rx.swift
//  RxResponderChain
//
//  Created by Yuki Takahashi on 2017/02/22.
//  Copyright © 2017年 waft. All rights reserved.
//

#if os(iOS)

import RxSwift
import RxCocoa

// MARK: - ResponderChainEvent

public protocol ResponderChainEvent {
}

// MARK: - ResponderChain

public struct ResponderChain<Base: UIResponder>: ObserverType {
    fileprivate let reactive: Reactive<Base>

    fileprivate init(_ reactive: Reactive<Base>) {
        self.reactive = reactive
    }

    public func on(_ event: RxSwift.Event<ResponderChainEvent>) {
        var currentResponder: UIResponder? = reactive.base
        while let responder = currentResponder {
            responder.rx.responderChainEventObserver.on(event)
            currentResponder = responder.next
        }
    }

    public func event<E: ResponderChainEvent>(_ type: E.Type) -> Observable<E> {
        return reactive.responderChainEventObserver
            .filter {
                $0 is E
            }
            .map {
                castOrFatalError($0) as E
            }
    }
}

// MARK: - Reactive

private var responderChainEventObserverContext: UInt8 = 0

public extension Reactive where Base: UIResponder {
    public var responderChain: ResponderChain<Base> {
        return ResponderChain(self)
    }

    fileprivate var responderChainEventObserver: PublishSubject<ResponderChainEvent> {
        if let observer = objc_getAssociatedObject(base, &responderChainEventObserverContext)
            as? PublishSubject<ResponderChainEvent> {
            return observer
        }

        let observer = PublishSubject<ResponderChainEvent>()

        objc_setAssociatedObject(base, &responderChainEventObserverContext, observer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return observer
    }
}

// MARK: - Bind

public extension ObservableType where E: ResponderChainEvent {

    @available(*, deprecated, renamed: "bind(to:)")
    public func bindTo<O>(_ observer: O) -> Disposable where O: ObserverType, O.E == Self.E {
        return bind(to: observer)
    }

    public func bind<O: ObserverType>(to observer: O) -> Disposable where O.E == ResponderChainEvent {
        return self.map { $0 as ResponderChainEvent }
            .bind(to: observer)
    }
}

// MARK: - Utils

private func castOrFatalError<T>(_ value: Any!) -> T {
    let maybeResult: T? = value as? T
    guard let result = maybeResult else {
        fatalError("Failure converting from \(value) to \(T.self)")
    }
    return result
}

#endif
