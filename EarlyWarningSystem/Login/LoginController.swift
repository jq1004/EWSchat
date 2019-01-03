//
//  ViewController.swift
//  EarlyWarningSystem
//
//  Created by Junqing li on 12/23/18.
//  Copyright © 2018 Junqing li. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController, UITextFieldDelegate {
    
    let backgroundImage: UIImageView = {
        let b = UIImageView(frame: UIScreen.main.bounds)
        b.image = UIImage(named: "login.png")
        b.contentMode = UIView.ContentMode.scaleAspectFill
        return b
    }()
    
    let change_languange_btn: UIButton = {
        let c = UIButton(type: .system)
        c.setTitleColor(.blue, for: .normal)
//        c.setTitle("Change Language", for: .normal)
        c.addTarget(self, action: #selector(changeLanguage), for: .touchUpInside)
        return c
    }()
    
    @objc func changeLanguage(){
        if LocalizationSystem.sharedInstance.getLanguage() == "fr" {
            LocalizationSystem.sharedInstance.setLanguage(languageCode: "en")
        } else{
            LocalizationSystem.sharedInstance.setLanguage(languageCode: "fr")
        }
        viewDidLoad()
    }
    
    let logo: UIImageView = {
        let l = UIImageView()
           l.image = UIImage(named: "ews_logo.png")
           l.contentMode = .scaleAspectFill
//           l.layer.masksToBounds = true
           l.layer.cornerRadius = 20
        return l
    }()
    
    let emailTextField: UITextField = {
        let e = UITextField()
           e.textColor = .blue
           e.autocorrectionType = .no
        return e
    }()
    
    let passwordTextField: UITextField = {
        let p = UITextField()
           p.textColor = .white
           p.isSecureTextEntry = true
           p.autocorrectionType = .no
        return p
    }()
    
    let loginButton: UIButton = {
        
        let color = UIColor(red: 89/255, green: 156/255, blue: 120/255, alpha: 1)
        let l = UIButton(type: .system)
           l.setTitleColor(.white, for: .normal)
//           l.setTitle("Log In", for: .normal)
           l.backgroundColor = color
           l.layer.cornerRadius = 10
        l.addTarget(self, action: #selector(handleSignin), for: .touchUpInside)
        return l
    }()
    
    @objc func handleSignin(){
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { (autoResult, error) in
            guard let user = autoResult?.user else{
                let signFailedAlert = UIAlertController(title: "SignIn Failed", message: error!.localizedDescription, preferredStyle: .alert)
                signFailedAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(signFailedAlert, animated: true, completion: nil)
                return
            }
            let homeController = MainTabController()
            self.present(homeController, animated: true, completion: nil)
        }
    }
    
    let forgetButton: UIButton = {
        let f = UIButton(type: .system)
        f.setTitleColor(.white, for: .normal)
        f.addTarget(self, action: #selector(forgetPassword), for: .touchUpInside)
        return f
    }()
    
    @objc func forgetPassword(){
        let forgetPasswordController = ForgetController()
         present(forgetPasswordController, animated: true, completion: nil)
    }
    
    
    let haveAccountButton: UIButton = {
        let h = UIButton(type: .system)
    
        h.addTarget(self, action: #selector(signUpAction), for: .touchUpInside)
        return h
    }()
    
    @objc func signUpAction(){
        let signupController = SignupController()
        present(signupController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        change_languange_btn.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "change_language", comment: ""), for: .normal)
        loginButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "log_in", comment: ""), for: .normal)
        forgetButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "forget_password", comment: ""), for: .normal)
        
        navigationController?.isNavigationBarHidden = true
        
        setUpbackgroundImageView()
        setUpChangeLanguageBtn()
        setUpAddLogo()
        setUpTextFieldComponets()
        setUpLoginButton()
        setUpForgetButton()
        setUpHaveAccountButton()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    fileprivate func setUpbackgroundImageView(){
        view.insertSubview(backgroundImage, at: 0)
        
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        backgroundImage.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    // add constraints
    fileprivate func setUpAddLogo(){
        view.addSubview(logo)
        
        logo.translatesAutoresizingMaskIntoConstraints = false
        logo.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 64).isActive = true
        logo.heightAnchor.constraint(equalToConstant: 150).isActive = true
        logo.widthAnchor.constraint(equalToConstant: 150).isActive = true
        logo.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    fileprivate func setUpChangeLanguageBtn(){
        view.addSubview(change_languange_btn)
        
        change_languange_btn.translatesAutoresizingMaskIntoConstraints = false
        change_languange_btn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        change_languange_btn.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        change_languange_btn.widthAnchor.constraint(equalToConstant: 150).isActive = true
         change_languange_btn.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    fileprivate func setUpForgetButton(){
        view.addSubview(forgetButton)
        
        forgetButton.translatesAutoresizingMaskIntoConstraints = false
        forgetButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 8).isActive = true
        forgetButton.leftAnchor.constraint(equalTo: loginButton.leftAnchor, constant: 0).isActive = true
        forgetButton.rightAnchor.constraint(equalTo: loginButton.rightAnchor, constant: 0).isActive = true
        forgetButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    fileprivate func setUpHaveAccountButton(){
        view.addSubview(haveAccountButton)
        let color = UIColor(red: 89/255, green: 156/255, blue: 120/255, alpha: 1)
        let font = UIFont.systemFont(ofSize: 16)
        
        let locStr1 = LocalizationSystem.sharedInstance.localizedStringForKey(key: "dont_have_account", comment: "")
        let locStr2 = LocalizationSystem.sharedInstance.localizedStringForKey(key: "signup", comment: "")
        let attributedTitle = NSMutableAttributedString(string: locStr1, attributes: [NSAttributedString.Key.foregroundColor : color, NSAttributedString.Key.font : font])
        attributedTitle.append(NSAttributedString(string: locStr2, attributes: [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font : font]))
        haveAccountButton.setAttributedTitle(attributedTitle, for: .normal)
        
        haveAccountButton.translatesAutoresizingMaskIntoConstraints = false
        haveAccountButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8).isActive = true
        haveAccountButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12).isActive = true
        haveAccountButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -12).isActive = true
        haveAccountButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    fileprivate func setUpLoginButton(){
        view.addSubview(loginButton)
        
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 12).isActive = true
        loginButton.leftAnchor.constraint(equalTo: passwordTextField.leftAnchor, constant: 0).isActive = true
        loginButton.rightAnchor.constraint(equalTo: passwordTextField.rightAnchor, constant: 0).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
   fileprivate func setUpTextFieldComponets(){
        setUpEmailField()
        setUpPasswordField()
    }
    
   fileprivate func setUpEmailField(){
    let locStr = LocalizationSystem.sharedInstance.localizedStringForKey(key: "email", comment: "")
    let attributedPlaceholder = NSAttributedString(string: locStr, attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
    emailTextField.attributedPlaceholder = attributedPlaceholder
        view.addSubview(emailTextField)
        
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 24).isActive = true
        emailTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -24).isActive = true
        emailTextField.heightAnchor.constraint(equalToConstant: 30).isActive = true
        emailTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    fileprivate func setUpPasswordField(){
        let locStr = LocalizationSystem.sharedInstance.localizedStringForKey(key: "password", comment: "")
        let attributedPlaceholder = NSAttributedString(string: locStr, attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
        passwordTextField.attributedPlaceholder = attributedPlaceholder
        view.addSubview(passwordTextField)
        
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 8).isActive = true
        passwordTextField.leftAnchor.constraint(equalTo: emailTextField.leftAnchor, constant: 0).isActive = true
        passwordTextField.rightAnchor.constraint(equalTo: emailTextField.rightAnchor, constant: 0).isActive = true
        passwordTextField.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }


}

