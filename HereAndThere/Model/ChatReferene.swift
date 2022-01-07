//
//  ChatReferene.swift
//  HereAndThere
//
//  Created by Shahad Nasser on 07/01/2022.
//

import Foundation
import FirebaseFirestoreSwift

class ChatReferene: Codable {
    @DocumentID var id: String?
    let receiverID: String

    init(receiverID: String) {
        self.receiverID = receiverID
    }
}
