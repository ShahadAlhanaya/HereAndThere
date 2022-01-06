//
//  ViewController.swift
//  HereAndThere
//
//  Created by Shahad Nasser on 01/01/2022.
//

import UIKit
import Firebase
import SDWebImage

class ViewController: UIViewController{

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    
    var userChatIDs = [String]()
    var chatListItems = [ChatListItem]()
    var chats = [Chat]()
    var uid = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkUserLogged()
        
        tableView.delegate = self
        tableView.dataSource = self
    
    }
    @IBAction func logoutButtonPressed(_ sender: Any) {
        handleLogout()
    }
    
    @IBAction func addChatButtonPressed(_ sender: UIBarButtonItem) {
        handleAddChat()
    }
    
    func checkUserLogged(){
        if Auth.auth().currentUser?.uid == nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.handleLogout()
            }
        }else{
            uid = Auth.auth().currentUser!.uid
            getUserData()
        }
    }
    
    func getUserData(){
        Firestore.firestore().collection("users").document(uid).addSnapshotListener{
            document, error in
            if let error = error {
            print("\(error.localizedDescription)")
                return
            }
            if let document = document, document.exists {
                do{
                    let user = try document.data(as: User.self)
                    user?.setFullName()
                    self.userNameLabel.text = user?.name
                    self.userEmailLabel.text = user?.email
                    if user?.image.trimmingCharacters(in: .whitespaces) != "" {
                        self.userImageView.sd_setImage(with: URL(string: user!.image))
                    }
                    self.getChatIDs()
                }catch{
                    print(error)
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func getChatIDs(){
        Firestore.firestore().collection("users").document(uid).collection("chats").addSnapshotListener {
            querySnapshot, error in
            if let error = error {
                print(error)
            }else{
                for doc in querySnapshot!.documents{
                    self.userChatIDs.append(doc.documentID)
                }
                self.getChats()
            }
        }
    }
    
    func getChats(){
        for chat in userChatIDs {
            Firestore.firestore().collection("chats").document(chat).addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print(error)
                }else{
                    if querySnapshot!.exists {
                        do{
                            print("im here")
                            let c = try querySnapshot?.data(as: Chat.self)
                            self.chats.append(c!)
                            self.getChatUsers(chat: c!)
                        }catch{
                            print(error)
                        }
                    }
                }
            }
        }
    }
    
    func getChatUsers(chat: Chat){
//        chatListItems = []
//        chats = []
        for id in chat.users! {
            if id != uid {
                Firestore.firestore().collection("users").document(id).addSnapshotListener { [self]
                    querySnapshot, error in
                    if let error = error {
                        print(error)
                    }else{
                        if querySnapshot!.exists {
                            do{
                                let user = try querySnapshot?.data(as: User.self)
                                user?.setFullName()
                                self.chatListItems.append(ChatListItem(chat: chat, user: user!))
                                self.chatListItems.sorted() { $0.chat.recentMessage?.timestamp ?? 0 > $1.chat.recentMessage?.timestamp ?? 0 }
                                self.tableView.reloadData()
                            }catch{
                                print(error)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func handleLogout(){
        
        do{
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LoginRegisterVC")
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
    func handleAddChat(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ContactsVC")
        vc.modalPresentationStyle = .fullScreen
        self.navigationController!.pushViewController(vc, animated: true)
//        present(vc, animated: true, completion: nil)
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatListItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell")! as! ChatListTableViewCell
        cell.user = chatListItems[indexPath.row].user
        cell.chat = chatListItems[indexPath.row].chat
        cell.configure()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = ChatLogViewController()
        vc.user = chatListItems[indexPath.row].user
        vc.chatID = chatListItems[indexPath.row].chat.id
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

