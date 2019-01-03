//
//  PostViewController.swift
//  EarlyWarningSystem
//
//  Created by Junqing li on 12/27/18.
//  Copyright © 2018 Junqing li. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseStorage

class PostViewController: UIViewController, UITextViewDelegate {
    
    var imagePicker: UIImagePickerController!
    var postImage: UIImageView!
    let userRef = Database.database().reference()
    var storageRef : StorageReference?
    
    
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

    let commentTextView:UITextView = {
        let c = UITextView()
        c.layer.cornerRadius = 15
        c.layer.masksToBounds = true
        c.font = UIFont.systemFont(ofSize: 15)
        c.font = UIFont(name: "Verdana", size: 17)
        c.textColor = .blue
        c.backgroundColor = UIColor.cyan
        c.autocorrectionType = .no
        return c
    }()
    
    @objc func completePost(){
        //should not post if no user profile image ..
        setContinueButton(enabled: false)
        activityView.startAnimating()
        
        guard let msg = commentTextView.text else{return}
        
        // create new post on database
        let postRef = Database.database().reference().child("posts").childByAutoId()
        let metadata = StorageMetadata()
        
        //upload image
        let imageData = postImage.image!.jpegData(compressionQuality: 0.2)
        
        metadata.contentType = "image/jpeg"
        let imagename = "PostImages/\(String(describing:postRef.key!)).jpeg"
        
        storageRef = storageRef?.child(imagename)
        storageRef?.putData(imageData!, metadata: metadata
            , completion: { (data, error) in
                if error == nil{
                    print("upload post img success!")
                    
                    // upload post info if upload image success
                    let postObject = [
                        "uid": Auth.auth().currentUser?.uid as Any,
                        "text": msg,
                        "timestamp": [".sv":"timestamp"]
                        ] as [String:Any]
                    
                    postRef.setValue(postObject, withCompletionBlock: { error, ref in
                        if error == nil {
                            print("succeeded to create new post")
                            self.activityView.stopAnimating()
                            self.navigationController?.popViewController(animated: true)
                        } else {
                            print("failed to create new post")
                        }
                    })
                    
                }else{
                    print("upload post img failed!")
                    self.activityView.stopAnimating()
                }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commentTextView.delegate = self
        
        storageRef = Storage.storage().reference()
        
        let startPostButton = UIBarButtonItem(title: "", style: .done, target: self, action: #selector(completePost))
        let postIcon: UIImage = UIImage(named: "post.png")!
        startPostButton.setBackgroundImage(postIcon, for: .normal, barMetrics: .default)
        
        navigationItem.rightBarButtonItem  = startPostButton
        navigationItem.title = "Add Post"
        
        setUpbackgroundImageView()
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
       
        
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(openImagePicker))
        
        postImage = UIImageView()
       
        postImage.isUserInteractionEnabled = true
        postImage.addGestureRecognizer(imageTap)
        postImage.clipsToBounds = true
        postImage.image = UIImage(named: "ews_logo.png")
        

        setupCommentTextView()
       
        setupActivityIndicator()
        setupProfileImg()
       
    }
    
    @objc func openImagePicker(){
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"{
            textView.resignFirstResponder()
            return false
        }
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
    
    //toggle button
    fileprivate func setContinueButton(enabled:Bool) {
        if enabled {
            navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    fileprivate func setupProfileImg(){
        view.addSubview(postImage)
        
        postImage.translatesAutoresizingMaskIntoConstraints = false
        postImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 58).isActive = true
        postImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        postImage.heightAnchor.constraint(equalToConstant: 200).isActive = true
        postImage.widthAnchor.constraint(equalToConstant: 200).isActive = true
    }
    
    fileprivate func setupCommentTextView(){
         view.addSubview(commentTextView)
        commentTextView.translatesAutoresizingMaskIntoConstraints = false
        commentTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30).isActive = true
        commentTextView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30).isActive = true
        commentTextView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30).isActive = true
        commentTextView.heightAnchor.constraint(equalToConstant: 300).isActive = true
    }
    
    fileprivate func setupActivityIndicator(){
        view.addSubview(activityView)
        
        activityView.center = view.center
    }
    
    
}

extension PostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else{ fatalError("picker image error!")}
        
        self.postImage.image = selectedImage
        
        dismiss(animated: true, completion: nil)
    }
}
