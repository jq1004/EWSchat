//
//  UserService.swift
//  EarlyWarningSystem
//
//  Created by Junqing li on 12/24/18.
//  Copyright © 2018 Junqing li. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage

class UseProfileServiceNoUse{
    static var currentUserProfile: UserProfile?
    
    static func getCurrentUid() -> String {
        return (Auth.auth().currentUser?.uid)!
    }
    
    static func observeUserProfile(_ uid:String, completion: @escaping ((_ userProfile: UserProfile?)->())){
        
         let userRef = Database.database().reference().child("User").child(uid)
        
         print("*******Start User Profile Service")
        
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            var userProfile: UserProfile?
            
            if let dict = snapshot.value as? [String:Any],
                let firstname = dict["First Name"] as? String,
                let lastname = dict["Last Name"] as? String,
                let emailid = dict["Email"] as? String,
                let address = dict["Address"] as? String,
                let phonenumber = dict["Phone Number"] as? String,
                let password = dict["Password"] as? String,
                let latitude = dict["Latitude"] as? Double,
                let longitude = dict["Longitude"] as? Double
            {
                
                userProfile = UserProfile(userId: snapshot.key, firstName: firstname, lastName: lastname, emailId: emailid, address: address, phoneNumber: phonenumber, password: password, photoImage: nil, latitude: latitude, longitude: longitude)
                 print("*******Start User Profile Service - fetching profile data suceess")
            }
            
            self.fetchUserImage(userID: snapshot.key, completion: { (img, error) in
                if error == nil && !(img == nil) {
                     print("*******Start User Profile Service - fetching image success")
                    userProfile?.photoImage = img as? UIImage
                } else {
                     print("*******Start User Profile Service - fetching image fail")
                }

            })
            completion(userProfile)
            
            
        }, withCancel: nil)
        
    }
    
    static func fetchUserImage(userID: String, completion: @escaping (Any?, Error?) -> ()) {
        
        let storageRef = Storage.storage().reference()
        
        let imageName = "UserImage/\(String(describing: userID)).jpeg"
        
        storageRef.child(imageName).getData(maxSize: 10*1024*1024) { (data, error) in
            if error == nil {
                let image = UIImage(data: data!)
                
                completion(image, nil)
            } else {
               
                completion(nil, error)
            }
            
        }
    }
    
    
}
