//
//  ChatMessageCell.swift
//  EarlyWarningSystem
//
//  Created by Junqing li on 12/28/18.
//  Copyright © 2018 Junqing li. All rights reserved.
//

import UIKit
import Firebase

class ChatMessageCell: UITableViewCell {
    
    var leadingConstraint: NSLayoutConstraint!
    var trailingConstraint: NSLayoutConstraint!
    
    var message: Message!{
        didSet{
            bubbleView.backgroundColor = message.fromId == Auth.auth().currentUser?.uid ? .green : .white
            messageLabel.text = message.text
            if Auth.auth().currentUser?.uid == message.fromId {
                leadingConstraint.isActive = false
                trailingConstraint.isActive = true
            }else{
                leadingConstraint.isActive = true
                trailingConstraint.isActive = false
            }
        }
    }
    
    var isIncoming: Bool!{
        didSet{
            bubbleView.backgroundColor = isIncoming ? .white : .green
        }
    }
    
    let messageLabel: UILabel = {
        let m = UILabel()
        m.translatesAutoresizingMaskIntoConstraints = false
        m.numberOfLines = 0
        return m
    }()
    
    let bubbleView: UIView = {
       let b = UIView()
       b.backgroundColor = .yellow
       b.layer.cornerRadius = 10
       b.translatesAutoresizingMaskIntoConstraints = false
       return b
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(bubbleView)
        addSubview(messageLabel)
        backgroundColor = .clear
        
        
        let constraints = [messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
        messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -32),
        messageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 250)]

        NSLayoutConstraint.activate(constraints)
        
        bubbleView.topAnchor.constraint(equalTo: messageLabel.topAnchor, constant: -16).isActive = true
        bubbleView.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor, constant:-16).isActive = true
        bubbleView.bottomAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 16).isActive = true
        bubbleView.trailingAnchor.constraint(equalTo: messageLabel.trailingAnchor, constant: 16).isActive = true
        
        leadingConstraint = messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant:32)
        leadingConstraint.isActive = false
        
        trailingConstraint = messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32)
        trailingConstraint.isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
