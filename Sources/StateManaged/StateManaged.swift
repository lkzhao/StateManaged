
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
    func send(_ action: Action) {
        switch reduce(state: &state, action: action) {
        case .none:
            break
        case .run(let block):
            block()
        }
    }
}
