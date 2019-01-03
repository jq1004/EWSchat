//
//  UserListController.swift
//  EarlyWarningSystem
//
//  Created by Junqing li on 12/24/18.
//  Copyright © 2018 Junqing li. All rights reserved.
//

import UIKit
import Firebase

class UserListController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    var data = [UserProfile]()
    
    var tableview: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableview = UITableView(frame: view.bounds, style: .plain)
        setupTableView()
        
        let cellNib = UINib(nibName: "UserListViewCell", bundle: nil)
        tableview.register(cellNib, forCellReuseIdentifier: "userCell")
        
        let logoutBarButtonItem = UIBarButtonItem(title: "", style: .done, target: self, action: #selector(logoutUser))
        let logoutIcon: UIImage = UIImage(named: "logout.png")!
        logoutBarButtonItem.setBackgroundImage(logoutIcon, for: .normal, barMetrics: .default)
        self.navigationItem.leftBarButtonItem  = logoutBarButtonItem
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "User List"
        
        if let currentUserList = UserListService.currentUserList{
            data = currentUserList
            tableview.reloadData()
        }
       
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserListViewCell
        cell.set(user: data[indexPath.row])
        cell.userID = data[indexPath.row].userId
        return cell
    }
    
    
    func setupTableView(){
        view.addSubview(tableview)
        
        tableview.translatesAutoresizingMaskIntoConstraints = false
        tableview.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        tableview.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        tableview.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        tableview.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        
        tableview.delegate = self
        tableview.dataSource = self
        tableview.tableFooterView = UIView()
    }
    
}
