//
//  ContactsViewController.swift
//  HereAndThere
//
//  Created by Shahad Nasser on 02/01/2022.
//

import UIKit
import Firebase

class ContactsViewController: UIViewController, OpenChatDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var users = [User]()
    var filteredUsers = [User]()
    
    var chatID = ""
    
    var uid = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeBackButton()
        
        if Auth.auth().currentUser?.uid == nil {
        }else{
            fetchUsers()
            uid = Auth.auth().currentUser?.uid ?? ""
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
    }
    
    func fetchUsers(){
        Firestore.firestore().collection("users").addSnapshotListener {
            snapshot, error in
                if let error = error {
                print("\(error.localizedDescription)")
                    return
                }
                self.users = []
                for document in snapshot!.documents {
                    do{
                        let user = try document.data(as: User.self)!
                        if(user.id == Auth.auth().currentUser?.uid){
                            continue
                        }
                        user.setFullName()
                        self.users.append(user)
                        
                    }catch{
                        print(error)
                    }
                   
                }
                self.filteredUsers = self.users
                self.tableView.reloadData()
            }
    }
    
    func customizeBackButton(){
        let imgBack = UIImage(named: "ic_back")
        navigationController?.navigationBar.backIndicatorImage = imgBack
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = imgBack
        self.navigationController?.navigationBar.tintColor = UIColor(named: "INFORMATIVE_PINK")
        navigationItem.leftItemsSupplementBackButton = true
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
    }
    
    func fetchChatID(_ user: User){
        Firestore.firestore().collection("users").document(uid).collection("chats").whereField("receiverID", isEqualTo: user.id).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("there was an error getting chat: \(error.localizedDescription)")
            }else{
                if querySnapshot!.isEmpty {
                    print("chat doesnt exist")
                    //create one
                    self.createChatWith(user)
                }else{
                    //it already exist and i need to get it
                    for doc in querySnapshot!.documents {
                        self.chatID = doc.documentID
                        self.transitionToChatView(user)
                    }
                }
            }
        }
        
    }
    
    func createChatWith(_ user: User){
        let ref = Firestore.firestore().collection("chats").document()
        ref.setData([
            "users" : [uid,user.id]
//            ,"messages": [],
//            "recentMessage": [:]
        ]){
            error in
            if let error = error {
                print("error in creating chat: \(error.localizedDescription)")
            }else{
                self.addChatReference(documentID: ref.documentID,userID: self.uid, receiverID: user.id!)
                self.addChatReference(documentID: ref.documentID, userID: user.id!, receiverID: self.uid)
                self.chatID = ref.documentID
                self.transitionToChatView(user)
                
            }
        }
    }
    
    func addChatReference(documentID: String,userID: String, receiverID: String){
        let ref = Firestore.firestore().collection("users").document(userID).collection("chats").document(documentID)
        ref.setData([ "receiverID" : receiverID]){
            error in
            if let error = error {
                print("error in creating reference of chat in user: \(error.localizedDescription)")
            }
        }
    }
    
    func transitionToChatView(_ user: User){
        let vc = ChatLogViewController()
        vc.user = user
        vc.chatID = chatID
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func openChat(with user: User) {
        //check if chat exist then get it , if not create it
        //in creation steps are: (create reference to chat in user, create reference to chat in other user, create the chat)
        //go to chat view
        fetchChatID(user)
    }
    
}

extension ContactsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell")! as! ContactTableViewCell
        cell.openChatDelegate = self
        cell.user = filteredUsers[indexPath.row]
        cell.configure()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(80)
    }
    
    
}

extension ContactsViewController: UISearchBarDelegate {
 
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredUsers = []
        
        if searchText.trimmingCharacters(in: .whitespaces) == "" {
            filteredUsers = users
        }else{
            for user in users {
                if user.name!.lowercased().contains(searchText.lowercased()) {
                    filteredUsers.append(user)
                }
            }
            self.tableView.reloadData()
        }
    }

}



