//
//  User.swift
//  TightlyCoupled
//
//  Created by Albert Gil Escura on 17/4/21.
//

import Foundation

struct User {
    let name: String
    
    func isIn(role: String) -> Bool {
        if role == "PreferredCustomer" {
            return true
        }
        return false
    }
}
