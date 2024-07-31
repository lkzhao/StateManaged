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

    func run() {
        actor.process(state: &actor.state, action: action)
    }
}

struct RunMessage: AnyMessage {
    let effect: () -> Void

    func run() {
        effect()
    }
}

class StateManagerQueue {
    static var queues = [ObjectIdentifier: StateManagerQueue]()
    var isProcessing = false
    var queue = [AnyMessage]()

    static func send<T: StateManaged>(actor: T, action: T.Action) {
        process(actor: actor,
                message: SendMessage(actor: actor, action: action))
    }

    static func run<T: StateManaged>(actor: T, effect: @escaping () -> Void) {
        process(actor: actor,
                message: RunMessage(effect: effect))
    }
    
    static func process<T: StateManaged>(actor: T, message: AnyMessage) {
        let id = ObjectIdentifier(actor)
        if queues[id] == nil {
            queues[id] = StateManagerQueue()
        }
        queues[id]!.process(id: id, message: message)
        if queues[id]?.isProcessing == false {
            queues[id] = nil
        }
    }

    func process(id: ObjectIdentifier, message: AnyMessage) {
        queue.append(message)
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
