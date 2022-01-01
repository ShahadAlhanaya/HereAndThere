//
//  User.swift
//  HereAndThere
//
//  Created by Shahad Nasser on 02/01/2022.
//

import Foundation
class User{
    var id: String
    var firstName: String
    var lastName: String
    var email: String
    var name: String
    
    init(id: String, firstName: String, lastName: String, email: String){
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.name = "\(firstName) \(lastName)"
    }
}
