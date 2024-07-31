

public protocol StateManaged: AnyObject {
    associatedtype State
    associatedtype Action
    var state: State { get set }
    func process(state: inout State, action: Action)
}

public extension StateManaged {
    func send(_ action: Action) {
        StateManagerQueue.send(actor: self, action: action)
    }

    func runAfterProcess(_ effect: @escaping () -> Void) {
        StateManagerQueue.run(actor: self, effect: effect)
    }
}
