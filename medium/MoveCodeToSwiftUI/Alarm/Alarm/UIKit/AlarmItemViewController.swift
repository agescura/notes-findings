//
//  AlarmItemViewController.swift
//  Alarm
//
//  Created by Albert Gil Escura on 20/12/21.
//

import Foundation
import UIKit
import Combine

class AlarmItemViewController: UIViewController {
    let viewModel: AlarmItemViewModel
    private var cancellables: Set<AnyCancellable> = []
    
    let datePicker: UIDatePicker = {
        let view = UIDatePicker()
        view.preferredDatePickerStyle = .wheels
        return view
    }()
    
    let labelView: UILabel = {
        let label = UILabel()
        label.text = "Do you want to activate?"
        return label
    }()
    
    let switchView: UISwitch = {
        let view = UISwitch()
        return view
    }()
    
    init(viewModel: AlarmItemViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        let horizontalStackView = UIStackView(arrangedSubviews: [labelView, switchView])
        horizontalStackView.axis = .horizontal
        
        let stackView = UIStackView(arrangedSubviews: [datePicker, horizontalStackView])
        stackView.spacing = UIStackView.spacingUseSystem
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        
        self.view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: self.view.readableContentGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: self.view.readableContentGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: self.view.readableContentGuide.trailingAnchor),
        ])
        
        self.viewModel.$alarmItem
            .map(\.date)
            .removeDuplicates()
            .sink { [unowned self] in
                self.datePicker.date = $0
            }
            .store(in: &self.cancellables)
        
        self.viewModel.$alarmItem
            .map(\.isOn)
            .removeDuplicates()
            .sink { [unowned self] in
                self.switchView.isOn = $0
            }
            .store(in: &self.cancellables)
        
        self.datePicker.addAction(
            .init { [unowned self] _ in
                self.viewModel.alarmItem.date = self.datePicker.date
            }, for: .valueChanged
        )
        
        self.switchView.addAction(
            .init { [unowned self] _ in
                self.viewModel.alarmItem.isOn = self.switchView.isOn
            }, for: .valueChanged
        )
    }
}

import SwiftUI

struct AlarmItemViewController_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIWrapper {
            UINavigationController(
                rootViewController: AlarmItemViewController(
                    viewModel: .init(
                        alarmItem: .init(
                            id: .init(),
                            date: .init(),
                            isOn: false
                        )
                    )
                )
            )
        }
    }
}
