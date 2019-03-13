//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Russell Wong on 3/6/19.
//  Copyright © 2019 Russell Wong. All rights reserved.
//

import UIKit
import Parse
import AlamofireImage
import MessageInputBar

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    let commentBar = MessageInputBar()
    var showsCommentBar = false
    var selectedPost: PFObject!
    
    var posts = [PFObject]() //create empty array
    //var refreshControl : UIRefreshControl! //for refresh
 
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        commentBar.inputTextView.placeholder = "Add a comment..."
        commentBar.sendButton.title = "Post"
        commentBar.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.keyboardDismissMode = .interactive
        
        let center = NotificationCenter.default //grab center
        center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil) //calls itself
        
        //refresh stuff:
//        refreshControl = UIRefreshControl()
//        refreshControl.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
//        tableView.insertSubview(refreshControl, at: 0)
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        //Create the comment
        let comment = PFObject(className: "Comments")
        comment["text"] = text
        comment["post"] = selectedPost
        comment["author"] = PFUser.current()
        
        selectedPost.add(comment, forKey: "comments") //add comment to post's newly created array/column "comments"
        
        selectedPost.saveInBackground{ (success, error) in
            if success {
                print("Comment saved")
            } else {
                print("Error saving comment")
            }
        }
        
        tableView.reloadData()
        
        //Clear and dismiss the input
        commentBar.inputTextView.text = nil
        
        showsCommentBar = false
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
    }
    
    @objc func keyboardWillBeHidden(note: Notification) {
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
    }
    
    override var inputAccessoryView: UIView? {
        return commentBar
    }
    
    override var canBecomeFirstResponder: Bool {
        return showsCommentBar
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let query = PFQuery(className:"Posts")
        query.includeKeys(["author","comments","comments.author"]) //this fetches the object from the pointer
        query.limit = 20
        query.findObjectsInBackground { (posts, error) in //get the query
            if posts != nil {
                self.posts = posts! //put into array
                self.tableView.reloadData() //refresh
            } else{
                
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let post = posts[section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        return comments.count + 2
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count //as many sections as there are posts
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell //to access the outlets

            let user = post["author"] as! PFUser
            cell.usernameLabel.text = user.username
            
            cell.captionLabel.text = post["caption"] as! String
            
            let imageFile = post["image"] as! PFFileObject
            let urlString = imageFile.url!
            let url = URL(string: urlString)!
            
            cell.photoView.af_setImage(withURL: url)
            
            return cell
        } else if indexPath.row <= comments.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
        
            let comment = comments[indexPath.row - 1]
            cell.commentLabel.text = comment["text"] as? String
            
            let user = comment["author"] as! PFUser
            cell.nameLabel.text = user.username
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!
            return cell
        }
    }
    
    //gets called when user taps on a row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        if indexPath.row == comments.count + 1 {
            showsCommentBar = true
            becomeFirstResponder()
            commentBar.inputTextView.becomeFirstResponder()
            
            selectedPost = post
        }
    }
    
    @IBAction func onLogoutButton(_ sender: Any) {
        PFUser.logOut() //clear Parse cache
        
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(withIdentifier: "LoginViewController")
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        
        delegate.window?.rootViewController = loginViewController
    }
    
    
//    @objc func onRefresh() {
//        //refresh block taken from viewDidAppear
//        let query = PFQuery(className:"Posts")
//        query.includeKey("author") //this fetches the object from the pointer
//        query.limit = 20
//        query.findObjectsInBackground { (posts, error) in //get the query
//            if posts != nil {
//                self.posts = posts! //put into array
//                self.tableView.reloadData() //refresh
//            } else{
//
//            }
//        }
//        //refresh block end
//
//        //calling the delay method
//        run(after: 2) {
//            self.refreshControl.endRefreshing()
//        }
//    }
//
//    // Implement the delay method
//    func run(after wait: TimeInterval, closure: @escaping () -> Void) {
//        let queue = DispatchQueue.main
//        queue.asyncAfter(deadline: DispatchTime.now() + wait, execute: closure)
//    }

}
