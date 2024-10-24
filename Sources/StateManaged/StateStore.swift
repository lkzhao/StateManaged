//
//  StateStore.swift
//  StateManaged
//
//  Created by Luke Zhao on 10/23/24.
//

import Foundation

private var allStateStore = NSMapTable<AnyObject, AnyObject>(keyOptions: .weakMemory, valueOptions: .strongMemory)

class StateStore<State> {
    @DidSetObservable var state: State?
    private init(state: State?) {
        self.state = state
    }

    static func store(for object: AnyObject) -> StateStore<State> {
        if let store = allStateStore.object(forKey: object) as? StateStore<State> {
            return store
        } else {
            let store = StateStore<State>(state: nil)
            allStateStore.setObject(store, forKey: object)
            return store
        }
    }
}

extension StateManaged {
    var stateStore: StateStore<State> {
        StateStore.store(for: self)
    }
}
