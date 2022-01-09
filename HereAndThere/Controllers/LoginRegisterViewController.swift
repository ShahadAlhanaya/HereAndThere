//
//  LoginViewController.swift
//  HereAndThere
//
//  Created by Shahad Nasser on 01/01/2022.
//

import UIKit

class LoginRegisterViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func registerButtonPressed(_ sender: UIButton) {
        print("register!")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "RegisterVC")
        let myNavigationController = UINavigationController(rootViewController: vc)
        present(myNavigationController, animated: true)
    }
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        print("login!")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LoginVC")
        let myNavigationController = UINavigationController(rootViewController: vc)
        present(myNavigationController, animated: true)
    }
}
