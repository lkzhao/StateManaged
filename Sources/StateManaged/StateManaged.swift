//
//  StateManaged.swift
//  StateManaged
//
//  Created by Luke Zhao on 10/23/24.
//

import Foundation
import Combine

/// A protocol for objects that manage a state and process actions to change the state
///
/// The protocol provides an accessable `state` variable that is updated by processing actions.
/// Call `send(_:)` to send actions to change the state, which will call the `process(state:action:)` method to handle the actions.
/// The state can be observed for changes through the `observeState(_:)` method.
///
/// - Note: The object must implement the `process(state:action:)` method to handle the actions.
/// - Note: The object must call `setInitialState` to set the initial state before accessing the state.
/// - Note: The object can call `send(_:)` or `runAfterProcess(_:)` during the processing of an action to send more actions or run effects after the current action processing finishes.
public protocol StateManaged<State, Action>: AnyObject {
    associatedtype State
    associatedtype Action
    func process(state: inout State, action: Action)
}

public extension StateManaged {
    /// The current state of the `StateManaged` object.
    /// - Note: This will crash if the state is not set. Make sure to call `setInitialState` before accessing the state.
    /// - Note: This is a read-only property. To change the state, use `send(_:)`.
    private(set) var state: State {
        get {
            guard let state = stateStore.state else {
                fatalError("State not found for \(self). Must call `setInitialState`")
            }
            return state
        }
        set {
            stateStore.state = newValue
        }
    }

    /// Set the initial state for the `StateManaged` object.
    /// - Parameter initialState: The initial state to set.
    /// - Note: This will crash if the state is already set. Make sure to call this only once.
    func setInitialState(_ initialState: State) {
        guard stateStore.state == nil else {
            fatalError("State already set for \(self)")
        }
        state = initialState
    }

    /// Force set the state for the `StateManaged` object.
    /// - Parameter state: The state to set.
    /// - Note: Using this method is discouraged. Use `send(_:)` to send actions to change the state.
    func forceSetState(_ state: State) {
        self.state = state
    }

    /// Observe the state of the `StateManaged` object.
    /// - Parameter closure: The closure to call when the state changes.
    /// - Returns: An `AnyCancellable` object that can be used to cancel the observation.
    ///
    /// Caller must keep a strong reference to the `AnyCancellable` object to keep the observation
    /// - Note: The closure will not be called immediately with the current state.
    func observeState(_ closure: @escaping (State) -> Void) -> AnyCancellable {
        stateStore.$state.observe {
            guard let state = $0 else { return }
            closure(state)
        }
    }

    /// Send an action to the `StateManaged` object to change the state.
    /// - Parameter action: The action to send.
    func send(_ action: Action) {
        ProcessQueue.process(id: ObjectIdentifier(self)) {
            self.process(state: &self.state, action: action)
        }
    }

    /// Runs the effect after the current action processing finishes.
    /// - Parameter effect: The effect to run
    func runAfterProcess(_ effect: @escaping () -> Void) {
        ProcessQueue.process(id: ObjectIdentifier(self), effect: effect)
    }
}

