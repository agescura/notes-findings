//
//  AlarmItemRowView.swift
//  Alarm
//
//  Created by Albert Gil Escura on 23/12/21.
//

import SwiftUI

struct AlarmItemRowView: View {
    @ObservedObject var viewModel: AlarmItemRowViewModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(self.viewModel.item.name)
                    .foregroundColor(self.viewModel.item.isOn ? .black : .black.opacity(0.5))
                Text(self.viewModel.item.description)
                    .font(.caption)
                    .foregroundColor(self.viewModel.item.isOn ? .black : .black.opacity(0.5))
            }
            Spacer()
            Text(self.viewModel.item.isOn ? "" : "Disabled")
                .foregroundColor(self.viewModel.item.isOn ? .black : .black.opacity(0.5))
        }
        .contentShape(Rectangle())
        .onTapGesture {
            //self.viewModel.toggle(alarm: item)
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                self.viewModel.deleteButtonTapped()
            } label: {
                Label("Trash", systemImage: "trash.circle")
            }
        }
        .swipeActions(edge: .leading) {
            Button {
                self.viewModel.toggleButtonTapped()
            } label: {
                Label(self.viewModel.item.status, systemImage: "alarm")
            }
        }
        .alert(
            viewModel.item.name,
            isPresented: Binding(
                get: {
                    guard case.deleteAlert = self.viewModel.route else { return false }
                    return true
                },
                set: { isPresented in
                    if !isPresented {
                        self.viewModel.route = nil
                    }
                }
            ),
            presenting: viewModel.item,
            actions: { item in
                Button("Delete", role: .destructive) {
                    withAnimation {
                        self.viewModel.deleteConfirmationButtonTapped()
                    }
                }
            },
            message: { _ in
                Text("Are you sure you want to delete this alert?")
            }
        )
        .confirmationDialog(
            viewModel.item.name,
            isPresented: Binding(
                get: {
                    guard case.toggleConfirmationDialog = self.viewModel.route else { return false }
                    return true
                },
                set: { isPresented in
                    if !isPresented {
                        self.viewModel.route = nil
                    }
                }
            ),
            titleVisibility: .visible,
            presenting: viewModel.item,
            actions: { item in
                Button(item.status) {
                    withAnimation {
                        self.viewModel.toggleConfirmationButtonTapped()
                    }
                }
            },
            message: { item in
                Text(item.description)
            }
        )
    }
}
