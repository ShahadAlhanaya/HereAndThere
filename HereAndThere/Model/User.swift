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

class ChatReferene: Codable {
    @DocumentID var id: String?
    let receiverID: String

    init(receiverID: String) {
        self.receiverID = receiverID
    }
}



class Chat: Codable {
    @DocumentID var id: String?
    let users: [String]?
    let messages: [Message]?
    let recentMessage: Message?

    init(id: String? ,users: [String]?, messages: [Message], recentMessage: Message) {
        self.users = users
        self.messages = messages
        self.recentMessage = recentMessage
        self.id = id
    }
}


struct Message: Codable{
    @DocumentID var id: String?
    let senderID, receiverID, text: String
    let timestamp: Int

    init(senderID: String, receiverID: String, text: String, timestamp: Int) {
        self.senderID = senderID
        self.receiverID = receiverID
        self.text = text
        self.timestamp = timestamp
        self.id = id
    }
}


class ChatListItem{
    var chat: Chat
    var user: User
    
    init(chat: Chat, user: User){
        self.chat = chat
        self.user = user
    }
    
    
}
