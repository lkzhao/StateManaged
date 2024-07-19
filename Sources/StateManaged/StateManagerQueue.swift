//
//  StateManagerQueue.swift
//
//
//  Created by Luke Zhao on 7/19/24.
//

import Foundation

protocol AnyMessage {
    func send()
}

struct Message<T: StateManaged>: AnyMessage {
    let actor: T
    let action: T.Action

    @MainActor
    func send() {
        switch actor.reduce(state: &actor.state, action: action) {
        case .none:
            break
        case .run(let block):
            block()
        }
    }
}

class StateManagerQueue {
    static var queue = [AnyMessage]()
    static var isProcessing = false

    static func send<T: StateManaged>(actor: T, action: T.Action) {
        let message = Message(actor: actor, action: action)
        queue.append(message)
        processQueue()
    }

    static func processQueue() {
        guard !isProcessing else {
            return
        }
        isProcessing = true
        while !queue.isEmpty {
            queue.removeFirst().send()
        }
        isProcessing = false
    }
}
