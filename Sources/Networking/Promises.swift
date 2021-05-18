//
//  Promises.swift
//  DiscourseKit
//
//  Created by Tanner Bennett on 5/18/21.
//

import Combine

extension Future {
    public static func promise(
        _ block: @escaping (@escaping Future<Output, Failure>.Promise) -> Void
    ) -> AnyPublisher<Output, Failure> {
        return Future(block).eraseToAnyPublisher()
    }
}

extension AnyPublisher {
    public static func just<T,E>(_ value: T) -> AnyPublisher<T,E> {
        return Just(value)
            .mapError { $0 as! E }
            .eraseToAnyPublisher()
    }
}

extension Publisher {
    public func passthrough(_ closure: @escaping (Output) -> Void) -> Self {
        // _ = self.sink { _ in } receiveValue: { closure($0) }
        self.subscribe(PassthroughSubscriber(closure))
        return self
    }
}

private class PassthroughSubscriber<I,E: Error>: Subscriber {
    typealias Input = I
    typealias Failure = E

    let block: (I) -> Void

    init(_ block: @escaping (I) -> Void) {
        self.block = block
    }

    func receive(subscription: Subscription) {
        subscription.request(.unlimited)
    }

    func receive(_ input: Input) -> Subscribers.Demand {
        self.block(input)
        return .unlimited
    }

    func receive(completion: Subscribers.Completion<Failure>) { }
}
