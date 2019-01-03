//
//  ResetPasswordController.swift
//  EarlyWarningSystem
//
//  Created by Junqing li on 12/24/18.
//  Copyright © 2018 Junqing li. All rights reserved.
//

import UIKit
import Firebase

class ResetPasswordController: UIViewController, UITextFieldDelegate{
    
    let userRef = Database.database().reference()
    
    let activityView: UIActivityIndicatorView = {
        let a = UIActivityIndicatorView(style: .gray)
        a.color = secondaryColor
        a.frame = CGRect(x: 0, y: 0, width: 50.0, height: 50.0)
        return a
    }()
    
    let backgroundImage: UIImageView = {
        let b = UIImageView(frame: UIScreen.main.bounds)
        b.image = UIImage(named: "login.png")
        b.contentMode = UIView.ContentMode.scaleAspectFill
        return b
    }()
    
    let passwordtxt: UITextField = {
        let f = UITextField()
        f.borderStyle = .none
        f.layer.cornerRadius = 5
        f.backgroundColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 0.2)
        f.font = UIFont(name: "Verdana", size: 17)
        f.textColor = .blue
        f.isSecureTextEntry = true
        f.autocorrectionType = .no
        var placeholder = NSMutableAttributedString(string: "Password", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14),NSAttributedString.Key.foregroundColor: UIColor(white: 1, alpha: 0.7)])
        f.attributedPlaceholder = placeholder
        return f
    }()
    
    let confirmPasswordtxt: UITextField = {
        let f = UITextField()
        f.borderStyle = .none
        f.layer.cornerRadius = 5
        f.backgroundColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 0.2)
        f.font = UIFont(name: "Verdana", size: 17)
        f.textColor = .blue
        f.isSecureTextEntry = true
        f.autocorrectionType = .no
        var placeholder = NSMutableAttributedString(string: "Confirm Password", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14),NSAttributedString.Key.foregroundColor: UIColor(white: 1, alpha: 0.7)])
        f.attributedPlaceholder = placeholder
        return f
       
    }()
    
    let continueButton: RoundedButton = {
        let c =  RoundedButton(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        c.setTitleColor(secondaryColor, for: .normal)
        c.setTitle("Submit", for: .normal)
        
        c.titleLabel?.font = UIFont.systemFont(ofSize: 18.0, weight: UIFont.Weight.bold)
        c.highlightedColor = UIColor(white: 1.0, alpha: 1.0)
        c.defaultColor = UIColor.white
        c.addTarget(self, action: #selector(resetPass), for: .touchUpInside)
        return c
    }()
    
    @objc func resetPass(){
        setContinueButton(enabled: false)
        continueButton.setTitle("", for: .normal)
        guard let password = self.passwordtxt.text else{return}
        guard let confirmPassword = confirmPasswordtxt.text else { return }
        if password != confirmPassword {return}
        Auth.auth().currentUser?.updatePassword(to: password, completion: { (error) in
            DispatchQueue.main.async {
                if  error != nil {
                    let resetFailedAlert = UIAlertController(title: "Reset Failed", message: error!.localizedDescription, preferredStyle: .alert)
                    resetFailedAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(resetFailedAlert, animated: true, completion: nil)
                } else {
                    let resetEmailSentAlert = UIAlertController(title: "Reset password successfully", message: "Please remember new password", preferredStyle: .alert)
                    resetEmailSentAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(resetEmailSentAlert, animated: true, completion: nil)
                }
            }
        })
        
        let user = Auth.auth().currentUser
        let userDict = ["Password": password] as [String : Any]
        
        self.userRef.child("User").child(user!.uid).updateChildValues(userDict)
//        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setUpbackgroundImageView()
        passwordtxt.delegate = self
        confirmPasswordtxt.delegate = self
        
        passwordtxt.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        confirmPasswordtxt.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        
        setUpPasswordField()
        setUpConfirmPasswordField()
        setupContinueButton()
        setupActivityIndicator()
        
    }
    
    @objc func textFieldChanged(_ target:UITextField) {
        
        let password = passwordtxt.text
        let confirmpassword = confirmPasswordtxt.text
        
        let formFilled: Bool = password != nil && password != "" && password != nil && password != "" && password == confirmpassword
        setContinueButton(enabled: formFilled)
    }
    
    fileprivate func setUpbackgroundImageView(){
        view.insertSubview(backgroundImage, at: 0)
        
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        backgroundImage.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    fileprivate func setUpPasswordField(){
        view.addSubview(passwordtxt)
        
        passwordtxt.translatesAutoresizingMaskIntoConstraints = false
        passwordtxt.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 150).isActive = true
        passwordtxt.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 80).isActive = true
        passwordtxt.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -80).isActive = true
        passwordtxt.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
    
    fileprivate func setUpConfirmPasswordField(){
        view.addSubview(confirmPasswordtxt)
        
        confirmPasswordtxt.translatesAutoresizingMaskIntoConstraints = false
        confirmPasswordtxt.topAnchor.constraint(equalTo: passwordtxt.bottomAnchor, constant: 50).isActive = true
        confirmPasswordtxt.leftAnchor.constraint(equalTo: passwordtxt.leftAnchor, constant: 0).isActive = true
        confirmPasswordtxt.rightAnchor.constraint(equalTo: passwordtxt.rightAnchor, constant: 0).isActive = true
        confirmPasswordtxt.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
    
    fileprivate func setupContinueButton(){
        view.addSubview(continueButton)
        
        continueButton.center = CGPoint(x: view.center.x, y: view.frame.height - continueButton.frame.height - 80)
        
        setContinueButton(enabled: false)
        
    }
    
    fileprivate func setupActivityIndicator(){
        view.addSubview(activityView)
        
        activityView.center = continueButton.center
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //toggle button
    fileprivate func setContinueButton(enabled:Bool) {
        if enabled {
            continueButton.alpha = 1.0
            continueButton.isEnabled = true
        } else {
            continueButton.alpha = 0.5
            continueButton.isEnabled = false
        }
    }
    
}
