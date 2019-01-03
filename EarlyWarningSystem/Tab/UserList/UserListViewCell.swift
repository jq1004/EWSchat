//
//  UserListViewCell.swift
//  EarlyWarningSystem
//
//  Created by Junqing li on 12/25/18.
//  Copyright © 2018 Junqing li. All rights reserved.
//

import UIKit

class UserListViewCell: UITableViewCell {

    @IBOutlet weak var profileImgview: UIImageView!
    
    @IBOutlet weak var lastnameLbl: UILabel!
    
    @IBOutlet weak var firstnameLbl: UILabel!
    
    var userID: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profileImgview.layer.cornerRadius = profileImgview.bounds.height/2
        profileImgview.clipsToBounds = true
    }

    
    @IBAction func addFriendBtn(_ sender: UIButton) {
//        print("add button! \(String(describing: userID))")
        UserAddService.addToFriendList(friendId: userID!) { (ref) in
            if ref == nil {
                print("add friend failed!")
            }
            else{
                print("add friend success!")
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func set(user: UserProfile){
        if user.photoImage != nil {
            profileImgview.image = user.photoImage
        } else {
            profileImgview.image = UIImage(named: "empty-image")
        }
        
        
        firstnameLbl.text = user.firstName
        lastnameLbl.text = user.lastName
    }
    
}
