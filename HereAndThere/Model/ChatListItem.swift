//
//  ChatListItem.swift
//  HereAndThere
//
//  Created by Shahad Nasser on 07/01/2022.
//

import Foundation

class ChatListItem{
    var chat: Chat
    var user: User
    
    init(chat: Chat, user: User){
        self.chat = chat
        self.user = user
    }
}
