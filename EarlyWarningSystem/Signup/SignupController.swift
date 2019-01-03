//
//  SignupController.swift
//  EarlyWarningSystem
//
//  Created by Junqing li on 12/23/18.
//  Copyright © 2018 Junqing li. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class SignupController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate{
    
    var ref: DatabaseReference!
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //database connnection
        ref = Database.database().reference()
    
        setUpbackgroundImageView()
        setUpTextFieldComponets()
        setupHaveAccountButton()
        setupContinueButton()
        setupActivityIndicator()
        
        firstName.delegate = self
        lastName.delegate = self
        emailtxt.delegate = self
        addresstxt.delegate = self
        phonetxt.delegate = self
        passwordtxt.delegate = self
        confirmPasswordtxt.delegate = self
        
        firstName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        lastName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        emailtxt.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        addresstxt.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        phonetxt.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        passwordtxt.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        confirmPasswordtxt.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        
    }
    
    var location: CLLocation!{
        didSet{
            print(location.coordinate.latitude)
            print(location.coordinate.longitude)
        }
    }
    
    let backgroundImage: UIImageView = {
        let b = UIImageView(frame: UIScreen.main.bounds)
        b.image = UIImage(named: "login.png")
        b.contentMode = UIView.ContentMode.scaleAspectFill
        return b
    }()
    
    let activityView: UIActivityIndicatorView = {
        let a = UIActivityIndicatorView(style: .gray)
           a.color = secondaryColor
           a.frame = CGRect(x: 0, y: 0, width: 50.0, height: 50.0)
        return a
    }()
    
    let haveAccountButton: UIButton = {
        let color = UIColor(red: 89/255, green: 156/255, blue: 120/255, alpha: 1)
        let font = UIFont.systemFont(ofSize: 16)
        
        let h = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Already have an account?", attributes: [NSAttributedString.Key.foregroundColor : color, NSAttributedString.Key.font : font])
        attributedTitle.append(NSAttributedString(string: "Sign In", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font : font]))
        h.setAttributedTitle(attributedTitle, for: .normal)
        h.addTarget(self, action: #selector(returnToSignInPageAction), for: .touchUpInside)
        return h
    }()
    
    @objc func returnToSignInPageAction(){
        self.dismiss(animated: true, completion: nil)
//        navigationController?.popViewController(animated: true)
    }
    
    
    let continueButton: RoundedButton = {
        let c =  RoundedButton(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
           c.setTitleColor(secondaryColor, for: .normal)
           c.setTitle("Submit", for: .normal)
        
           c.titleLabel?.font = UIFont.systemFont(ofSize: 18.0, weight: UIFont.Weight.bold)
           c.highlightedColor = UIColor(white: 1.0, alpha: 1.0)
           c.defaultColor = UIColor.white
           c.addTarget(self, action: #selector(signUp), for: .touchUpInside)
        return c
    }()
    
    @objc func signUp(){
        setContinueButton(enabled: false)
        continueButton.setTitle("", for: .normal)
        activityView.startAnimating()
        Auth.auth().createUser(withEmail: emailtxt.text!, password: passwordtxt.text!) { (authResult, error) in
            guard let user = authResult?.user else{
                print("error signup")
                    return
             }
            
            guard let firstName = self.firstName.text else{return}
            guard let lastName = self.lastName.text else{return}
            guard let email = self.emailtxt.text else{return}
            guard let address = self.addresstxt.text else{return}
            guard let phoneNumber = self.phonetxt.text else{return}
            guard let password = self.passwordtxt.text else{return}
            
            let userDict = ["Uid": user.uid, "First Name": firstName, "Last Name":lastName, "Email":email,"Address":address, "Phone Number":phoneNumber, "Password": password, "Latitude": self.location.coordinate.latitude, "Longitude": self.location.coordinate.longitude  ] as [String : Any]
            self.ref?.child("User").child(user.uid).setValue(userDict, withCompletionBlock: { (error, ref) in
                if error != nil {
                    print("*******check user signup error")
                    print(error?.localizedDescription ?? "")
                    self.activityView.stopAnimating()
                }
                else {
                    print("*******sign up sucesss")
                    self.activityView.stopAnimating()
                    // when signup succeeds, signOut
                    try! Auth.auth().signOut()
                    self.dismiss(animated: true, completion: nil)
                }
            })
        }
    }
    
    let firstName: UITextField = {
        let f = UITextField()
        f.borderStyle = .none
        f.layer.cornerRadius = 5
        f.backgroundColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 0.2)
        f.font = UIFont(name: "Verdana", size: 17)
        f.textColor = .blue
        f.autocorrectionType = .no
        var placeholder = NSMutableAttributedString(string: "Firstname", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14),NSAttributedString.Key.foregroundColor: UIColor(white: 1, alpha: 0.7)])
        f.attributedPlaceholder = placeholder
        return f
    }()
    
    let lastName: UITextField = {
        let l = UITextField()
        l.borderStyle = .none
        l.layer.cornerRadius = 5
        l.backgroundColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 0.2)
        l.font = UIFont(name: "Verdana", size: 17)
        l.textColor = .blue
        l.autocorrectionType = .no
        var placeholder = NSMutableAttributedString(string: "Lastname", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14),NSAttributedString.Key.foregroundColor: UIColor(white: 1, alpha: 0.7)])
        l.attributedPlaceholder = placeholder
        return l
    }()
    
    let emailtxt: UITextField = {
        let l = UITextField()
        l.borderStyle = .none
        l.layer.cornerRadius = 5
        l.backgroundColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 0.2)
        l.font = UIFont(name: "Verdana", size: 17)
        l.textColor = .blue
        l.autocorrectionType = .no
        var placeholder = NSMutableAttributedString(string: "Email", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14),NSAttributedString.Key.foregroundColor: UIColor(white: 1, alpha: 0.7)])
        l.attributedPlaceholder = placeholder
        return l
    }()
    
    let addresstxt: UITextField = {
        let l = UITextField()
        l.borderStyle = .none
        l.layer.cornerRadius = 5
        l.backgroundColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 0.2)
        l.font = UIFont(name: "Verdana", size: 17)
        l.textColor = .blue
        l.autocorrectionType = .no
        var placeholder = NSMutableAttributedString(string: "Address", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14),NSAttributedString.Key.foregroundColor: UIColor(white: 1, alpha: 0.7)])
        l.attributedPlaceholder = placeholder
        return l
    }()
    
    let phonetxt: UITextField = {
        let l = UITextField()
        l.borderStyle = .none
        l.layer.cornerRadius = 5
        l.backgroundColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 0.2)
        l.font = UIFont(name: "Verdana", size: 17)
        l.textColor = .blue
        l.autocorrectionType = .no
        var placeholder = NSMutableAttributedString(string: "Phone number", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14),NSAttributedString.Key.foregroundColor: UIColor(white: 1, alpha: 0.7)])
        l.attributedPlaceholder = placeholder
        return l
    }()
    
    let passwordtxt: UITextField = {
        let l = UITextField()
        l.borderStyle = .none
        l.layer.cornerRadius = 5
        l.backgroundColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 0.2)
        l.font = UIFont(name: "Verdana", size: 17)
        l.textColor = .blue
        l.autocorrectionType = .no
        l.isSecureTextEntry = true
        var placeholder = NSMutableAttributedString(string: "Password", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14),NSAttributedString.Key.foregroundColor: UIColor(white: 1, alpha: 0.7)])
        l.attributedPlaceholder = placeholder
        return l
    }()
    
    let confirmPasswordtxt: UITextField = {
        let l = UITextField()
        l.borderStyle = .none
        l.layer.cornerRadius = 5
        l.backgroundColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 0.2)
        l.font = UIFont(name: "Verdana", size: 17)
        l.textColor = .blue
        l.autocorrectionType = .no
        l.isSecureTextEntry = true
        var placeholder = NSMutableAttributedString(string: "Confrim password", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14),NSAttributedString.Key.foregroundColor: UIColor(white: 1, alpha: 0.7)])
        l.attributedPlaceholder = placeholder
        return l
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        checkCoreLocationPermission()
        
    }
    
    func checkCoreLocationPermission(){
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        } else if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if CLLocationManager.authorizationStatus() == .restricted{
            print("unauthorized location!")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        location = (locations).last
        locationManager.stopUpdatingLocation()
    }
    
   
    
    @objc func textFieldChanged(_ target:UITextField) {
        
        let firstname = firstName.text
        let lastname = lastName.text
        let email = emailtxt.text
        let address = addresstxt.text
        let phone = phonetxt.text
        let password = passwordtxt.text
        let confirmpassword = confirmPasswordtxt.text
        
        let formFilled: Bool = firstname != nil && firstname != ""&&lastname != nil && lastname != "" && email != nil && email != "" && address != nil && address != "" && phone != nil && phone != "" && password != nil && password != "" && password != nil && password != "" && password == confirmpassword
        print(formFilled)
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
    
    fileprivate func setUpTextFieldComponets(){
        setUpFirstnameField()
        setUpLastnameField()
        setUpEmailField()
        setUpAddressField()
        setUpPhonenumberField()
        setUpPasswordField()
        setUpConfirmPasswordField()
    }
    
    fileprivate func setUpFirstnameField(){
        view.addSubview(firstName)
        
        firstName.translatesAutoresizingMaskIntoConstraints = false
        firstName.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60).isActive = true
        firstName.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30).isActive = true
        firstName.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30).isActive = true
        firstName.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
    
    fileprivate func setUpLastnameField(){
        view.addSubview(lastName)
        
        lastName.translatesAutoresizingMaskIntoConstraints = false
        lastName.topAnchor.constraint(equalTo: firstName.bottomAnchor, constant: 20).isActive = true
        lastName.leftAnchor.constraint(equalTo: firstName.leftAnchor, constant: 0).isActive = true
        lastName.rightAnchor.constraint(equalTo: firstName.rightAnchor, constant: 0).isActive = true
        lastName.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
    
    fileprivate func setUpEmailField(){
        view.addSubview(emailtxt)
        
        emailtxt.translatesAutoresizingMaskIntoConstraints = false
        emailtxt.topAnchor.constraint(equalTo: lastName.bottomAnchor, constant: 20).isActive = true
        emailtxt.leftAnchor.constraint(equalTo: lastName.leftAnchor, constant: 0).isActive = true
        emailtxt.rightAnchor.constraint(equalTo: lastName.rightAnchor, constant: 0).isActive = true
        emailtxt.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
    
    fileprivate func setUpAddressField(){
        view.addSubview(addresstxt)
        
        addresstxt.translatesAutoresizingMaskIntoConstraints = false
        addresstxt.topAnchor.constraint(equalTo: emailtxt.bottomAnchor, constant: 20).isActive = true
        addresstxt.leftAnchor.constraint(equalTo: lastName.leftAnchor, constant: 0).isActive = true
        addresstxt.rightAnchor.constraint(equalTo: lastName.rightAnchor, constant: 0).isActive = true
        addresstxt.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
    
    fileprivate func setUpPhonenumberField(){
        view.addSubview(phonetxt)
        
        phonetxt.translatesAutoresizingMaskIntoConstraints = false
        phonetxt.topAnchor.constraint(equalTo: addresstxt.bottomAnchor, constant: 20).isActive = true
        phonetxt.leftAnchor.constraint(equalTo: lastName.leftAnchor, constant: 0).isActive = true
        phonetxt.rightAnchor.constraint(equalTo: lastName.rightAnchor, constant: 0).isActive = true
        phonetxt.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
    
    fileprivate func setUpPasswordField(){
        view.addSubview(passwordtxt)
        
        passwordtxt.translatesAutoresizingMaskIntoConstraints = false
        passwordtxt.topAnchor.constraint(equalTo: phonetxt.bottomAnchor, constant: 20).isActive = true
        passwordtxt.leftAnchor.constraint(equalTo: lastName.leftAnchor, constant: 0).isActive = true
        passwordtxt.rightAnchor.constraint(equalTo: lastName.rightAnchor, constant: 0).isActive = true
        passwordtxt.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
    
    fileprivate func setUpConfirmPasswordField(){
        view.addSubview(confirmPasswordtxt)
        
        confirmPasswordtxt.translatesAutoresizingMaskIntoConstraints = false
        confirmPasswordtxt.topAnchor.constraint(equalTo: passwordtxt.bottomAnchor, constant: 20).isActive = true
        confirmPasswordtxt.leftAnchor.constraint(equalTo: lastName.leftAnchor, constant: 0).isActive = true
        confirmPasswordtxt.rightAnchor.constraint(equalTo: lastName.rightAnchor, constant: 0).isActive = true
        confirmPasswordtxt.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
    
    fileprivate func setupActivityIndicator(){
        view.addSubview(activityView)
        
        activityView.center = continueButton.center
    }
    
    fileprivate func setupContinueButton(){
        view.addSubview(continueButton)
        
        continueButton.center = CGPoint(x: view.center.x, y: view.frame.height - continueButton.frame.height - 37)
        
        setContinueButton(enabled: false)
        
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
    
    fileprivate func setupHaveAccountButton(){
        view.addSubview(haveAccountButton)
        
        haveAccountButton.translatesAutoresizingMaskIntoConstraints = false
        haveAccountButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 8).isActive = true
        haveAccountButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        haveAccountButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        haveAccountButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }
    
}
