//
//  File.swift
//  
//
//  Created by Gustavo Ordaz on 11/9/19.
//

public struct Machine<S:Hashable, A:Hashable> {
    public var initial: S
    public var context: Any?
    public var states: [S: Transition<S, A>?]
    public var actions: [String: (Any?) -> Any]?
    
    public var currentState: S
    
    private var alive = true
    
    public init(
        initial: S,
        context: Any?,
        states: [S: Transition<S, A>?],
        actions: [String: (Any?) -> Any]? = nil
    ) {
        self.initial = initial
        self.currentState = initial
        self.context = context
        self.states = states
        self.actions = actions
    }
    
    public init(forChart chart: Chart<S, A>) {
        self.initial = chart.initial
        self.currentState = chart.initial
        self.context = chart.context
        self.states = chart.states
        self.actions = chart.actions
    }
    
    public mutating func transition(state: S, event actionType: A) -> S {
        if !alive {
            return self.currentState
        }
        
        guard let transitions = self.states[state]! else {
            self.alive = false
            return state
        }
        
        for case let .type(type) in transitions {
            if type == "final" {
                self.alive = false
                break
            }
        }
        
        var event: Event<S, A>?
        for case let .on(e) in transitions {
            event = e
        }
        
        guard let target = event![actionType] else {
            return state
        }
        
        switch target {
        case .simple(let simple):
            self.currentState = simple
            return simple
            
        case .withContext(let withContext):
            let (tgt, action) = withContext
            self.context = action(self.context)
            self.currentState = tgt
            return tgt
            
        case .withActions(let withActions):
            let (tgt, acts) = withActions
            if let ourActions = self.actions {
                for action in acts {
                    if let act = ourActions[action] {
                        self.context = act(self.context)
                    }
                }
            }
            self.currentState = tgt
            return tgt
        }
    }
}
