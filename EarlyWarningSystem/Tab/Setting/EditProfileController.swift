//
//  EditProfile.swift
//  EarlyWarningSystem
//
//  Created by Junqing li on 12/24/18.
//  Copyright © 2018 Junqing li. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class EditProfileController: UIViewController, UITextFieldDelegate{
    
    let userRef = Database.database().reference()
    var storageRef = Storage.storage().reference()
    var imagePicker: UIImagePickerController!
    var profileImage: UIImageView!
   
    let backgroundImage: UIImageView = {
        let b = UIImageView(frame: UIScreen.main.bounds)
        b.image = UIImage(named: "login.png")
        b.contentMode = UIView.ContentMode.scaleAspectFill
        return b
    }()
    
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
        let e = UITextField()
        e.textColor = UIColor.darkGray
        e.isUserInteractionEnabled = false
        e.autocorrectionType = .no

        return e
    }()
    
    let addresstxt: UITextField = {
        let a = UITextField()
        a.borderStyle = .none
        a.layer.cornerRadius = 5
        a.backgroundColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 0.2)
        a.font = UIFont(name: "Verdana", size: 17)
        a.textColor = .blue
        a.autocorrectionType = .no
        var placeholder = NSMutableAttributedString(string: "Address", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14),NSAttributedString.Key.foregroundColor: UIColor(white: 1, alpha: 0.7)])
        a.attributedPlaceholder = placeholder

        return a
    }()
    
    let phonetxt: UITextField = {
        let p = UITextField()
        p.borderStyle = .none
        p.layer.cornerRadius = 5
        p.backgroundColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 0.2)
        p.font = UIFont(name: "Verdana", size: 17)
        p.textColor = .blue
        p.autocorrectionType = .no
        var placeholder = NSMutableAttributedString(string: "Phone number", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14),NSAttributedString.Key.foregroundColor: UIColor(white: 1, alpha: 0.7)])
        p.attributedPlaceholder = placeholder

        return p
    }()
    
    let activityView: UIActivityIndicatorView = {
        let a = UIActivityIndicatorView(style: .gray)
        a.color = secondaryColor
        a.frame = CGRect(x: 0, y: 0, width: 50.0, height: 50.0)
        return a
    }()
    
    let continueButton: RoundedButton = {
        let c =  RoundedButton(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        c.setTitleColor(secondaryColor, for: .normal)
        c.setTitle("Edit", for: .normal)
        
        c.titleLabel?.font = UIFont.systemFont(ofSize: 18.0, weight: UIFont.Weight.bold)
        c.highlightedColor = UIColor(white: 1.0, alpha: 1.0)
        c.defaultColor = UIColor.white
        c.addTarget(self, action: #selector(edit), for: .touchUpInside)
        return c
    }()
    
    fileprivate func observeUserProfile(){
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        let currenUserRef = userRef.child("User").child(uid)
             currenUserRef.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dict = snapshot.value as? [String:AnyObject] else {
                    return
                }
//                print("start edit controller")
                self.firstName.text = dict["First Name"] as? String
                self.lastName.text = dict["Last Name"] as? String
                self.emailtxt.text = dict["Email"] as? String
                self.addresstxt.text = dict["Address"] as? String
                self.phonetxt.text = dict["Phone Number"] as? String
                
                let imageName = "UserImage/\(String(describing: snapshot.key)).jpeg"
                self.storageRef.child(imageName).getData(maxSize: 10*1024*1024) { (imgdata, error) in
                    if error == nil {
                        
                        self.profileImage.image = UIImage(data: imgdata!)
                        print("*EdidProfileController - finishing reloading userprofile")
                        
                    } else {
                         self.profileImage.image = UIImage(named: "empty-image")
                        print(error!)
                    }
                }
            }, withCancel: nil)
    }
    
    @objc func edit(){
        setContinueButton(enabled: false)
        continueButton.setTitle("", for: .normal)
        activityView.startAnimating()
       
        guard let user = Auth.auth().currentUser else {return}
        
        guard let firstName = self.firstName.text else{return}
        guard let lastName = self.lastName.text else{return}
        guard let email = self.emailtxt.text else{return}
        guard let address = self.addresstxt.text else{return}
        guard let phoneNumber = self.phonetxt.text else{return}
        guard let image = profileImage.image else { return }
        
        let userDict = ["First Name": firstName, "Last Name":lastName, "Email":email,"Address":address, "Phone Number":phoneNumber] as [String : Any]
        
        self.userRef.child("User").child(user.uid).updateChildValues(userDict)
        uploaduserImage(id: user.uid, image: image)
       
    }
    
    fileprivate func uploaduserImage(id: String, image: UIImage){
        let metadata = StorageMetadata()
        let imageData = image.jpegData(compressionQuality: 0.2)

        
         metadata.contentType = "image/jpeg"
        let imagename = "UserImage/\(String(describing: id)).jpeg"
        
        storageRef = storageRef.child(imagename)
        storageRef.putData(imageData!, metadata: metadata
            , completion: { (data, error) in
                if error == nil{
                    print("*******Edit Profile: upload img success!")
                    self.activityView.stopAnimating()
                    print("********Edit Profile: Update profile again!")
                    self.navigationController?.popViewController(animated: true)
                }else{
                    print("*******Edit Profile: upload img fail!")
                    self.activityView.stopAnimating()
                }
                
                
        })
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setUpbackgroundImageView()
        setUpTextFieldComponets()
        setupContinueButton()
        setupActivityIndicator()
        
        firstName.delegate = self
        lastName.delegate = self
        emailtxt.delegate = self
        addresstxt.delegate = self
        phonetxt.delegate = self
        
        firstName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        lastName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        emailtxt.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        addresstxt.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        phonetxt.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(openImagePicker))
        
        profileImage = UIImageView()
        profileImage.isUserInteractionEnabled = true
        profileImage.addGestureRecognizer(imageTap)
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
        profileImage.clipsToBounds = true
        profileImage.layer.masksToBounds = true
        
        setupProfileImg()
        observeUserProfile()
    }
    
        @objc func openImagePicker(){
            self.present(imagePicker, animated: true, completion: nil)
        }
    
        @objc func textFieldChanged(_ target:UITextField) {
        
        let firstname = firstName.text
        let lastname = lastName.text
        let email = emailtxt.text
        let address = addresstxt.text
        let phone = phonetxt.text
        
        let formFilled: Bool = firstname != nil && firstname != ""&&lastname != nil && lastname != "" && email != nil && email != "" && address != nil && address != "" && phone != nil && phone != ""
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
        }
    
       fileprivate func setupActivityIndicator(){
        view.addSubview(activityView)
        
        activityView.center = continueButton.center
       }
    
        fileprivate func setUpFirstnameField(){
            view.addSubview(firstName)
            
            firstName.translatesAutoresizingMaskIntoConstraints = false
            firstName.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 150).isActive = true
            firstName.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30).isActive = true
            firstName.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30).isActive = true
            firstName.heightAnchor.constraint(equalToConstant: 50).isActive = true
        }
    
        fileprivate func setUpLastnameField(){
            view.addSubview(lastName)
        
            lastName.translatesAutoresizingMaskIntoConstraints = false
            lastName.topAnchor.constraint(equalTo: firstName.bottomAnchor, constant: 20).isActive = true
            lastName.leftAnchor.constraint(equalTo: firstName.leftAnchor, constant: 0).isActive = true
            lastName.rightAnchor.constraint(equalTo: firstName.rightAnchor, constant: 0).isActive = true
            lastName.heightAnchor.constraint(equalToConstant: 50).isActive = true
        }
    
        fileprivate func setUpEmailField(){
            view.addSubview(emailtxt)
        
            emailtxt.translatesAutoresizingMaskIntoConstraints = false
            emailtxt.topAnchor.constraint(equalTo: lastName.bottomAnchor, constant: 20).isActive = true
            emailtxt.leftAnchor.constraint(equalTo: lastName.leftAnchor, constant: 0).isActive = true
            emailtxt.rightAnchor.constraint(equalTo: lastName.rightAnchor, constant: 0).isActive = true
            emailtxt.heightAnchor.constraint(equalToConstant: 50).isActive = true
        }
    
        fileprivate func setUpAddressField(){
            view.addSubview(addresstxt)
        
            addresstxt.translatesAutoresizingMaskIntoConstraints = false
            addresstxt.topAnchor.constraint(equalTo: emailtxt.bottomAnchor, constant: 20).isActive = true
            addresstxt.leftAnchor.constraint(equalTo: lastName.leftAnchor, constant: 0).isActive = true
            addresstxt.rightAnchor.constraint(equalTo: lastName.rightAnchor, constant: 0).isActive = true
            addresstxt.heightAnchor.constraint(equalToConstant: 50).isActive = true
        }
    
        fileprivate func setUpPhonenumberField(){
            view.addSubview(phonetxt)
        
            phonetxt.translatesAutoresizingMaskIntoConstraints = false
            phonetxt.topAnchor.constraint(equalTo: addresstxt.bottomAnchor, constant: 20).isActive = true
            phonetxt.leftAnchor.constraint(equalTo: lastName.leftAnchor, constant: 0).isActive = true
            phonetxt.rightAnchor.constraint(equalTo: lastName.rightAnchor, constant: 0).isActive = true
            phonetxt.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    fileprivate func setupContinueButton(){
        view.addSubview(continueButton)
        
        continueButton.center = CGPoint(x: view.center.x, y: view.frame.height - continueButton.frame.height - 70)
        
        setContinueButton(enabled: false)
        
    }
    
        fileprivate func setupProfileImg(){
            view.addSubview(profileImage)
    
            profileImage.translatesAutoresizingMaskIntoConstraints = false
            profileImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32).isActive = true
            profileImage.heightAnchor.constraint(equalToConstant: 64).isActive = true
            profileImage.widthAnchor.constraint(equalToConstant: 64).isActive = true
            profileImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        }
}

extension EditProfileController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
       
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else{ fatalError("picker image error!")}
        self.profileImage.image = selectedImage
        self.profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
        self.profileImage.layer.masksToBounds = true
        dismiss(animated: true, completion: nil)
        //update continue button state
        let firstname = firstName.text
        let lastname = lastName.text
        let email = emailtxt.text
        let address = addresstxt.text
        let phone = phonetxt.text
        
        let formFilled: Bool = firstname != nil && firstname != ""&&lastname != nil && lastname != "" && email != nil && email != "" && address != nil && address != "" && phone != nil && phone != ""
        setContinueButton(enabled: formFilled)
       
    }
}

