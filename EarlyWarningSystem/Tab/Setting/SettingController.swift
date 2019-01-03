//
//  SettingController.swift
//  EarlyWarningSystem
//
//  Created by Junqing li on 12/23/18.
//  Copyright © 2018 Junqing li. All rights reserved.
//

import UIKit
import Firebase

class SettingController: UIViewController{
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setUpbackgroundImageView()
        
        setupEditProfileBtn()
        
        let logoutBarButtonItem = UIBarButtonItem(title: "", style: .done, target: self, action: #selector(logoutUser))
        let logoutIcon: UIImage = UIImage(named: "logout.png")!
        logoutBarButtonItem.setBackgroundImage(logoutIcon, for: .normal, barMetrics: .default)
        self.navigationItem.leftBarButtonItem  = logoutBarButtonItem
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        } else {
            // Fallback on earlier versions
        }
        navigationItem.title = "Setting"
        
        setupEditProfileBtn()
        setupResetPasswordBtn()
    }
    
    let backgroundImage: UIImageView = {
        let b = UIImageView(frame: UIScreen.main.bounds)
        b.image = UIImage(named: "login.png")
        b.contentMode = UIView.ContentMode.scaleAspectFill
        return b
    }()
    
    let editProfileBtn: UIButton = {
        let r = UIButton()
        var attributedString = NSMutableAttributedString(string: "Edit Profile", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 18),NSAttributedString.Key.foregroundColor: UIColor.white])
        r.setAttributedTitle(attributedString, for: .normal)
        r.layer.cornerRadius = 10
        r.layer.borderWidth = 1
        r.layer.borderColor = UIColor(red: 255/255, green: 151/255, blue: 164/255, alpha: 1).cgColor
        r.addTarget(self, action: #selector(editProfile), for: .touchUpInside)
        return r
    }()
    
    @objc func editProfile(){
        let editProfileController = EditProfileController()
        navigationController?.pushViewController(editProfileController, animated: true)
    }
    
    let resetPasswordBtn: UIButton = {
        let r = UIButton()
        var attributedString = NSMutableAttributedString(string: "Change Password", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 18),NSAttributedString.Key.foregroundColor: UIColor.white])
        r.setAttributedTitle(attributedString, for: .normal)
        r.layer.cornerRadius = 10
        r.layer.borderWidth = 1
        r.layer.borderColor = UIColor(red: 255/255, green: 151/255, blue: 164/255, alpha: 1).cgColor
        r.addTarget(self, action: #selector(resetPassword), for: .touchUpInside)
        return r
    }()
    
    @objc func resetPassword(){
        
        let resetPasswordController = ResetPasswordController()
        navigationController?.pushViewController(resetPasswordController, animated: true)
        
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
    
    fileprivate func setUpbackgroundImageView(){
        view.insertSubview(backgroundImage, at: 0)
        
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        backgroundImage.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    fileprivate func setupEditProfileBtn(){
        view.addSubview(editProfileBtn)
        
        editProfileBtn.translatesAutoresizingMaskIntoConstraints = false
        editProfileBtn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50).isActive = true
        editProfileBtn.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 24).isActive = true
        editProfileBtn.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -24).isActive = true
        editProfileBtn.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
    }
    
    fileprivate func setupResetPasswordBtn(){
        view.addSubview(resetPasswordBtn)
        
        resetPasswordBtn.translatesAutoresizingMaskIntoConstraints = false
        resetPasswordBtn.topAnchor.constraint(equalTo: editProfileBtn.bottomAnchor, constant: 20).isActive = true
        resetPasswordBtn.leftAnchor.constraint(equalTo: editProfileBtn.leftAnchor, constant: 0).isActive = true
        resetPasswordBtn.rightAnchor.constraint(equalTo: editProfileBtn.rightAnchor, constant: 0).isActive = true
        resetPasswordBtn.heightAnchor.constraint(equalToConstant: 80).isActive = true
    }
    
}


