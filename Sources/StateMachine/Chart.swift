//
//  Chart.swift
//  
//
//  Created by Gustavo Ordaz on 11/10/19.
//

// MARK: Declarations

public struct Chart<S:Hashable, A:Hashable> {
    public var id: String?
    public var initial: S
    public var context: Context?
    public var states: [S: Transition?]
    public var actions: [String: (Context) -> Context]?
    public var guards: [String: (Context) -> Bool]?
    
    public init(
        id: String?,
        initial: S,
        context: Context?,
        states: [S: Transition?],
        actions: [String: (Context) -> Context]? = nil,
        guards: [String: (Context) -> Bool]? = nil
    ) {
        self.id = id
        self.initial = initial
        self.context = context
        self.states = states
        self.actions = actions
        self.guards = guards
    }
}

// MARK: - Interfaces

extension Chart {
    public typealias Context = [String: Any]
    public typealias Transition = [TransitionTypes]
    public typealias Event = [A: VariadicState]

    public enum TransitionTypes {
        case on(Event)
        case type(String)
    }

    public enum VariadicState {
        case simple(S)
        case withContext(target: S, action: (Context) -> Context)
        case withActions(target: S, actions: [String])
        case withGuards(target: S, cond: String)
        case withActionsAndGuards(target: S, actions: [String], cond: String)
    }
}
