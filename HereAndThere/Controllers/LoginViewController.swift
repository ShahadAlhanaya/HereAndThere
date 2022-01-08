//
//  LoginViewController.swift
//  HereAndThere
//
//  Created by Shahad Nasser on 01/01/2022.
//

import UIKit
import Firebase
import FBSDKLoginKit

class LoginViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyUICustomization()

    }

    @IBAction func signInButtonPressed(_ sender: UIButton) {
        let error = validateFields()
        
        if error != nil {
            showError(error!)
        }else{
            errorLabel.isHidden = true
            handleLogin()
        }
    }
    
    
    
    @IBAction func joinUsButtonPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "RegisterVC")
        if var viewControllers = navigationController?.viewControllers {
            viewControllers[viewControllers.count - 1] = vc
            navigationController?.viewControllers = viewControllers
        }
    }
    
    @IBAction func facebookButtonPressed(_ sender: UIButton) {
        let fbLoginManager = FBSDKLoginKit.LoginManager()
        fbLoginManager.logIn(permissions: ["public_profile", "email"], from: self) { result, error in
            if let error = error {
                print(error)
            }else{
                
                guard let token = result?.token?.tokenString else{
                    print("noice: user failed to login")
                    return
                }
                
                let fackbookRequest  = FBSDKLoginKit.GraphRequest(graphPath: "me", parameters: ["fields":"email, first_name, last_name, picture"], tokenString: token, version: nil, httpMethod: .get)
                fackbookRequest.start { _, result, error in
                    guard let result = result as? [String: Any], error == nil else{
                        print("faild to make facebook graph request")
                        return
                    }
                    
                    print(result)
                    guard let firstName = result["first_name"] as? String,
                          let lastName = result["last_name"] as? String,
                          let id = result["id"] as? String,
                          let email = result["email"] as? String else {
                              print("failed to get email and name ")
                              return
                    }
                    var userProfileImage = ""
                    if let profilePicObj = result["picture"] as? [String:Any]{
                        if let profilePicData = profilePicObj["data"] as? [String:Any] {
                            if let profilePic = profilePicData["url"] as? String {
                                userProfileImage = profilePic
                            }
                        }
                    }
                    
                    let credential = FacebookAuthProvider.credential(withAccessToken: token)
                    
                    Auth.auth().signIn(with: credential, completion: {
                        authResult, error in
                        if let error = error {
                            print(error)
                            print("noice: facebook login failed")
                        }else{
                            print("noice: successfully user logged in")
                            Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid).setData([
                                "email": email,
                                "firstName": firstName,
                                "lastName": lastName,
                                "image": userProfileImage
                            ])
                            self.dismissLogin()
                        }
                    })
                    
                }
            }
        }
    }
    
    @IBAction func forgotPasswordButtonPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "Reset Password", message: "You will receive an email for resetting your password", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = self.emailTextField.text
            textField.placeholder = "Email address"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Send", style: .default, handler: {action in
            let email = alert.textFields![0].text ?? ""
            if email.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                Auth.auth().sendPasswordReset(withEmail: email) { error in
                    if let error = error {
                        print(error)
                    }
                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
      
    }
    
    
    
    func handleLogin(){
    
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        Auth.auth().signIn(withEmail: email, password: password) {
            result, error in
            if error != nil{
                self.showError(error!.localizedDescription)
            }else{
                self.dismissLogin()
            }
        }
    }
    
    func dismissLogin() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ChatVC")
        let myNavigationController = UINavigationController(rootViewController: vc)
        myNavigationController.modalPresentationStyle = .fullScreen
        present(myNavigationController, animated: true)
    }
    
    func validateFields()-> String?{
        
        if emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""
        {
            return "All Fields are required"
        }
        
//        let cleanedEmail = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
//        if Utilities.isValidPassword(cleanedEmail) == false {
//            return "Please enter a valid email"
//        }
        
//        let cleanedPassword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
//        if Utilities.isValidPassword(cleanedPassword) == false {
//            return "Password should be at least 8 characters, and contains 1 upper case letter, 1 lower case letter, 1 number, and 1 special character"
//        }
        
        return nil
    }
    
    func showError(_ error: String){
        errorLabel.text = error
        errorLabel.isHidden = false
        print("Error: \(error)")
    }
    
    func applyUICustomization(){
        customizedTextField(emailTextField)
        customizedTextField(passwordTextField)
    }

    func customizedTextField(_ textField: UITextField){
        textField.layer.cornerRadius = 20.0
        textField.borderStyle = .none
        textField.setLeftPaddingPoints(10)
        textField.setRightPaddingPoints(10)
        textField.layer.masksToBounds = true
    }

}
