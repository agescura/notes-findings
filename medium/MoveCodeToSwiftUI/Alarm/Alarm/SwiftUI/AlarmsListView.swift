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
