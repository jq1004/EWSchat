//
//  ChatViewController.swift
//  EarlyWarningSystem
//
//  Created by Junqing li on 12/28/18.
//  Copyright © 2018 Junqing li. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class ChatViewController: UIViewController, UITextFieldDelegate{
    
    let userRef = Database.database().reference()
    let cellId = "cellId"

    var userProfile: UserProfile? {
        didSet {
            navigationItem.title = userProfile?.firstName
            
            observeMessage()
        }
    }
    var messages = [Message]()
    var groupMessages = [[Message]]()
    
    fileprivate func observeMessage(){
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        let userMessageRef = userRef.child("user_messages").child(uid)
        userMessageRef.observe(.childAdded, with: { (snapshot) in
            
            let messageId = snapshot.key
            let messageRef = self.userRef.child("messages").child(messageId)
            
            messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String:AnyObject] else {
                    return
                }
                
                var groupMessagesTemp = [[Message]]()
                let message = Message()
                
                message.text = dictionary["text"] as? String
                message.fromId = dictionary["fromId"] as? String
                message.toId = dictionary["toId"] as? String
                
                let seconds = dictionary["timestamp"]?.doubleValue
                let timestampDate = NSDate(timeIntervalSince1970: seconds!)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/yyyy hh:mm a"
                message.dateStr = dateFormatter.string(from: timestampDate as Date)
                
                if message.chatPartnerId() == self.userProfile?.userId {
                    self.messages.append(message)
                    
                    // grouping by Date
                    let dictMessages = Dictionary(grouping: self.messages, by: { (element) -> String in
                        return element.dateStr!
                    })
                    let sortedKeys = dictMessages.keys.sorted()
                    sortedKeys.forEach({ (key) in
                        let values = dictMessages[key]
                        groupMessagesTemp.append(values ?? [])
                    })
                    
                    self.groupMessages = groupMessagesTemp
                    
                    DispatchQueue.main.async {
                        self.newTable.reloadData()
                        print("*start reloadingData")
                    }
                }
                
            }, withCancel: nil)
            
        }, withCancel: nil)
    }
    
    lazy var newTable: UITableView = {
        let table = UITableView()
        table.separatorStyle = .none
        table.backgroundColor = UIColor(white: 0.95, alpha: 1)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(ChatMessageCell.self, forCellReuseIdentifier: cellId)
        return table
    }()
    
    lazy var inputTextField :UITextField = {
        let i = UITextField()
        i.placeholder = "Please type message .."
        i.translatesAutoresizingMaskIntoConstraints = false
        i.delegate = self
        return i
    }()
    
    fileprivate func setupTableView(){
//        view.insertSubview(newTable, at: 0)
        view.addSubview(newTable)
        newTable.separatorStyle = .none
        newTable.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        newTable.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        newTable.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        newTable.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        newTable.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100).isActive = true
        newTable.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupInputField()
//        view.backgroundColor = .white
        newTable.dataSource = self
        newTable.delegate = self
        newTable.tableFooterView = UIView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    var bottomConstraint: NSLayoutConstraint?
    
    @objc func handleKeyboardNotification(notification: NSNotification){
        if let userInfo = notification.userInfo{
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
            
            bottomConstraint?.constant = isKeyboardShowing ? -keyboardFrame.height : 0
            if isKeyboardShowing {
            let indexPath = NSIndexPath(row: self.groupMessages[self.groupMessages.count-1].count-1, section: self.groupMessages.count-1)
                self.newTable.scrollToRow(at: indexPath as IndexPath, at: .bottom, animated: true)}
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        inputTextField.endEditing(true)
    }
   
    
    func setupInputField(){
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .white
        view.addSubview(containerView)
       
        bottomConstraint = NSLayoutConstraint(item: containerView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        view.addConstraint(bottomConstraint!)
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        containerView.addSubview(sendButton)
        
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        
        containerView.addSubview(inputTextField)
        inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        let seperatorLineView = UIView()
        seperatorLineView.backgroundColor = .gray
        seperatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(seperatorLineView)
        // x y w h
        seperatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        seperatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        seperatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        seperatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    @objc func handleSend(){
        guard let inputText = inputTextField.text else{return}
        if inputText == "" {return}
        let rf = userRef.child("messages").childByAutoId()
        let fromId = Auth.auth().currentUser?.uid
        let toId = userProfile?.userId
        let timestamp = Int(NSDate().timeIntervalSince1970)
        let values = ["text": inputText, "toId": toId!, "fromId": fromId!, "timestamp": timestamp] as [String : Any]
        rf.updateChildValues(values)
        
        inputTextField.text = ""
        guard let messageId = rf.key else { return }
        guard let fromid = fromId else {return}
        let userMessagesRef = self.userRef.child("user_messages").child(fromid)
        let v1 = [messageId:1]
        userMessagesRef.updateChildValues(v1)
        
        guard let toid = toId else {return}
        let recipientMessagesRef = self.userRef.child("user_messages").child(toid)
        let v2 = [messageId:1]
        recipientMessagesRef.updateChildValues(v2)
    }
    
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
//        return true
//    }
    
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return groupMessages.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupMessages[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = newTable.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatMessageCell
        cell.message = groupMessages[indexPath.section][indexPath.row]
        return cell
    }
    
    class HeaderLabel: UILabel{
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            backgroundColor = .gray
            textColor = .white
            textAlignment = .center
            font = UIFont.boldSystemFont(ofSize: 14)
            translatesAutoresizingMaskIntoConstraints = false
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override var intrinsicContentSize: CGSize{
            let originalContentSize = super.intrinsicContentSize
            let height = originalContentSize.height + 12
            layer.cornerRadius = height / 2
            layer.masksToBounds = true
            return CGSize(width: originalContentSize.width + 16, height: height)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if let firstMessageSection = groupMessages[section].first {
            let label = HeaderLabel()
            label.text = firstMessageSection.dateStr
            
            let containerView = UIView()
            
            containerView.addSubview(label)
            label.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
            return containerView
                }
            return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }

}
