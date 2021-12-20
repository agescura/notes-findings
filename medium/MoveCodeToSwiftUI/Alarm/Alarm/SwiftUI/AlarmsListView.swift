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
                let _ = print(item.id)
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.name)
                            .foregroundColor(item.isOn ? .black : .black.opacity(0.5))
                        Text(item.description)
                            .font(.caption)
                            .foregroundColor(item.isOn ? .black : .black.opacity(0.5))
                    }
                    Spacer()
                    Text(item.isOn ? "" : "Disabled")
                        .foregroundColor(item.isOn ? .black : .black.opacity(0.5))
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    self.viewModel.toggle(alarm: item)
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive){
                        guard let index = self.viewModel.items.firstIndex(where: { $0.id == item.id }) else { return }
                        self.viewModel.deleteButtonTapped(at: index)
                    } label: {
                        Label("Trash", systemImage: "trash.circle")
                    }
                }
                .alert(
                    item.name,
                    isPresented: Binding(
                        get: {
                            guard case let .deleteAlert(itemToDelete) = self.viewModel.route else { return false }
                            return itemToDelete == item
                        },
                        set: { isPresented in
                            if !isPresented {
                                self.viewModel.route = nil
                            }
                        }
                    ),
                    presenting: item,
                    actions: { item in
                        Button("Delete", role: .destructive) {
                            withAnimation {
                                self.viewModel.delete(item)
                            }
                        }
                    },
                    message: { _ in
                        Text("Are you sure you want to delete this alert?")
                    }
                )
            }
        }
        .navigationTitle("Alarms")
    }
}

struct AlarmsListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AlarmsListView(
                viewModel: .init(
                    items: [
                        .init(id: .init(), date: .init(), isOn: false),
                        .init(id: .init(), date: .init(), isOn: true),
                        .init(id: .init(), date: .init(), isOn: false)
                    ]
                )
            )
        }
    }
}
