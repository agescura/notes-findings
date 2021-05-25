//
//  Counter.swift
//  CounterView
//
//  Created by Albert Gil Escura on 25/5/21.
//

import Foundation
import ComposableArchitecture

public struct CounterState: Equatable {
    public var counter: Int
    public var cheeseEnabled: Bool
    
    public init(
        counter: Int = 0,
        cheeseEnabled: Bool = false
    ) {
        self.counter = counter
        self.cheeseEnabled = cheeseEnabled
    }
}

public enum CounterAction: Equatable {
    case incrementTapped
    case decrementTapped
    case checkPickHasTenItems
}

public let reducerCounter = Reducer<CounterState, CounterAction, Void> { state, action, _ in
    switch action {
    
    case .decrementTapped:
        state.counter -= 1
        return Effect(value: .checkPickHasTenItems)
        
    case .incrementTapped:
        state.counter += 1
        return Effect(value: .checkPickHasTenItems)
        
    case .checkPickHasTenItems:
        state.cheeseEnabled = state.counter > 9
        return .none
    }
}
