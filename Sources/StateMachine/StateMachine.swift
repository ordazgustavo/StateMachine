public typealias Chart<S:Hashable, A:Hashable> = (
    initial: S,
    context: Any?,
    states: [S: Transition<S, A>?]
)

public typealias Transition<S:Hashable, A:Hashable> = [
    TransitionTypes: Event<S, A>
]

public enum TransitionTypes {
    case on
    case type
}

public typealias Event<S, A:Hashable> = [A: VariadicState<S>]

public enum VariadicState<S> {
    case simple(S)
    case withContext((target: S, action: (Any?) -> Any))
}
