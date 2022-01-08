//
//  ViewController.swift
//  HereAndThere
//
//  Created by Shahad Nasser on 01/01/2022.
//

import UIKit
import Firebase
import SDWebImage
import FBSDKLoginKit

class ViewController: UIViewController{

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var noChatsImage: UIImageView!
    
    var uid = ""
    var chatList = [ChatListItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        if checkUserLogged() {
            uid = Auth.auth().currentUser!.uid
            getUserData()
            getChatIDS()
        }
        
    }

    override func viewDidAppear(_ animated: Bool) {
        if checkUserLogged() {
            tableView.reloadData()
        }else{
            handleLogout()
        }
    }
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Logout", message: "Are you sure want to log out from your account?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Logout", style: .default, handler: {action in
            self.handleLogout()

        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func addChatButtonPressed(_ sender: UIBarButtonItem) {
        handleOpenChat()
    }
   
    func getUserData(){
        print("Getting user")
        Firestore.firestore().collection("users").document(uid).addSnapshotListener { documentSnapshot, error in
            if let error = error {
                print(error)
            }else{
                if documentSnapshot!.exists {
                    do{
                        let user = try documentSnapshot!.data(as: User.self)
                        user?.setFullName()
                        self.userNameLabel.text = user?.name
                        self.userEmailLabel.text = user?.email
                        if let image = user?.image {
                            self.userImageView.sd_setImage(with: URL(string: image))
                        }
                    }catch{
                        print(error)
                    }
                }
            }
        }
    }
    
    func getChatIDS(){
        print("Getting chat IDs")
        Firestore.firestore().collection("users").document(uid).collection("chats").addSnapshotListener { querySnapshot, error in
            if let error = error {
                print(error)
            }else{
                if querySnapshot!.isEmpty == false {
                    for cr in querySnapshot!.documents {
                        do{
                            let chatRef = try cr.data(as: ChatReferene.self)
                            self.getChat(chatRef: chatRef!)
                        }catch{
                            print(error)
                        }
                    }
                }else{
                    self.noChatsImage.isHidden = false
                }
            }
        }
    }
    
    func getChat(chatRef: ChatReferene){
        print("Getting chats")
        Firestore.firestore().collection("chats").document(chatRef.id!).addSnapshotListener { documentSnapshot, error in
            if let error = error {
                print(error)
            }else{
                if documentSnapshot!.exists {
                    do{
                        let c = try documentSnapshot?.data(as: Chat.self)
                        if c?.recentMessage != nil {
                            self.getUserDetails(c: c!, userID: chatRef.receiverID)
                        }
                    }catch{print(error)}
                }
            }
        }
    }
    
    func getUserDetails(c: Chat,userID: String){
        Firestore.firestore().collection("users").document(userID).addSnapshotListener{ documentSnapshot, error in
            if let error = error {
                print(error)
            }else{
                if documentSnapshot!.exists{
                    do{
                        let user = try documentSnapshot?.data(as: User.self)
                        user?.setFullName()
                        self.updateChatList(cItem: ChatListItem(chat: c, user: user!))
                    }catch{
                        print(error)
                    }
                }
            }
        }
    }
    
    func updateChatList(cItem: ChatListItem){
        print("Getting updating")
        var found = -1
        for i in 0..<chatList.count{
            if chatList[i].chat.id == cItem.chat.id {
                found = i
            }
        }
    
        if found == -1 {
            chatList.append(cItem)
        }else{
            chatList[found] = cItem
        }
        
        if chatList.isEmpty {
            self.noChatsImage.isHidden = false
        }else{
            self.noChatsImage.isHidden = true
        }
        
        chatList.sort(by: { $0.chat.recentMessage!.timestamp > $1.chat.recentMessage!.timestamp })
        print("reloading")
        tableView.reloadData()
    }
    
    func checkUserLogged()->Bool{
        if Auth.auth().currentUser?.uid == nil{
            return false
        }else{
            return true
        }
    }

    func handleLogout(){
        
        //logout facebook
        FBSDKLoginKit.LoginManager().logOut()
        
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

    func handleOpenChat(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ContactsVC")
        vc.modalPresentationStyle = .fullScreen
        self.navigationController!.pushViewController(vc, animated: true)
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell")! as! ChatListTableViewCell
        cell.user = chatList[indexPath.row].user
        cell.chat = chatList[indexPath.row].chat
        cell.configure()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = ChatLogViewController()
        vc.user = chatList[indexPath.row].user
        vc.chatID = chatList[indexPath.row].chat.id
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

