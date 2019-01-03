//
//  UserListService.swift
//  EarlyWarningSystem
//
//  Created by Junqing li on 12/25/18.
//  Copyright © 2018 Junqing li. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage

class UserListService {
    static var currentUserList: [UserProfile]?
    static func getCurrentUid() -> String {
        return (Auth.auth().currentUser?.uid)!
    }
    
    static func fetchAllUsers(completion: @escaping (Any?) -> ()) {
         let userRef = Database.database().reference().child("User")
        print(userRef)
        print("observeFetchAlluSER*****")
        let fetchUserGroup = DispatchGroup()
        let fetchUserComponentsGroup = DispatchGroup()
        fetchUserGroup.enter()
        
        userRef.observeSingleEvent(of: .value) { (snapshot, error) in
            if error == nil {
                var userInfoArray : [UserProfile] = []
                
                if let users = snapshot.value as? [String:[String:Any]] {
                    for user in users {
                        let userProfile = UserProfile(userId: user.key,
                                                      firstName: (user.value["First Name"] as? String)!,
                                                      lastName: (user.value["Last Name"] as? String)!,
                                                      emailId: (user.value["Email"] as? String)!,
                                                      address: (user.value["Address"] as? String)!,
                                                       phoneNumber: (user.value["Phone Number"] as? String)!,
                                                       password: (user.value["Password"] as? String)!,
                                                       photoImage: nil,
                                                       latitude: (user.value["Latitude"] as? Double)!,
                                                       longitude: (user.value["Longitude"] as? Double)!)
                        fetchUserComponentsGroup.enter()
                        self.fetchAllUserImage(userID: user.key, completion: { (img, error) in
                            if error == nil && !(img == nil) {
                                print("**download user list image success!")
                               userProfile.photoImage = img as? UIImage
                            } else {
                                 print("**download user list image falied!")
                            }
                            if userProfile.userId != self.getCurrentUid() {
                                userInfoArray.append(userProfile)
                            }
                        
                            fetchUserComponentsGroup.leave()
                        })
                    }
                    fetchUserComponentsGroup.notify(queue: .main) {
                        fetchUserGroup.leave()
                    }
                    
                    fetchUserGroup.notify(queue: .main) {
                        // now the currentUser should be properly configured
                        completion(userInfoArray)
                    }
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    static func fetchAllUserImage(userID: String, completion: @escaping (Any?, Error?) -> ()) {
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
