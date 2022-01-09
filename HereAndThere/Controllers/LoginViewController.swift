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
        faceBookSignIn()
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
                AuthenticaionModel.resetPassword(email: email) { (resetResult: Result<Bool, Error>) in
                    switch resetResult {
                    case .success(_):
                        print("reset password email sent")
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func handleLogin(){
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        AuthenticaionModel.logIn(email: email, password: password) {
            (authResult: Result<AuthDataResult, Error>) in
            switch authResult {
            case .failure(let error):
                var errorStr = "something went wrong"
                let err = error as NSError
                switch err.code {
                     case AuthErrorCode.wrongPassword.rawValue:
                        errorStr = "invalid credentials"
                     case AuthErrorCode.invalidEmail.rawValue:
                        errorStr = "invalid credentials"
                     case AuthErrorCode.accountExistsWithDifferentCredential.rawValue:
                        errorStr = "invalid credentials"
                     case AuthErrorCode.emailAlreadyInUse.rawValue:
                        errorStr = "email is alreay in use"
                    case AuthErrorCode.userNotFound.rawValue:
                        errorStr = "user not found"
                     default:
                        print("unknown error: \(err.localizedDescription)")
                     }
                self.showError(errorStr)
            case .success(_):
                self.dismissLogin()
            }
        }
    }
    
    func faceBookSignIn(){
                let fbLoginManager = FBSDKLoginKit.LoginManager()
                fbLoginManager.logIn(permissions: ["public_profile", "email"], from: self) { result, error in
                    if let error = error {
                        print(error)
                    }else{
        
                        guard let token = result?.token?.tokenString else{
                            print("user failed to login")
                            return
                        }
        
                        let fackbookRequest  = FBSDKLoginKit.GraphRequest(graphPath: "me", parameters: ["fields":"email, first_name, last_name, picture.type(large)"], tokenString: token, version: nil, httpMethod: .get)
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
        
                            AuthenticaionModel.logIn(credentials: credential) {
                            (result: Result<AuthDataResult, Error>) in
                                switch result {
                                case .failure(let error):
                                    print("facebook login failed")
                                    print(error.localizedDescription)
                                case .success(let result):
                                    print("successfully user logged in")
                                    FirebaseModel.saveFacebookUser(firstName: firstName, lastName: lastName, email: email, uid: result.user.uid, image: userProfileImage) { (result: Result<String, Error>) in
                                        if let error = error {
                                            print(error.localizedDescription)
                                        }else{
                                            self.dismissLogin()
                                        }
                                    }
                                }
                            }
                        }
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
