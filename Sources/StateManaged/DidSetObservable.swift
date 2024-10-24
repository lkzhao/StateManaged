//
//  DidSetObservable.swift
//  StateManaged
//
//  Created by Luke Zhao on 10/23/24.
//

import Combine

@propertyWrapper
public class DidSetObservable<Value> {
    private class ObserverToken {
        let block: (Value) -> Void
        init(block: @escaping (Value) -> Void) {
            self.block = block
        }
    }

    private var observers: [ObserverToken] = []

    public var wrappedValue: Value {
        didSet {
            for observer in observers {
                observer.block(wrappedValue)
            }
        }
    }

    public var projectedValue: DidSetObservable<Value> { self }

    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }

    public func observe(_ closure: @escaping (Value) -> Void) -> AnyCancellable {
        let token = ObserverToken(block: closure)
        observers.append(token)
        return AnyCancellable { [weak self] in
            self?.observers.removeAll { $0 === token }
        }
    }
}
