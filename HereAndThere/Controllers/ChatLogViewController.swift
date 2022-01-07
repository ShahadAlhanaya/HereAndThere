//
//  ChatLogTableViewController.swift
//  HereAndThere
//
//  Created by Shahad Nasser on 04/01/2022.
//

import UIKit
import Firebase
import MessageKit
import InputBarAccessoryView

class ChatLogViewController: MessagesViewController{
    
    var currentUser: User?
    var user: User?
    var chatID: String?
    var chat: Chat?
    var kSender: Sender?
    var kReceiver: Sender?
    
    
    var messages = [KMessage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messagesCollectionView.backgroundColor = UIColor(named: "WHITE_OWL")
        messagesCollectionView.backgroundColor = UIColor(patternImage: UIImage(named: "chat_bg")!)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "ACAI_BERRY")]
        if Auth.auth().currentUser?.uid == nil || user == nil{

        }else{
            fetchCurrentUser()
            kReceiver = Sender(senderId: user!.id!, displayName: user!.name!)
                
            title = user?.name ?? "Chat"
            showMessageTimestampOnSwipeLeft = true

            messagesCollectionView.messagesDataSource = self
            messagesCollectionView.messagesLayoutDelegate = self
            messagesCollectionView.messagesDisplayDelegate = self
            messagesCollectionView.messageCellDelegate = self
            messageInputBar.delegate = self
            messageInputBar.inputTextView.placeholder = "Message"
            messageInputBar.sendButton.image = UIImage(systemName: "paperplane.fill")
            messageInputBar.sendButton.title = ""
            messageInputBar.tintColor = UIColor(named: "INFORMATIVE_PINK")
            messageInputBar.inputTextView.textColor = UIColor(named: "ACAI_BERRY")
            
            
            if chatID != "" {
                chat = getChat(chatID: chatID!)
            }
        }
    }
    
    func getChat(chatID: String)-> Chat?{
        var chat: Chat?
        Firestore.firestore().collection("chats").document(chatID).addSnapshotListener {documentSnapshot, error in
            if let error = error {
                print("error in getting chat: \(error.localizedDescription)")
            }else{
                if documentSnapshot!.exists {
                    do{
                        chat = try documentSnapshot!.data(as: Chat.self)!
                        self.setChatData(chat: chat)
                        
                    }catch{
                        print(error)
                    }
                }
            }
        }
        return chat
    }
    
    func setChatData(chat: Chat?){
        let chatMessages = chat?.messages ?? [Message]()
        print("chat messages \(chatMessages)")
        messages = []
        for m in chatMessages{
            var sender = kSender
            if m.senderID != kSender!.senderId {
                sender = kReceiver
            }
            messages.append(KMessage(sender: sender as! SenderType, messageId: "\(m.id)" , sentDate: Date(timeIntervalSince1970: TimeInterval(m.timestamp)), kind: .text(m.text)))
        }
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToLastItem()
    }
    
    func fetchCurrentUser(){
        let uid = Auth.auth().currentUser?.uid
        Firestore.firestore().collection("users").document(uid!).addSnapshotListener{
            document, error in
            if let error = error {
            print("\(error.localizedDescription)")
                return
            }
            if let document = document, document.exists {
                do{
                    self.currentUser = try document.data(as: User.self)
                    self.currentUser!.setFullName()
                    self.kSender = Sender(senderId: self.currentUser!.id!, displayName: self.currentUser!.name!)
                }catch{
                    print(error)
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func saveMessage(receiverID: String, senderID: String, text: String, timestamp: Int){
        if chatID != "" {
            Firestore.firestore().collection("chats").document(chatID!).updateData([
                "recentMessage": [
                    "receiverID": receiverID,
                    "senderID": senderID,
                    "text": text,
                    "timestamp": timestamp
                ],
                "messages": FieldValue.arrayUnion([[
                    "receiverID": receiverID,
                    "senderID": senderID,
                    "text": text,
                    "timestamp": timestamp
                ]])
            ]){
                error in
                if let error = error {
                    print("error \(error)")
                }
            }
        }
    }
    
}

extension ChatLogViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate{
    
    func currentSender() -> SenderType {
        return kSender!
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? UIColor(named: "INFORMATIVE_PINK")! : UIColor(named: "TURQUOISE_CHALK")!
    }
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : UIColor(named: "ACAI_BERRY")!
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(tail, .pointedEdge)
    }
    
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        avatarView.image =  UIImage(named: "empty_profile")
        if message.sender.senderId == user!.id{
            guard let url = URL(string: user!.image) else { return }
            avatarView.sd_setImage(with: url)
        }else{
            guard let url = URL(string: currentUser!.image) else { return }
            avatarView.sd_setImage(with: url)
        }
        avatarView.setCorner(radius: 10)
    }

//    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
//        return 10
//    }
    
//    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
//        let dateString = convertDate(date: message.sentDate, format: "h:mm a")
//        return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
//    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let dateString = convertDate(date: message.sentDate, format: "h:mm a")
        return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 17
    }
    
//    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
//        return 10
//    }
    
//    func footerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
//        return CGSize(width: 300, height: 300)
//    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 20
    }

    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        print("oh nice")
        let name = message.sender.displayName
        print(name)
        return NSAttributedString(string: name, attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "ACAI_BERRY")])
    }
    
    
    func convertDate(date: Date, format: String)-> String{
          let date = date
          let dateFormatter = DateFormatter()
          dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
          dateFormatter.locale = NSLocale.current
          dateFormatter.dateFormat = format
          return dateFormatter.string(from: date)
      }
    
}

extension ChatLogViewController: MessageCellDelegate{
    func didTapMessage(in cell: MessageCollectionViewCell) {
        print("tapped Message!")
    }

    func didTapAvatar(in cell: MessageCollectionViewCell) {
        print("tapped Avatar!")
    }
}

extension ChatLogViewController: InputBarAccessoryViewDelegate{
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        self.saveMessage(receiverID: kReceiver!.senderId, senderID: kSender!.senderId, text: text.trimmingCharacters(in: .whitespacesAndNewlines), timestamp: Int(Date().timeIntervalSince1970))
        inputBar.inputTextView.text = ""
        self.messagesCollectionView.scrollToLastItem(animated: true)
    }
}


struct sender: SenderType{
    var senderId: String
    var displayName: String
}

struct KMessage: MessageType{
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    
    
}


