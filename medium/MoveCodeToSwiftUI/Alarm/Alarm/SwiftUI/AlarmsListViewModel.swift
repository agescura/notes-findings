//
//  AlarmsListViewModel.swift
//  Alarm
//
//  Created by Albert Gil Escura on 20/12/21.
//

import Foundation

struct AlarmItem: Identifiable, Hashable, Equatable {
    let id: UUID
    var date: Date
    var isOn: Bool
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

class AlarmsListViewModel: ObservableObject {
    @Published var items: [AlarmItemRowViewModel]
    @Published var route: Route?
    
    enum Route: Equatable, Identifiable {
        case add(AlarmItemViewModel)
        case items(id: AlarmItemRowViewModel.ID, route: AlarmItemRowViewModel.Route)
        
        var id: UUID {
            switch self {
            case let .add(item):
                return item.id
            case let .items(id: id, route: _):
                return id
            }
        }
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case let (.add(lhs), .add(rhs)):
                return lhs === rhs
            case let (.items(lhsId, lhsRoute), .items(rhsId, rhsRoute)):
                return lhsId == rhsId && lhsRoute == rhsRoute
            case (.add, .items), (.items, .add):
                return false
            }
        }
    }
    
    init(
        items: [AlarmItemRowViewModel] = [],
        route: Route? = nil
    ) {
        self.items = []
        self.route = route
        
        for row in items {
            self.bind(itemRowViewModel: row)
        }
    }
    
    private func bind(itemRowViewModel: AlarmItemRowViewModel) {
        print(itemRowViewModel.id.uuidString)
        itemRowViewModel.onDelete = { [weak self, item =  itemRowViewModel.item] in
            self?.delete(item: item)
        }
        itemRowViewModel.onToggle = { [weak self, item =  itemRowViewModel.item] in
            self?.toggle(item: item)
        }
        itemRowViewModel.$route
            .map { [id = itemRowViewModel.id] route in
                route.map { .items(id: id, route: $0) }
            }
            .removeDuplicates()
            .dropFirst()
            .assign(to: &self.$route)
        self.$route
            .map { [id = itemRowViewModel.id] route in
                guard case let .items(id: routeRowId, route: route) = route,
                routeRowId == id else { return nil }
                return route
            }
            .removeDuplicates()
            .assign(to: &itemRowViewModel.$route)
        self.items.append(itemRowViewModel)
    }
    
    func cancelButtonTapped() {
        self.route = nil
    }
    
    func add(item: AlarmItem) {
        self.items.append(.init(item: item))
        self.route = nil
    }
    
    func addButtonTapped() {
        self.route = .add(.init(alarmItem: .init(id: .init(), date: .init(), isOn: true)))
    }
    
    func delete(item: AlarmItem) {
        guard let index = self.items.firstIndex(where: { $0.item == item }) else { return }
        self.items.remove(at: index)
    }
    
    func toggle(item: AlarmItem) {
        guard let index = self.items.firstIndex(where: { $0.item == item }) else { return }
        self.items[index].item.isOn.toggle()
    }
}

