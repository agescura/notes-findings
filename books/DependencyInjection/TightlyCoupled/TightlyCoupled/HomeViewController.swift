//
//  HomeViewController.swift
//  TightlyCoupled
//
//  Created by Albert Gil Escura on 17/4/21.
//

import UIKit

class HomeViewController: UIViewController {
    
    // MARK: - User
    
    var user: User?
    
    // MARK: - Service
    
    private let service = ProductService()
    
    // MARK: Products
    
    private var products: [Product] = []
    
    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        tableView.dataSource = self
        reloadProducts()
    }

    // MARK: - Actions
    
    @IBAction func addProduct(_ sender: UIBarButtonItem) {
        let newProduct = Product(id: UUID(),
                                  name: random(length: 5),
                                  description: random(length: 50),
                                  unitPrice: 10, isFeatured: true)
        
        service.add(product: newProduct)
        reloadProducts()
    }
    
    private func reloadProducts() {
        products = service.getFeaturedProducts(isCustomerPreferred: true)
        tableView.reloadData()
    }
    
    private func random(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
      }
}

// MARK: UITableViewDataSource

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath)
        cell.textLabel?.text = products[indexPath.row].name
        return cell
    }
}
