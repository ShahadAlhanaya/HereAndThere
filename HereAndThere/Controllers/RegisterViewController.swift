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
        
        AuthenticaionModel.createAuthUser(email: email, password: password) {
        (authResult: Result<AuthDataResult, Error>) in
            switch authResult {
            case .success(let result):
                AuthenticaionModel.currentUserID = result.user.uid
                FirebaseModel.createFirestoreUser(firstName: firstName, lastName: lastName, email: email, uid: AuthenticaionModel.currentUserID) { (userCreateResult: Result<String, Error>) in
                    switch userCreateResult {
                    case .success(_):
                        self.uploadUserImage()
                        self.dismissRegister()
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
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
                default:
                    print("unknown error: \(err.localizedDescription)")
                }
                self.showError(errorStr)
                return
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
    
    func uploadUserImage(){
        FirebaseModel.uploadUserImage(userID: AuthenticaionModel.currentUserID, image: self.profileImageView.image!) {
            (imageUploadResult: Result<StorageMetadata, Error>) in
            switch imageUploadResult {
            case .success(let result):
                print("image saved: \(result)")
            case .failure(let error):
                print("error in uploading image: \(error)")
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

