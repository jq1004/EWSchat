//
//  FriendsController.swift
//  EarlyWarningSystem
//
//  Created by Junqing li on 12/24/18.
//  Copyright © 2018 Junqing li. All rights reserved.
//

import UIKit
import Firebase

class FriendsController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    
    var tableview: UITableView!
    var data = [UserProfile]()
    let userRef = Database.database().reference()
   
    fileprivate func observeFriendlist(){
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        let userFriendListRef = userRef.child("User").child(uid).child("Friends")
        
        userFriendListRef.observe(.childAdded, with: { (snapshot) in
        
          let friendId = snapshot.key
          let friendRef = self.userRef.child("User").child(friendId)

        
            friendRef.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dict = snapshot.value as? [String:AnyObject] else {
                    print("No friends!")
                    return
                }
                var userProfile: UserProfile?
                if  let firstname = dict["First Name"] as? String,
                    let lastname = dict["Last Name"] as? String,
                    let emailid = dict["Email"] as? String,
                    let address = dict["Address"] as? String,
                    let phonenumber = dict["Phone Number"] as? String,
                    let password = dict["Password"] as? String,
                    let latitude = dict["Latitude"] as? Double,
                    let longitude = dict["Longitude"] as? Double
                {
                    
                   userProfile = UserProfile(userId: snapshot.key, firstName: firstname, lastName: lastname, emailId: emailid, address: address, phoneNumber: phonenumber, password: password, photoImage: nil, latitude: latitude, longitude: longitude)
                    print("*******FriendsController - fetching profile data suceess")
                }
                
                let storageRef = Storage.storage().reference()
                let imageName = "UserImage/\(String(describing: snapshot.key)).jpeg"
                
                storageRef.child(imageName).getData(maxSize: 10*1024*1024) { (imgdata, error) in
                    if error == nil {
                       
                        userProfile?.photoImage = UIImage(data: imgdata!)
                        self.data.append(userProfile!)
                        DispatchQueue.main.async {
                            self.tableview.reloadData()
                                print("*start reloading Friendslist")
                            }
                        
                    } else {
                        print(error!)
                    }
                }
                
            }, withCancel: nil)
            
            
        }, withCancel: nil)
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableview = UITableView(frame: view.bounds, style: .plain)
        let cellNib = UINib(nibName: "FriendsListViewCell", bundle: nil)
        tableview.register(cellNib, forCellReuseIdentifier: "cell")
        view.addSubview(tableview)
        setupTableView()
        
        let showMapButtonItem = UIBarButtonItem(title: "", style: .done, target: self, action: #selector(showMap))
        let mapIcon: UIImage = UIImage(named: "map.png")!
        showMapButtonItem.setBackgroundImage(mapIcon, for: .normal, barMetrics: .default)
        self.navigationItem.rightBarButtonItem  = showMapButtonItem
        
        
        let logoutBarButtonItem = UIBarButtonItem(title: "", style: .done, target: self, action: #selector(logoutUser))
        let logoutIcon: UIImage = UIImage(named: "logout.png")!
        logoutBarButtonItem.setBackgroundImage(logoutIcon, for: .normal, barMetrics: .default)
        self.navigationItem.leftBarButtonItem = logoutBarButtonItem
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        } else {
            // Fallback on earlier versions
        }
        navigationItem.title = "My Friends"
        observeFriendlist()
    }
    
    @objc func showMap(){
        let s = ShowMapViewController()
        s.data = data
        self.navigationController?.pushViewController(s, animated: true)
    }
    
    @objc func logoutUser(){
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        dismiss(animated: true, completion: nil)
        let loginController = LoginController()
        present(loginController, animated: true, completion: nil)
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FriendsListViewCell
        cell.set(user: data[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let chatVC = ChatViewController()
        chatVC.userProfile = data[indexPath.row]
        navigationController?.pushViewController(chatVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if(editingStyle == .delete){
            let userFriendListRef = userRef.child("User").child((Auth.auth().currentUser?.uid)!).child("Friends")
             userFriendListRef.child(data[indexPath.row].userId).removeValue()
            data.remove(at: indexPath.item)
            tableview.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func setupTableView(){
        tableview.translatesAutoresizingMaskIntoConstraints = false
        tableview.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        tableview.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        tableview.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        tableview.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        
        tableview.delegate = self
        tableview.dataSource = self
        tableview.tableFooterView = UIView()
        tableview.reloadData()
    }
    
    
}
