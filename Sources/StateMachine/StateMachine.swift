public typealias Chart<S:Hashable, A:Hashable> = (
    initial: S,
    context: Context,
    states: [S: Transition<S, A>?],
    actions: [String: (Context) -> Any]?,
    guards: [String: (Context) -> Bool]?
)

public typealias Transition<S:Hashable, A:Hashable> = [TransitionTypes<S, A>]

public enum TransitionTypes<S:Hashable, A:Hashable> {
    case on(Event<S, A>)
    case type(String)
}

public typealias Event<S, A:Hashable> = [A: VariadicState<S>]

public enum VariadicState<S> {
    case simple(S)
    case withContext((target: S, action: (Context) -> Any))
    case withActions((target: S, actions: [String]))
    case withGuards((target: S, cond: String))
    case withActionsAndGuards((target: S, actions: [String], cond: String))
}

public typealias Context = Any?
