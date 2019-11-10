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
    
    public mutating func transition(state: S, event actionType: A) -> S {
        if !alive {
            return self.currentState
        }
        
        guard let transition = self.states[state] else { return state }
        
        guard let event = transition?[.on] else {
            self.alive = false
            return state
        }
        
        guard let target = event[actionType] else {
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
        }
    }
}
