//
//  ProfileViewController.swift
//  HereAndThere
//
//  Created by Shahad Nasser on 08/01/2022.
//

import UIKit
import FBSDKLoginKit
import Firebase

class ProfileViewController: UIViewController, UINavigationControllerDelegate, ChooseProfileImageDelegate {

    @IBOutlet weak var userProfileImage: UIImageView!
    
    @IBOutlet weak var userProfileButton: UIButton!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var profileImagesCollectionView: UICollectionView!
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var logoutButton: UIButton!
    
    let images = [
        "profile1",
        "profile2",
        "profile3",
        "profile4",
        "profile5",
        "profile6",
        "profile7",
        "profile8",
        "profile9",
        "profile10",
        "profile11",
        "profile12"
    ]
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyUICustomization()
        profileImagesCollectionView.dataSource = self
        
        setUserInfo()
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        uploadUserImage(uid: user!.id!)
        updateUserData()
    }
    
    @IBAction func logoutButtonPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "Logout", message: "Are you sure want to log out from your account?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Logout", style: .default, handler: {action in
            self.handleLogout()

        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func imageButtonPressed(_ sender: UIButton) {
        presentPhotoActionSheet()
    }
    
    func updateUserData(){
        if let firstName = firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), let lastName = lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            Firestore.firestore().collection("users").document(user!.id!).updateData([
                "firstName": firstName,
                "lastName": lastName,
            ])
        }
    }
    
    func uploadUserImage(uid: String){
        var imageURL = ""
        let storageRef = Storage.storage().reference().child("\(uid).png")
        if let uploadData = self.userProfileImage.image?.jpegData(compressionQuality: 0.5){
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
    
    
    func setUserInfo(){
        if user != nil {
            firstNameTextField.text = user?.firstName
            lastNameTextField.text = user?.lastName
            emailTextField.text = user?.email
            emailTextField.textColor = UIColor(named: "ACAI_BERRY_50")
            userProfileImage.sd_setImage(with: URL(string: user!.image))
        }
        if let token = AccessToken.current, !token.isExpired {
            firstNameTextField.isUserInteractionEnabled = false
            lastNameTextField.isUserInteractionEnabled = false
            userProfileButton.isUserInteractionEnabled = false
            userProfileButton.isHidden = true
            profileImagesCollectionView.isHidden = true
            saveButton.isHidden = true
            
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
    
    func chooseImage(image: String) {
        userProfileImage.image = UIImage(named: image)
    }
    
    func applyUICustomization(){
        customizedTextField(firstNameTextField)
        customizedTextField(lastNameTextField)
        customizedTextField(emailTextField)
        emailTextField.isUserInteractionEnabled = false
    }

    func customizedTextField(_ textField: UITextField){
        textField.layer.cornerRadius = 20.0
        textField.borderStyle = .none
        textField.setLeftPaddingPoints(10)
        textField.setRightPaddingPoints(10)
        textField.layer.masksToBounds = true
    }
    
}

extension ProfileViewController:  UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileImageCell", for: indexPath as IndexPath) as! ProfileImageCollectionViewCell
        cell.image = images[indexPath.row]
        cell.delegate = self
        cell.configure()
        return cell
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate {
  
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
        self.userProfileImage.image = selectedImage
        
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

}
