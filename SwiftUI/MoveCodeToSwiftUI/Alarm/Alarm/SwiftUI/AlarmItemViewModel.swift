//
//  AlarmItemViewModel.swift
//  Alarm
//
//  Created by Albert Gil Escura on 20/12/21.
//

import Foundation
import Combine

class AlarmItemViewModel: ObservableObject, Identifiable {
    @Published var alarmItem: AlarmItem
    
    var id: AlarmItem.ID { self.alarmItem.id }
    
    init(alarmItem: AlarmItem) {
        self.alarmItem = alarmItem
    }
}
