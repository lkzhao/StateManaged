//
//  StateManagerQueue.swift
//
//
//  Created by Luke Zhao on 7/19/24.
//

import Foundation

protocol AnyMessage {
    func run()
}

struct SendMessage<T: StateManaged>: AnyMessage {
    let actor: T
    let action: T.Action

    @MainActor
    func run() {
        actor.process(state: &actor.state, action: action)
    }
}

struct RunMessage: AnyMessage {
    let effect: () async -> Void

    @MainActor
    func run() {
        Task {
            await effect()
        }
    }
}

class StateManagerQueue {
    static var queue = [AnyMessage]()
    static var isProcessing = false

    static func send<T: StateManaged>(actor: T, action: T.Action) {
        let message = SendMessage(actor: actor, action: action)
        queue.append(message)
        processQueue()
    }

    static func run(effect: @escaping () async -> Void) {
        let message = RunMessage(effect: effect)
        queue.append(message)
        processQueue()
    }

    static func processQueue() {
        guard !isProcessing else {
            return
        }
        isProcessing = true
        while !queue.isEmpty {
            queue.removeFirst().run()
        }
        isProcessing = false
    }
}
