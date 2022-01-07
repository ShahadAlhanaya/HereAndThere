//
//  User.swift
//  HereAndThere
//
//  Created by Shahad Nasser on 02/01/2022.
//

import Foundation
import FirebaseFirestoreSwift

class User: Codable {
    @DocumentID var id: String?
    let email, firstName, lastName, image: String
    var name: String?
    
    init(email: String, firstName: String, lastName: String, image: String) {
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.image = image
        self.name = "\(firstName) \(lastName)"
    }
    
    func setFullName(){
        name = "\(firstName) \(lastName)"
    }
    
    
}
