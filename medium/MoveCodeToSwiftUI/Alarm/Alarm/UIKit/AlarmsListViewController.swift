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
    }
}

extension AlarmsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard self.viewModel.items.count > indexPath.row else { return }
        let item = self.viewModel.items[indexPath.row]
        self.viewModel.toggle(alarm: item)
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
