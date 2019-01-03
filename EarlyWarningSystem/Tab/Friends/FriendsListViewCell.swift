//
//  FriendsListViewCell.swift
//  EarlyWarningSystem
//
//  Created by Junqing li on 12/25/18.
//  Copyright © 2018 Junqing li. All rights reserved.
//

import UIKit
import Firebase

class FriendsListViewCell: UITableViewCell {

    let userRef = Database.database().reference()
    @IBOutlet weak var lastNamelbl: UILabel!
    @IBOutlet weak var firstNamelbl: UILabel!
    @IBOutlet weak var profileImgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImgView.layer.cornerRadius = profileImgView.bounds.height/2
        profileImgView.clipsToBounds = true
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func set(user: UserProfile){
        profileImgView.image = user.photoImage
        
        firstNamelbl.text = user.firstName
        lastNamelbl.text = user.lastName
    }
    
}
