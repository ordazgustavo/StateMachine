public typealias Chart<S:Hashable, A:Hashable> = (
    initial: S,
    context: Any?,
    states: [S: Transition<S, A>?],
    actions: [String: (Any?) -> Any]?
)

public typealias Transition<S:Hashable, A:Hashable> = [TransitionTypes<S, A>]

public enum TransitionTypes<S:Hashable, A:Hashable> {
    case on(Event<S, A>)
    case type(String)
}

public typealias Event<S, A:Hashable> = [A: VariadicState<S>]

public enum VariadicState<S> {
    case simple(S)
    case withContext((target: S, action: (Any?) -> Any))
    case withActions((target: S, actions: [String]))
}
