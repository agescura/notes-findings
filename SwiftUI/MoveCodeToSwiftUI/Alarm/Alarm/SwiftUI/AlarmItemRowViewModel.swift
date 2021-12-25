//
//  AlarmItemRowViewModel.swift
//  Alarm
//
//  Created by Albert Gil Escura on 23/12/21.
//

import SwiftUI

extension AlarmItem {
    var status: String {
        self.isOn ? "Disable" : "Enable"
    }
}

class AlarmItemRowViewModel: ObservableObject, Hashable, Equatable, Identifiable {
    @Published var item: AlarmItem
    @Published var route: Route?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.item.id)
    }
    
    static func == (lhs: AlarmItemRowViewModel, rhs: AlarmItemRowViewModel) -> Bool {
        lhs.item.id == rhs.item.id
    }
    
    var id: AlarmItem.ID { self.item.id }
    
    enum Route: Equatable {
        case deleteAlert
        case toggleConfirmationDialog
        case edit(AlarmItemViewModel)
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case (.deleteAlert, .deleteAlert):
                return true
            case (.toggleConfirmationDialog, .toggleConfirmationDialog):
                return true
            case let (.edit(lhs), .edit(rhs)):
                return lhs === rhs
            case (.deleteAlert, _), (.toggleConfirmationDialog, _), (.edit, _):
                return false
            }
        }
    }
    
    init(
        item: AlarmItem
    ) {
        self.item = item
    }
    
    var onDelete: () -> Void = {}
    
    func deleteButtonTapped() {
        self.route = .deleteAlert
    }
    
    func deleteConfirmationButtonTapped() {
        self.onDelete()
        self.route = nil
    }
    
    func cancelButtonTapped() {
        self.route = nil
    }
    
    func toggleButtonTapped() {
        self.route = .toggleConfirmationDialog
    }
    
    var onToggle: () -> Void = {}
    
    func toggleConfirmationButtonTapped() {
        self.onToggle()
        self.route = nil
    }
    
    func edit(item: AlarmItem) {
        self.item = item
        self.route = nil
    }
    
    func setEditNavigation(isActive: Bool) {
        self.route = isActive ? .edit(.init(alarmItem: self.item)) : nil
    }
}
