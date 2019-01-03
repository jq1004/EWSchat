//
//  ForgetPassword.swift
//  EarlyWarningSystem
//
//  Created by Junqing li on 12/23/18.
//  Copyright © 2018 Junqing li. All rights reserved.
//

import UIKit

class ForgetController: UIViewController {
    
    let backButton: UIButton = {
        let color = UIColor(red: 89/255, green: 156/255, blue: 120/255, alpha: 1)
        let font = UIFont.systemFont(ofSize: 16)
        
        let h = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Remember?", attributes: [NSAttributedString.Key.foregroundColor : color, NSAttributedString.Key.font : font])
        attributedTitle.append(NSAttributedString(string: "Sign In", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font : font]))
        h.setAttributedTitle(attributedTitle, for: .normal)
        h.addTarget(self, action: #selector(backToSignInAction), for: .touchUpInside)
        return h
    }()
    @objc func backToSignInAction(){
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "login.png")
        backgroundImage.contentMode = UIView.ContentMode.scaleAspectFill
        view.insertSubview(backgroundImage, at: 0)
        
        setupBackButton()
    }
    
    
    fileprivate func setupBackButton(){
       view.addSubview(backButton)
        
       backButton.translatesAutoresizingMaskIntoConstraints = false
       backButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 8).isActive = true
       backButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
       backButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
       backButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }
}
