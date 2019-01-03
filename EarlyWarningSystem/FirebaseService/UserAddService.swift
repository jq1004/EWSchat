//
//  UserAddService.swift
//  EarlyWarningSystem
//
//  Created by Junqing li on 12/25/18.
//  Copyright © 2018 Junqing li. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage

class UserAddService {
    
    static func getCurrentUid() -> String {
        return (Auth.auth().currentUser?.uid)!
    }
    
    static func addToFriendList(friendId: String, completion: @escaping (Any?) -> ()){
            
        Database.database().reference().child("User").child(getCurrentUid()).child("Friends").updateChildValues([friendId: "Friend ID"]) {
            (error, ref) in
            
                if error == nil {
                    completion(ref)
                }
                else{
                    completion(error)
                }
        }
    }
    
}
