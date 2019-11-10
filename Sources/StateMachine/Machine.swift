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
    
    public var currentState: S
    
    private var alive = true
    
    public init(initial: S, context: Any?, states: [S: Transition<S, A>?]) {
        self.initial = initial
        self.context = context
        self.states = states
        self.currentState = initial
    }
    
    public init(forChart chart: Chart<S, A>) {
        self.initial = chart.initial
        self.context = chart.context
        self.states = chart.states
        self.currentState = chart.initial
    }
    
    public mutating func transition(state: S, event: A) -> S {
        if !alive {
            return self.currentState
        }
        
        guard let transition = self.states[state] else { return state }
        
        guard let action = transition?[.on] else {
            self.alive = false
            return state
        }
        
        switch action {
        case .simple(let simple):
            guard let target = simple[event] else { return state }
            self.currentState = target
            return target
            
        case .withContext(let withContext):
            guard let (target, ctx) = withContext[event] else { return state }
            self.context = ctx(self.context)
            self.currentState = target
            return target
        }
    }
}
