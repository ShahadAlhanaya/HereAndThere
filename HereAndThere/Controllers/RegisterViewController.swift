//
//  RegisterViewController.swift
//  HereAndThere
//
//  Created by Shahad Nasser on 01/01/2022.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController, UINavigationControllerDelegate {
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    
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
    
    @IBAction func profileImageButtonPressed(_ sender: UIButton) {
        
        presentPhotoActionSheet()
    }
    
    @IBAction func signInButtonPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LoginVC")
        if var viewControllers = navigationController?.viewControllers {
            viewControllers[viewControllers.count - 1] = vc
            navigationController?.viewControllers = viewControllers
        }
    }
    
    
    
    func handleRegister(){
        
        let firstName = firstNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let lastName = lastNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        
        Auth.auth().createUser(withEmail: email, password: password) {
            result, error in
            
            var errorStr = "something went wrong"
            if let x = error {
                let err = x as NSError
                switch err.code {
                     case AuthErrorCode.wrongPassword.rawValue:
                        errorStr = "invalid credentials"
                     case AuthErrorCode.invalidEmail.rawValue:
                        errorStr = "invalid credentials"
                     case AuthErrorCode.accountExistsWithDifferentCredential.rawValue:
                        errorStr = "invalid credentials"
                     case AuthErrorCode.emailAlreadyInUse.rawValue:
                        errorStr = "email is alreay in use"
                     default:
                        print("unknown error: \(err.localizedDescription)")
                     }
                self.showError(errorStr)
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
                    self.uploadUserImage(uid: uid, fileName: "\(uid)\(Date().timeIntervalSince1970)")
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
    
    func uploadUserImage(uid: String, fileName: String){
        var imageURL = ""
        let storageRef = Storage.storage().reference().child("\(fileName).png")
        if let uploadData = self.profileImageView.image?.jpegData(compressionQuality: 0.5){
            storageRef.putData(uploadData, metadata: nil){
                (metadata, error) in
                if let error = error {
                    print("error \(error)")
                }else{
                    storageRef.downloadURL { url, error in
                        imageURL = url!.absoluteString
                        Firestore.firestore().collection("users").document(uid).updateData([
                            "image": imageURL,
                        ]){ error in
                            if let error = error {
                                print("error: \(error)")
                            }
                        }
                    }
                }
            }
        }
    }
    
    func validateFields()-> String?{
        
        if firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""
        {
            return "All Fields are required"
        }
        
        let cleanedEmail = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if Utilities.isValidEmail(cleanedEmail) == false {
            return "Please enter a valid email address"
        }
        
        let cleanedPassword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if Utilities.isValidPassword(cleanedPassword) == false {
            return "Password should be at least 8 characters and contains: \n1 upper case letter \n1 lower case letter \n1 number"
        }
        
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
extension RegisterViewController: UIImagePickerControllerDelegate {
  
    func presentPhotoActionSheet(){
        print("hey!")
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        vc.modalPresentationStyle = .fullScreen
        present(vc,animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print(info)
        picker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {return}
        self.profileImageView.image = selectedImage
        
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
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
