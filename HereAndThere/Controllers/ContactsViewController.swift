//
//  ContactsViewController.swift
//  HereAndThere
//
//  Created by Shahad Nasser on 02/01/2022.
//

import UIKit
import Firebase

class ContactsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    var users = [User]()
    var filteredUsers = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeBackButton()
        fetchUsers()
        
        
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
                    let data = document.data()
                    let id = document.documentID
                    if(id == Auth.auth().currentUser?.uid){
                        continue
                    }
                    let firstName = data["firstName"] as? String ?? ""
                    let lastName = data["lastName"] as? String ?? ""
                    let email = data["email"] as? String ?? ""
                        self.users.append(User(id: id, firstName: firstName, lastName: lastName, email: email))
                }
                self.filteredUsers = self.users
                self.tableView.reloadData()
            }
    }
    
    func customizeBackButton(){
        let imgBack = UIImage(named: "ic_back")
        navigationController?.navigationBar.backIndicatorImage = imgBack
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = imgBack
        navigationItem.leftItemsSupplementBackButton = true
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
    }

}

extension ContactsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell")!
//        cell.textLabel?.text = "\(users[indexPath.row].firstName!) \(users[indexPath.row].lastName!)"
        cell.textLabel?.text = filteredUsers[indexPath.row].name
        return cell
    }
    
    
}

extension ContactsViewController: UISearchBarDelegate {
 
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        filteredUsers = []
        
        if searchText == "" {
            filteredUsers = users
        }else{
            for user in users {
                if user.name.lowercased().contains(searchText.lowercased()) {
                    filteredUsers.append(user)
                }
            }
            self.tableView.reloadData()
        }
    }
}

