//
//  File.swift
//  
//
//  Created by Gustavo Ordaz on 11/9/19.
//

public struct Machine<S:Hashable, A:Hashable> {
    public var initial: S
    public var context: Context
    public var states: [S: Transition<S, A>?]
    public var actions: [String: (Context) -> Any]?
    public var guards: [String: (Context) -> Bool]?
    
    public var currentState: S
    
    private var alive = true
    
    public init(
        initial: S,
        context: Context,
        states: [S: Transition<S, A>?],
        actions: [String: (Context) -> Any]? = nil,
        guards: [String: (Context) -> Bool]? = nil
    ) {
        self.initial = initial
        self.currentState = initial
        self.context = context
        self.states = states
        self.actions = actions
        self.guards = guards
    }
    
    public init(forChart chart: Chart<S, A>) {
        self.initial = chart.initial
        self.currentState = chart.initial
        self.context = chart.context
        self.states = chart.states
        self.actions = chart.actions
        self.guards = chart.guards
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
            return self.currentState
            
        case .withContext(let (tgt, action)):
            handleWithContextEvent(action: action)
            
            self.currentState = tgt
            return self.currentState
            
        case .withActions(let (tgt, actions)):
            handleWithActionsEvent(actions: actions)
            
            self.currentState = tgt
            return self.currentState
            
        case .withGuards(let (tgt, cond)):
            let shouldUpdate = handleWithGuardsEvent(
                context: self.context,
                cond: cond
            )
            
            if shouldUpdate {
                self.currentState = tgt
            }
            return self.currentState
            
        case .withActionsAndGuards(let (tgt, actions, cond)):
            let shouldUpdate = handleWithActionsAndGuardsEvent(
                actions: actions,
                cond: cond
            )
            
            if shouldUpdate {
                self.currentState = tgt
            }
            return self.currentState
        }
    }
    
    private mutating func handleWithContextEvent(action: (Any?) -> Any) {
        self.context = action(self.context)
    }
    
    private mutating func handleWithActionsEvent(actions: [String]) {
        guard let ourActions = self.actions else { return }
        
        for action in actions {
            guard let act = ourActions[action] else { continue }
            self.context = act(self.context)
        }
    }
    
    private mutating func handleWithGuardsEvent(
        context: Context,
        cond: String
    ) -> Bool {
        /// Allow to update the given state if the user:
        /// 1. Needs guards but did not provide a guards array
        guard let ourGuards = self.guards else { return true }
        /// 2. Provided guards but we can't find the selected guard
        guard let g = ourGuards[cond] else { return true }
        
        return g(context)
    }
    
    private mutating func handleWithActionsAndGuardsEvent(
        actions: [String],
        cond: String
    ) -> Bool {
        guard let ourActions = self.actions else { return true }
        
        /// Firs we validate that we can make all the actions
        /// We don't want to make partial updates to the context
        var valid = true
        for action in actions {
            guard let act = ourActions[action] else { continue }
            let result = act(self.context)
            let guarded = handleWithGuardsEvent(context: result, cond: cond)
            if !guarded {
                valid = false
                break
            }
        }
        
        /// Stop execution if we have a non guarded update
        guard valid else { return false }
        
        handleWithActionsEvent(actions: actions)
        
        return true
    }
}
