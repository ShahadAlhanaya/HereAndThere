//
//  ContactsTableViewCell.swift
//  HereAndThere
//
//  Created by Shahad Nasser on 04/01/2022.
//

import UIKit

class ContactTableViewCell: UITableViewCell {
    
    var openChatDelegate: OpenChatDelegate?
    
    var user: User?
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    func configure(){
        userNameLabel.text = user!.name
        emailLabel.text = user!.email
        profileImageView.image = UIImage(named: "empty_profile")
        let image = user!.image
        if image.trimmingCharacters(in: .whitespaces) != "" {
            profileImageView.sd_setImage(with: URL(string: image))
        }
    }
    
    @IBAction func messageButtonPressed(_ sender: UIButton) {
        openChatDelegate?.openChat(with: user!)
    }
    
}
