

public protocol StateManaged: AnyObject {
    associatedtype State
    associatedtype Action
    var state: State { get set }
    func process(state: inout State, action: Action)
}

public extension StateManaged {
    @MainActor func send(_ action: Action) {
        StateManagerQueue.send(actor: self, action: action)
    }

    @MainActor func runAfterProcess(_ effect: @escaping () async -> Void) {
        StateManagerQueue.run(effect: effect)
    }
}
