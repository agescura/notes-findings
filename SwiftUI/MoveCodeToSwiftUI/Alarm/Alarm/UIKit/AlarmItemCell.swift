//
//  AlarmItemCell.swift
//  Alarm
//
//  Created by Albert Gil Escura on 20/12/21.
//

import UIKit
import Combine

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
    var cancellables: Set<AnyCancellable> = []
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.cancellables = []
    }
    
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
    
    func bind(viewModel: AlarmItemRowViewModel, context: UIViewController) {
        selectionStyle = .none
        
        viewModel.$item
            .map(\.name)
            .removeDuplicates()
            .sink { [unowned self] name in
                self.nameLabel.text = name
            }
            .store(in: &self.cancellables)
        viewModel.$item
            .map(\.description)
            .removeDuplicates()
            .sink { [unowned self] description in
                self.descriptionLabel.text = description
            }
            .store(in: &self.cancellables)
        viewModel.$item
            .map(\.isOn)
            .removeDuplicates()
            .sink { [unowned self] isOn in
                self.nameLabel.textColor = isOn ? .black : .black.withAlphaComponent(0.5)
                self.descriptionLabel.textColor = isOn ? .black : .black.withAlphaComponent(0.5)
                self.activateLabel.text = isOn ? "" : "Disabled"
                self.activateLabel.textColor = isOn ? .black : .black.withAlphaComponent(0.5)
            }
            .store(in: &self.cancellables)
        
        descriptionLabel.font = .systemFont(ofSize: 14)
        verticalStackView.addArrangedSubview(nameLabel)
        verticalStackView.addArrangedSubview(descriptionLabel)
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
        
        var presentedViewController: UIViewController?
        
        viewModel.$route
            .removeDuplicates()
            .sink { route in
                switch route {
                case .none:
                    guard let vc = presentedViewController else { return }
                    vc.dismiss(animated: true)
                    presentedViewController = nil
                case .deleteAlert:
                    let alert = UIAlertController(
                        title: viewModel.item.name,
                        message: "Are you sure you want to delete this item?",
                        preferredStyle: .alert
                    )
                    alert.addAction(.init(title: "Cancel", style: .cancel, handler: { _ in
                        viewModel.cancelButtonTapped()
                    }))
                    alert.addAction(.init(title: "Delete", style: .destructive, handler: { _ in
                        viewModel.deleteConfirmationButtonTapped()
                    }))
                    context.present(alert, animated: true)
                    presentedViewController = alert
                case .toggleConfirmationDialog:
                    let alert = UIAlertController(
                        title: viewModel.item.name,
                        message: viewModel.item.description,
                        preferredStyle: .actionSheet
                    )
                    alert.addAction(.init(title: "Cancel", style: .cancel, handler: { _ in
                        viewModel.toggleButtonTapped()
                    }))
                    alert.addAction(.init(title: viewModel.item.status, style: .default, handler: { _ in
                        viewModel.toggleConfirmationButtonTapped()
                    }))
                    context.present(alert, animated: true)
                    presentedViewController = alert
                case let .edit(itemViewModel):
                    let vc = AlarmItemViewController(viewModel: itemViewModel)
                    vc.title = "Edit"
                    vc.navigationItem.leftBarButtonItem = .init(
                        title: "Cancel",
                        primaryAction: .init { _ in
                            viewModel.cancelButtonTapped()
                        }
                    )
                    vc.navigationItem.rightBarButtonItem = .init(
                        title: "Save",
                        primaryAction: .init { _ in
                            viewModel.edit(item: itemViewModel.alarmItem)
                        }
                    )
                    context.show(vc, sender: nil)
                    presentedViewController = vc
                    break
                }
            }
            .store(in: &self.cancellables)
    }
}
