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
    
    init(items: [AlarmItem] = []) {
        self.items = items
    }
    
    func toggle(alarm item: AlarmItem) {
        guard let index = self.items.firstIndex(where: { $0 == item }) else { return }
        self.items[index].isOn.toggle()
    }
}

