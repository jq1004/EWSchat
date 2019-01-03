//
//  MainTabController.swift
//  EarlyWarningSystem
//
//  Created by Junqing li on 12/23/18.
//  Copyright © 2018 Junqing li. All rights reserved.
//

import UIKit
import Firebase
class MainTabController : UITabBarController{
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        print("*******Trigger User List Service!")
        UserListService.fetchAllUsers(completion: { (userInfoArray) in
            UserListService.currentUserList = (userInfoArray as? [UserProfile])

                        })
        
        tabBar.barTintColor = UIColor(red: 38/255, green: 196/255, blue: 133/255, alpha: 1)
        
        setupTabbar()
    }
   
    
    func setupTabbar(){
       
        let weatherController = UINavigationController(rootViewController: WeatherController())
        weatherController.tabBarItem.image = UIImage(named: "home_unselected")
        weatherController.tabBarItem.selectedImage = UIImage(named: "home_selected")
        
        let layout = UICollectionViewFlowLayout()
        let postListController = UINavigationController(rootViewController: PostListController(collectionViewLayout: layout))
        postListController.tabBarItem.image = UIImage(named: "reports_unselected")
        postListController.tabBarItem.selectedImage = UIImage(named: "reports_selected")

        let userListController = UINavigationController(rootViewController: UserListController())
        userListController.tabBarItem.image = UIImage(named: "userlist_unselected")
        userListController.tabBarItem.selectedImage = UIImage(named: "userlist_selected")

        let friendsController = UINavigationController(rootViewController: FriendsController())
        friendsController.tabBarItem.image = UIImage(named: "myfriends_unselected")
        friendsController.tabBarItem.selectedImage = UIImage(named: "myfriends_selected")
        
        let settingController = UINavigationController(rootViewController: SettingController())
        settingController.tabBarItem.image = UIImage(named: "setting")
        settingController.tabBarItem.selectedImage = UIImage(named: "setting")
        viewControllers = [weatherController,postListController,userListController, friendsController,settingController]
        
        guard let items = tabBar.items else {return}
        
        for item in items{
            item.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
        }
    }
    
}
