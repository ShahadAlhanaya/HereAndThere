//
//  FirestoreModel.swift
//  HereAndThere
//
//  Created by Shahad Nasser on 09/01/2022.
//

import Foundation
import UIKit
import Firebase

class FirebaseModel{
    
    static func uploadUserImage(userID: String, image: UIImage, completionHandler: @escaping (Result<StorageMetadata, Error>) -> Void){
        let storageRef = Storage.storage().reference().child("\(userID).png")
        if let uploadData = image.jpegData(compressionQuality: 0.5){
            storageRef.putData(uploadData, metadata: nil) { storageMetaData, error in
                if let error = error {
                    completionHandler(.failure(error))
                }else{
                    storageRef.downloadURL { url, error in
                        let imageURL = url!.absoluteString
                        Firestore.firestore().collection("users").document(userID).updateData([
                            "image": imageURL,
                        ]){ error in
                            if let error = error {
                                print("error in saving image reference: \(error)")
                            }
                        }
                    }
                    completionHandler(.success(storageMetaData!))
                }
            }
        }
        
    }
    
    static func createFirestoreUser(firstName: String, lastName: String, email: String, uid: String, completionHandler: @escaping (Result<String, Error>) -> Void){
        Firestore.firestore().collection("users").document(uid).setData([
            "firstName": firstName,
            "lastName": lastName,
            "email": email,
        ]){ error in
            if let error = error {
                completionHandler(.failure(error))
            } else {
                completionHandler(.success(uid))
                print("user created: \(uid)")
            }
        }
    }
    
    static func saveFacebookUser(firstName: String, lastName: String, email: String, uid: String, image: String, completionHandler: @escaping (Result<String, Error>) -> Void){
        Firestore.firestore().collection("users").document(uid).setData([
            "firstName": firstName,
            "lastName": lastName,
            "email": email,
            "image": image
        ]){ error in
            if let error = error {
                completionHandler(.failure(error))
            } else {
                completionHandler(.success(uid))
                print("user saved: \(uid)")
            }
        }
    }
}
