//
//  ViewController.swift
//  HereAndThere
//
//  Created by Shahad Nasser on 01/01/2022.
//

import UIKit
import Firebase

class ViewController: UIViewController{

    @IBOutlet weak var tableView: UITableView!
    
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
            let uid = Auth.auth().currentUser?.uid
            Firestore.firestore().collection("users").document(uid!).getDocument { document, error in
                if let document = document, document.exists {
                    let data = document.data()
                    self.title = data?["firstName"] as? String ?? " "
                } else {
                    print("Document does not exist")
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
//        self.navigationController!.pushViewController(vc, animated: true)
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
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell")!
        cell.textLabel?.text = "hey"
        return cell
    }
    
    
}

