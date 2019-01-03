//
//  Message.swift
//  EarlyWarningSystem
//
//  Created by Junqing li on 12/31/18.
//  Copyright © 2018 Junqing li. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {
    
    var fromId: String?
    var text: String?
    var dateStr: String?
    var toId: String?
    
    func chatPartnerId() -> String? {
        if fromId == Auth.auth().currentUser?.uid {
            return toId
        }
        else {
            return fromId
        }
    }
    
}
