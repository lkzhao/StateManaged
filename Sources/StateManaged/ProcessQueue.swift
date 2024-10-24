//
//  ProcessQueue.swift
//
//
//  Created by Luke Zhao on 7/19/24.
//

import Foundation

class ProcessQueue {
    static var queues = [ObjectIdentifier: ProcessQueue]()
    
    static func process(id: ObjectIdentifier, effect: @escaping () -> Void) {
        if queues[id] == nil {
            queues[id] = ProcessQueue()
        }
        queues[id]!.process(effect)
        if queues[id]?.isProcessing == false {
            queues[id] = nil
        }
    }

    private var isProcessing = false
    private var queue = [() -> Void]()

    private func process(_ effect: @escaping () -> Void) {
        queue.append(effect)
        guard !isProcessing else {
            return
        }
        isProcessing = true
        while !queue.isEmpty {
            queue.removeFirst()()
        }
        isProcessing = false
    }
}
