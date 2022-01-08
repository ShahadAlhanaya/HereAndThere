//
//  ProfileImageCollectionViewCell.swift
//  HereAndThere
//
//  Created by Shahad Nasser on 08/01/2022.
//

import UIKit

class ProfileImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    
    var image = ""
    var delegate : ChooseProfileImageDelegate?

    
    func configure(){
        profileImageView.image = UIImage(named: image)
    }
    
    @IBAction func imagePressed(_ sender: UIButton) {
        delegate?.chooseImage(image: image)
    }
    
}
