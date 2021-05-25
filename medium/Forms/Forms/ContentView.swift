//
//  ContentView.swift
//  Forms
//
//  Created by Albert Gil Escura on 25/5/21.
//

import SwiftUI
import ComposableArchitecture
import CounterView

struct AppState: Equatable {
    var toggleEnabled: Bool = false
    var textField: String = ""
    var textFieldMatchHelloWorld: Bool = false
    
    var counterView = CounterState()
}

private extension AppState {
    var cheeseEnabled: Bool {
        counterView.cheeseEnabled
    }
}

enum AppAction: Equatable {
    case toggle(isOn: Bool)
    case textField(change: String)
    case resetForm
    
    case counter(CounterAction)
}

let appReducer = Reducer<AppState, AppAction, Void>.combine(
    reducerCounter.pullback(
        state: \.counterView,
        action: /AppAction.counter,
        environment: { _ in () }),
    
    
    Reducer<AppState, AppAction, Void> { state, action, _ in
        switch action {
        case let .toggle(isOn: isOn):
            state.toggleEnabled = isOn
            return .none
            
        case let .textField(change: newValue):
            state.textField = newValue
            state.textFieldMatchHelloWorld = newValue == "HELLO, WORLD!"
            return .none
            
        case .resetForm:
            state = .init()
            return .none
            
        case .counter:
            return .none
        }
    }
)

struct ContentView: View {
    let store: Store<AppState, AppAction>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            NavigationView {
                Form {
                    Section(header: Text("Enable if you want to continue")) {
                        Toggle(isOn: viewStore.binding(
                                get: \.toggleEnabled,
                                send: AppAction.toggle)
                        ) {
                            Text("Toggle")
                                .foregroundColor(viewStore.toggleEnabled ? .black : .gray)
                        }
                    }
                    
                    Section(header: Text("Write ").bold() + Text("HELLO, WORLD!").italic()) {
                        HStack {
                            TextField(
                                "Write HELLO, WORLD!",
                                text: viewStore.binding(
                                    get: \.textField,
                                    send: AppAction.textField
                                )
                            )
                        }
                    }
                    .disabled(!viewStore.toggleEnabled)
                    
                    Section(header: Text("Pick 10 items")) {
                        CounterView(
                            store: self.store.scope(
                                state: \.counterView,
                                action: AppAction.counter
                            )
                        )
                    }
                    .foregroundColor(viewStore.textFieldMatchHelloWorld ? .black : .gray)
                    .disabled(!viewStore.textFieldMatchHelloWorld)
                    
                    Section(header: Text("Ups, you can't reset this form")) {
                        Button(action: { viewStore.send(.resetForm) }, label: {
                            Text("Reset form")
                        })
                        .buttonStyle(PlainButtonStyle())
                    }
                    .foregroundColor(viewStore.cheeseEnabled ? .blue : .gray)
                    .disabled(!viewStore.cheeseEnabled)
                }
                .navigationBarTitle("Form")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(
            store: Store(
                initialState: AppState(),
                reducer: appReducer,
                environment: ()
            )
        )
    }
}
