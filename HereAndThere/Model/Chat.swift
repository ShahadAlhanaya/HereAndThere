//
//  Chat.swift
//  HereAndThere
//
//  Created by Shahad Nasser on 07/01/2022.
//

import Foundation
import FirebaseFirestoreSwift

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


