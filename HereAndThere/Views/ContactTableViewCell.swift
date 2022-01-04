//
//  ContactsTableViewCell.swift
//  HereAndThere
//
//  Created by Shahad Nasser on 04/01/2022.
//

import UIKit

class ContactTableViewCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var messageButton: UIButton!
    
    
    func configure(user: User){
        userNameLabel.text = user.name
        emailLabel.text = user.email
        profileImageView.image = UIImage(named: "empty_profile")
        let image = user.image
        if image.trimmingCharacters(in: .whitespaces) != "" {
            profileImageView.sd_setImage(with: URL(string: image))
        }
    }
}
