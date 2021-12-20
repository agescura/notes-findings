//
//  AlarmsListViewController.swift
//  Alarm
//
//  Created by Albert Gil Escura on 20/12/21.
//

import UIKit
import Combine

class AlarmsListViewController: UIViewController {
    let viewModel: AlarmsListViewModel
    private var cancellables: Set<AnyCancellable> = []
    
    let tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = 60
        tableView.separatorStyle = .none
        tableView.register(
            AlarmItemCell.self,
            forCellReuseIdentifier: "AlarmItemCell"
        )
        return tableView
    }()
    
    init(viewModel: AlarmsListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Alarms"
        self.navigationItem.rightBarButtonItem = .init(
            title: "Add",
            primaryAction: .init { [unowned self] _ in
                self.viewModel.addButtonTapped()
            }
        )
        
        enum Section { case one }
        
        let dataSource = UITableViewDiffableDataSource<Section, AlarmItem>(
            tableView: tableView,
            cellProvider: { tableView, indexPath, item in
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: "AlarmItemCell",
                    for: indexPath
                ) as? AlarmItemCell else {
                    return UITableViewCell(frame: .zero)
                }
                cell.bind(viewModel: item)
                cell.contentView.backgroundColor = indexPath.row % 2 == 0 ? .white : .black.withAlphaComponent(0.05)
                return cell
            }
        )
        
        dataSource.defaultRowAnimation = .none
        tableView.dataSource = dataSource
        tableView.delegate = self
        
        self.view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.topAnchor
            ),
            tableView.leadingAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.leadingAnchor
            ),
            tableView.trailingAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.trailingAnchor
            ),
            tableView.bottomAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.bottomAnchor
            ),
        ])
        
        self.viewModel.$items
            .sink { items in
                var snapshot = NSDiffableDataSourceSnapshot<Section, AlarmItem>()
                snapshot.appendSections([.one])
                snapshot.appendItems(items, toSection: .one)
                dataSource.apply(snapshot, animatingDifferences: true)
            }
            .store(in: &self.cancellables)
        
        var presentedViewController: UIViewController?
        
        self.viewModel.$route
            .removeDuplicates()
            .sink { route in
                switch route {
                case .none:
                    guard let vc = presentedViewController else { return }
                    vc.dismiss(animated: true)
                    presentedViewController = nil
                case let .deleteAlert(item):
                    let alert = UIAlertController(
                        title: item.name,
                        message: "Are you sure you want to delete this alarm?",
                        preferredStyle: .alert
                    )
                    alert.addAction(.init(title: "Cancel", style: .cancel, handler: { _ in
                        self.viewModel.cancelButtonTapped()
                    }))
                    alert.addAction(.init(title: "Delete", style: .destructive, handler: { _ in
                        self.viewModel.delete(item)
                    }))
                    self.present(alert, animated: true)
                    presentedViewController = alert
                case let .add(viewModel):
                    let vc = AlarmItemViewController(viewModel: viewModel)
                    let nc = UINavigationController(rootViewController: vc)
                    vc.title = "Add Alarm"
                    vc.navigationItem.leftBarButtonItem = .init(
                        title: "Cancel",
                        primaryAction: .init { [unowned self] _ in
                            self.viewModel.cancelButtonTapped()
                        }
                    )
                    vc.navigationItem.rightBarButtonItem = .init(
                        title: "Add",
                        primaryAction: .init { [unowned self] _ in
                            self.viewModel.add(item: vc.viewModel.alarmItem)
                        }
                    )
                    self.present(nc, animated: true)
                    presentedViewController = nc
                }
            }
            .store(in: &self.cancellables)
    }
}

extension AlarmsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard self.viewModel.items.count > indexPath.row else { return }
        let item = self.viewModel.items[indexPath.row]
        self.viewModel.toggle(alarm: item)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(
            style: .destructive,
            title: "Remove"
        ) { action, view, completion in
            self.viewModel.deleteButtonTapped(at: indexPath.row)
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

import SwiftUI

struct AlarmsListViewController_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIWrapper {
            UINavigationController(
                rootViewController: AlarmsListViewController(
                    viewModel: .init(
                        items: [
                            .init(id: .init(), date: .init(), isOn: false),
                            .init(id: .init(), date: .init(), isOn: true),
                            .init(id: .init(), date: .init(), isOn: false)
                        ]
                    )
                )
            )
        }
    }
}
