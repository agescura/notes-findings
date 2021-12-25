//
//  AlarmsListView.swift
//  Alarm
//
//  Created by Albert Gil Escura on 20/12/21.
//

import SwiftUI

struct AlarmsListView: View {
    @ObservedObject var viewModel: AlarmsListViewModel
    
    var body: some View {
        List {
            ForEach(self.viewModel.items) { item in
                AlarmItemRowView(viewModel: item)
            }
        }
        .navigationTitle("Alarms")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Add") { self.viewModel.addButtonTapped() }
            }
        }
        .sheet(
            value: Binding<AlarmItemViewModel?>(
                get: {
                    guard case let .add(viewModel) = self.viewModel.route else { return nil }
                    return viewModel
                },
                set: { isPresented in
                    if isPresented == nil {
                        self.viewModel.route = nil
                    }
                }
            )
        ) { $viewModel in
            NavigationView {
                AlarmItemView(viewModel: viewModel)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") { self.viewModel.cancelButtonTapped() }
                        }
                        
                        ToolbarItem(placement: .primaryAction) {
                            Button("Save") { self.viewModel.add(item: viewModel.alarmItem) }
                        }
                    }
            }
        }
    }
}

struct AlarmsListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AlarmsListView(
                viewModel: .init(
                    items: [
                        .init(item: .init(id: .init(), date: .init(), isOn: false)),
                        .init(item: .init(id: .init(), date: .init(), isOn: true)),
                        .init(item: .init(id: .init(), date: .init(), isOn: false)),
                    ]
                )
            )
        }
    }
}

extension View {
    func sheet<Value, Content>(
        value optionalValue: Binding<Value?>,
        @ViewBuilder content: @escaping (Binding<Value>) -> Content
    ) -> some View where Value: Identifiable, Content: View {
        self.sheet(
            item: optionalValue
        ) { _ in
            if let wrappedValue = optionalValue.wrappedValue,
               let value = Binding(
                get: { wrappedValue },
                set: { optionalValue.wrappedValue = $0 }
               ) {
                content(value)
            }
        }
    }
}
