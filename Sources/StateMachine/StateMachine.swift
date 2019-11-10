public enum TransitionTypes {
    case on
    case type
}

public enum VariadicEvent<S:Hashable, A:Hashable> {
    case simple([A: S])
    case withContext([A: (target: S, action: (Any?) -> Any)])
}

public typealias Chart<S:Hashable, A:Hashable> = (
    initial: S,
    context: Any?,
    states: [S: Transition<S, A>?]
)
//public typealias Context = [String: String]
public typealias Transition<S:Hashable, A:Hashable> = [
    TransitionTypes: VariadicEvent<S, A>
]
