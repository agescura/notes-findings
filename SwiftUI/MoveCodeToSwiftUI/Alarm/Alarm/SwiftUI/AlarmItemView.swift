//
//  AlarmItemView.swift
//  Alarm
//
//  Created by Albert Gil Escura on 20/12/21.
//

import SwiftUI

struct AlarmItemView: View {
    @ObservedObject var viewModel: AlarmItemViewModel
    
    var body: some View {
        Form {
            DatePicker("Date", selection: self.$viewModel.alarmItem.date)
            Toggle("Do you want to activate?", isOn: self.$viewModel.alarmItem.isOn)
        }
    }
}

struct AlarmItemView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AlarmItemView(
                viewModel: .init(
                    alarmItem: .init(
                        id: .init(),
                        date: .init(),
                        isOn: false
                    )
                )
            )
        }
    }
}
