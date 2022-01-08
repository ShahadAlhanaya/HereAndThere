//
//  Utilities.swift
//  HereAndThere
//
//  Created by Shahad Nasser on 01/01/2022.
//

import Foundation
class Utilities {
    
    static func isValidPassword(_ password: String)-> Bool{
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[a-zA-Z\\d]{8,}$")
        return passwordTest.evaluate(with: password)
    }
    
    static func isValidEmail(_ email: String)-> Bool{
        let emailTest = NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
        return emailTest.evaluate(with: email)
    }
    
    
}
