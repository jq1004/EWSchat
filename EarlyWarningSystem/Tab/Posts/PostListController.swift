//
//  PostListController.swift
//  EarlyWarningSystem
//
//  Created by Junqing li on 12/27/18.
//  Copyright © 2018 Junqing li. All rights reserved.
//

import Foundation
import UIKit
import Firebase

let cellId = "cellId"

class PostListController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let userRef = Database.database().reference()
    let storageRef = Storage.storage().reference()
    var postData = [Post]()
    
    fileprivate func observePostlist(){
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        let postListRef = userRef.child("posts")
        
        postListRef.observe(.childAdded, with: { (snapshot) in
            
            let postId = snapshot.key
            let postRef = self.userRef.child("posts").child(postId)
            let post = Post()
            postRef.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dict = snapshot.value as? [String:AnyObject] else {
                    print("No post!")
                    return
                }
                print("post list debugging")
                
                post.uId = dict["uid"] as? String
                post.text = dict["text"] as? String
                post.timestamp = dict["timestamp"] as? NSNumber


                let userProfileRef = self.userRef.child("User").child(post.uId!)
                userProfileRef.observeSingleEvent(of: .value, with: { (snap) in
                    guard let userDict = snap.value as? [String:AnyObject] else {
                        print("No User!")
                        return
                    }
                    post.firstname = userDict["First Name"] as? String
                    
                }, withCancel: nil)
                //fetch profile img
                let imageName = "UserImage/\(String(describing: post.uId!)).jpeg"
                self.storageRef.child(imageName).getData(maxSize: 10*1024*1024) { (img, error) in
                    if error == nil {
                        
                    post.profilImg = UIImage(data: img!)
                        print("^^^profile img download success")

                        //fetch post img
                        let postImgName = "PostImages/\(String(describing: snapshot.key)).jpeg"
                        self.storageRef.child(postImgName).getData(maxSize: 10*1024*1024) { (imgdata, error) in
                            if error == nil {
                                
                                post.postImg = UIImage(data: imgdata!)
                                print("^^^post img download success")
                                self.postData.append(post)
                                //sort array by timestamp
                                self.postData.sort(by: { (post1, post2) -> Bool in
                                    return post1.timestamp!.intValue > post2.timestamp!.intValue
                                })
                                
                                DispatchQueue.main.async {
                                    self.collectionView.reloadData()
                                    print("*start reloading postlist")
                                }
                                
                            } else {
                                print(error!)
                            }
                        }
                    } else {
                        print(error!)
                    }
                }
                
            }, withCancel: nil)
            
            
        }, withCancel: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //   set background image
        collectionView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        collectionView.alwaysBounceVertical = true
        collectionView.register(PostCell.self, forCellWithReuseIdentifier: "cellId")
        
        
        let startPostButton = UIBarButtonItem(title: "", style: .done, target: self, action: #selector(startPost))
        let photoIcon: UIImage = UIImage(named: "photo.png")!
        startPostButton.setBackgroundImage(photoIcon, for: .normal, barMetrics: .default)
        
        navigationItem.rightBarButtonItem  = startPostButton
//
        let logoutButton = UIBarButtonItem(title: "", style: .done, target: self, action: #selector(logoutUser))
        let logoutIcon: UIImage = UIImage(named: "logout.png")!
        logoutButton.setBackgroundImage(logoutIcon, for: .normal, barMetrics: .default)
        navigationItem.leftBarButtonItem = logoutButton
                
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Posts"
        observePostlist()

    }
    
    @objc func startPost(){
        let p = PostViewController()
        self.navigationController?.pushViewController(p, animated: true)
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
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postData.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! PostCell
       
        cell.commentTextView.text = postData[indexPath.row].text
        
        let date = postData[indexPath.row].timestamp
        let seconds = date?.doubleValue
        let timestampDate = NSDate(timeIntervalSince1970: seconds!)
        let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = "hh:mm:ss a"
        let dataStr = dateFormatter.string(from: timestampDate as Date)
        cell.nameLabel.attributedText = createAttributedString(name: postData[indexPath.row].firstname!,dataStr: dataStr)
        
        cell.postImageView.image = postData[indexPath.row].postImg
        cell.profileImageView.image = postData[indexPath.row].profilImg
        
        return cell
    }
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width:view.frame.width, height:300)
       
    }
    
    func createAttributedString(name: String, dataStr: String)-> NSMutableAttributedString{
        let attributedText = NSMutableAttributedString(string: name, attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)])
        
        attributedText.append(NSAttributedString(string: "\n\(dataStr)", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor(red: 155/255, green: 161/255, blue: 171/255, alpha: 1)]))
        
        let paragraphSytle = NSMutableParagraphStyle()
        paragraphSytle.lineSpacing = 4
        
        attributedText.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphSytle, range: NSMakeRange(0, attributedText.string.count))
        
        return attributedText
    }
    
}

class PostCell: UICollectionViewCell{
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let nameLabel: UILabel = {
        let n = UILabel()
        n.numberOfLines = 2
        return n
    }()
    
    let profileImageView: UIImageView = {
        let p = UIImageView()
        p.contentMode = .scaleAspectFit
        p.image = UIImage(named: "liam-neeson")
        return p
    }()
    
    var commentTextView: UITextView = {
       let c = UITextView()
       c.isEditable = false
       c.font = UIFont.systemFont(ofSize: 14)
       return c
    }()
    
    let postImageView: UIImageView = {
       let p = UIImageView()
       p.image = UIImage(named: "lionel_messi")
       p.contentMode = .scaleAspectFill
       p.layer.masksToBounds = true
       return p
    }()
    
    
    func setupViews(){
        backgroundColor = .white
        
        addSubview(nameLabel)
        addSubview(profileImageView)
        addSubview(commentTextView)
        addSubview(postImageView)
        
        addConstraintsWithFormat(format: "H:|-8-[v0(44)]-8-[v1]|", views: profileImageView, nameLabel)
        addConstraintsWithFormat(format: "H:|-4-[v0]-4-|", views: commentTextView)
        addConstraintsWithFormat(format: "H:|[v0]|", views: postImageView)
        
        addConstraintsWithFormat(format: "V:|-12-[v0]", views: nameLabel)
        addConstraintsWithFormat(format: "V:|-8-[v0(44)]-4-[v1(30)]-4-[v2]|", views: profileImageView, commentTextView, postImageView)
       
    }
    
}


extension UIView {
    func addConstraintsWithFormat(format: String, views: UIView...) {
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewsDictionary[key] = view
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: viewsDictionary))
    }
}

