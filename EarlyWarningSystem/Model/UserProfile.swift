//
//  UserList.swift
//  EarlyWarningSystem
//
//  Created by Junqing li on 12/24/18.
//  Copyright © 2018 Junqing li. All rights reserved.
//

import UIKit

class UserProfile{
    var userId: String
    var firstName: String
    var lastName: String
    var emailId: String
    var address: String
    var phoneNumber: String
    var password: String
    var photoImage: UIImage?
    var latitude: Double
    var longitude: Double
    
    
    init(userId: String, firstName: String,lastName: String,emailId: String, address: String, phoneNumber: String, password: String, photoImage: UIImage?,latitude: Double, longitude: Double){
        self.userId = userId
        self.firstName = firstName
        self.lastName = lastName
        self.emailId = emailId
        self.address = address
        self.phoneNumber = phoneNumber
        self.password = password
        self.photoImage = photoImage
        self.latitude = latitude
        self.longitude = longitude
       
    }
}

//class UserProfile{
//    var userId: String
//    var firstName: String
//    var lastName: String
//    var emailId: String
//    var address: String
//    var phoneNumber: String
//    var password: String
//    var photoImage: UIImage?
//    var latitude: Double
//    var longitude: Double
//
//
//    init(userId: String, firstName: String,lastName: String,emailId: String, address: String, phoneNumber: String, password: String, photoImage: UIImage?,latitude: Double, longitude: Double){
//        self.userId = userId
//        self.firstName = firstName
//        self.lastName = lastName
//        self.emailId = emailId
//        self.address = address
//        self.phoneNumber = phoneNumber
//        self.password = password
//        self.photoImage = photoImage
//        self.latitude = latitude
//        self.longitude = longitude
//
//    }
//}
