
public enum Effect {
    case none
    case run(() -> Void)
}

public protocol StateManaged: AnyObject {
    associatedtype State
    associatedtype Action
    var state: State { get set }
    func reduce(state: inout State, action: Action) -> Effect
}

public extension StateManaged {
    @MainActor func send(_ action: Action) {
        StateManagerQueue.send(actor: self, action: action)
    }
}
