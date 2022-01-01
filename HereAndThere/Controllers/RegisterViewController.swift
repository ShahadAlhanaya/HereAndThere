//
//  RegisterViewController.swift
//  HereAndThere
//
//  Created by Shahad Nasser on 01/01/2022.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyUICustomization()
    }

    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        let error = validateFields()
        
        if error != nil {
            showError(error!)
        }else{
            errorLabel.isHidden = true
            handleRegister()
        }
    }
    
    func handleRegister(){
        
        let firstName = firstNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let lastName = lastNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        Auth.auth().createUser(withEmail: email, password: password) {
            result, error in
            
            if error != nil{
                print("error \(error)")
                return
            }
            guard let uid = result?.user.uid else { return }
            Firestore.firestore().collection("users").document(uid).setData([
                "firstName": firstName,
                "lastName": lastName,
                "email": email,
            ]){ error in
                if let error = error {
                    print("error \(error)")
                } else {
                    print("user created")
                    self.dismissRegister()
                }
            }
        }
    }
    
    func dismissRegister() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ChatVC")
        let myNavigationController = UINavigationController(rootViewController: vc)
        myNavigationController.modalPresentationStyle = .fullScreen
        present(myNavigationController, animated: true)
    }
    
    func validateFields()-> String?{
        
        if firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""
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
        customizedTextField(firstNameTextField)
        customizedTextField(lastNameTextField)
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

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
