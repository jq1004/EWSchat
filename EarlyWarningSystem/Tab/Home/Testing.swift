//
//  Testing.swift
//  EarlyWarningSystem
//
//  Created by Junqing li on 12/30/18.
//  Copyright © 2018 Junqing li. All rights reserved.
//

import Foundation
import UIKit

class Testing : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let cityLabel: UILabel = {
        let c = UILabel()
        c.text = "Saint Charles"
        c.font=UIFont.boldSystemFont(ofSize: 28)
        c.textColor = UIColor.white
//        c.backgroundColor = UIColor.white
        c.textAlignment = .center
        c.translatesAutoresizingMaskIntoConstraints=false
        return c
    }()
    
    let tableView : UITableView = {
        let t = UITableView()
        
        t.translatesAutoresizingMaskIntoConstraints = false
        return t
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set a background color so we can easily see the table
        self.view.backgroundColor = UIColor.blue
        
        // add the table view to self.view
        self.view.addSubview(tableView)
        
        // constrain the table view to 120-pts on the top,
        //  32-pts on left, right and bottom (just to demonstrate size/position)
        
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 32.0).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 250.0).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -32.0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -32.0).isActive = true
        
        // set delegate and datasource
        tableView.delegate = self
        tableView.dataSource = self
        
        // register a defalut cell
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        view.addSubview(cityLabel)
        cityLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        cityLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 50).isActive = true
        
        cityLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -50).isActive = true
        cityLabel.heightAnchor.constraint(equalToConstant: 35).isActive = true
    }
    
    // Note: because this is NOT a subclassed UITableViewController,
    // DataSource and Delegate functions are NOT overridden
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 25
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = "\(indexPath)"
        
        return cell
    }
    
    // MARK: - Table view delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // etc
    }
}
