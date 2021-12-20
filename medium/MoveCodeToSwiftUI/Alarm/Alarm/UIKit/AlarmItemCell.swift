//
//  AlarmItemCell.swift
//  Alarm
//
//  Created by Albert Gil Escura on 20/12/21.
//

import UIKit

extension AlarmItem {
    var name: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self.date)
    }
    var description: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM, yyyy"
        return formatter.string(from: self.date)
    }
}

class AlarmItemCell: UITableViewCell {
    let nameLabel = UILabel()
    let descriptionLabel = UILabel()
    let activateLabel = UILabel()
    let verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = UIStackView.spacingUseSystem
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .equalCentering
        return stackView
    }()
    
    func bind(viewModel: AlarmItem) {
        selectionStyle = .none
        nameLabel.text = viewModel.name
        nameLabel.textColor = viewModel.isOn ? .black : .black.withAlphaComponent(0.5)
        descriptionLabel.font = .systemFont(ofSize: 14)
        descriptionLabel.text = viewModel.description
        descriptionLabel.textColor = viewModel.isOn ? .black : .black.withAlphaComponent(0.5)
        verticalStackView.addArrangedSubview(nameLabel)
        verticalStackView.addArrangedSubview(descriptionLabel)
        
        activateLabel.text = viewModel.isOn ? "" : "Disabled"
        activateLabel.textColor = viewModel.isOn ? .black : .black.withAlphaComponent(0.5)
        stackView.addArrangedSubview(verticalStackView)
        stackView.addArrangedSubview(activateLabel)
        self.contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            activateLabel.widthAnchor.constraint(equalToConstant: 100),
            stackView.topAnchor.constraint(
                equalTo: self.contentView.safeAreaLayoutGuide.topAnchor
            ),
            stackView.bottomAnchor.constraint(
                equalTo: self.contentView.safeAreaLayoutGuide.bottomAnchor
            ),
            stackView.leadingAnchor.constraint(
                equalTo: self.contentView.safeAreaLayoutGuide.leadingAnchor,
                constant: 16
            ),
            stackView.trailingAnchor.constraint(
                equalTo: self.contentView.safeAreaLayoutGuide.trailingAnchor,
                constant: 16
            )
        ])
    }
}
