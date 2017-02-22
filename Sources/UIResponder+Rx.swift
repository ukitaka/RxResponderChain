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

extension Reactive where Base: UIResponder {

    func responderChainEvent<E: RxResponderChainEvent>(event: E) -> Observable<E> {
        Mirror
    }

}

#endif

/*
 
 self.rx.responderChain.on(myCustomEvent)
 
 
 self.rx.responderChain.event(MyCustomEvent) // Observable<MyCustomEvent>
    .subscribe()
    ...
 
 */
