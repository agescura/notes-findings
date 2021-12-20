//
//  AlarmsListViewModel.swift
//  Alarm
//
//  Created by Albert Gil Escura on 20/12/21.
//

import Foundation

struct AlarmItem: Identifiable, Hashable {
  let id: UUID
  var date: Date
  var isOn: Bool
}

class AlarmsListViewModel: ObservableObject {
    @Published var items: [AlarmItem]
    @Published var route: Route?
    
    enum Route: Equatable, Identifiable {
        case deleteAlert(AlarmItem)
        
        var id: UUID {
            switch self {
            case let .deleteAlert(item):
                return item.id
            }
        }
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case let (.deleteAlert(lhs), .deleteAlert(rhs)):
                return lhs == rhs
            }
        }
    }
    
    init(
        items: [AlarmItem] = [],
        route: Route? = nil
    ) {
        self.items = items
        self.route = route
    }
    
    func toggle(alarm item: AlarmItem) {
        guard let index = self.items.firstIndex(where: { $0 == item }) else { return }
        self.items[index].isOn.toggle()
    }
    
    func deleteButtonTapped(at index: Int) {
        let item = self.items[index]
        self.route = .deleteAlert(item)
    }
    
    func cancelButtonTapped() {
        self.route = nil
    }
    
    func delete(_ item: AlarmItem) {
        guard let index = self.items.firstIndex(where: { $0.id == item.id }) else { return }
        self.items.remove(at: index)
    }
}

