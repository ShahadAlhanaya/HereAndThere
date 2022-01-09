//
//  AuthenticationModel.swift
//  HereAndThere
//
//  Created by Shahad Nasser on 09/01/2022.
//

import Foundation
import Firebase

class AuthenticaionModel{
    //    typealias rigesterCompletionHandler = (Result<AuthDataResult, Error>) -> Void
    //    typealias rigesterSaveDataCompletionHandler = (Result<Bool, Error>) -> Void
    static var currentUserID = ""
    
    static func createAuthUser(email: String, password: String, completionHandler: @escaping (Result<AuthDataResult, Error>) -> Void){
        Auth.auth().createUser(withEmail: email, password: password) {
            result, error in
                if let error = error {
                    completionHandler(.failure(error))
                } else {
                    completionHandler(.success(result!))
                }
        }
    }
    
    static func logIn(email: String, password: String, completionHandler: @escaping (Result<AuthDataResult, Error>) -> Void){
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completionHandler(.failure(error))
            } else {
                completionHandler(.success(result!))
            }
        }
    }
    
    static func logIn(credentials: AuthCredential, completionHandler: @escaping (Result<AuthDataResult, Error>) -> Void){
        Auth.auth().signIn(with: credentials) { result, error in
            if let error = error {
                completionHandler(.failure(error))
            } else {
                completionHandler(.success(result!))
            }
        }
    }
    
    static func resetPassword(email: String, completionHandler: @escaping (Result<Bool, Error>) -> Void){
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                completionHandler(.failure(error))
            } else {
                completionHandler(.success(true))
            }
        }
    }
    
}
