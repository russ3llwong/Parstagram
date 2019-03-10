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

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var posts = [PFObject]() //create empty array
    var refreshControl : UIRefreshControl! //for refresh
 
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //refresh stuff:
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let query = PFQuery(className:"Posts")
        query.includeKey("author") //this fetches the object from the pointer
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
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell //to access the outlets
        
        let post = posts[indexPath.row]
        
        let user = post["author"] as! PFUser
        cell.usernameLabel.text = user.username
        
        cell.captionLabel.text = post["caption"] as! String
        
        let imageFile = post["image"] as! PFFileObject
        let urlString = imageFile.url!
        let url = URL(string: urlString)!
        
        cell.photoView.af_setImage(withURL: url)
        
        return cell
    }
    
    @objc func onRefresh() {
        //refresh block taken from viewDidAppear
        let query = PFQuery(className:"Posts")
        query.includeKey("author") //this fetches the object from the pointer
        query.limit = 20
        query.findObjectsInBackground { (posts, error) in //get the query
            if posts != nil {
                self.posts = posts! //put into array
                self.tableView.reloadData() //refresh
            } else{
                
            }
        }
        //refresh block end
        
        //calling the delay method
        run(after: 2) {
            self.refreshControl.endRefreshing()
        }
    }

    // Implement the delay method
    func run(after wait: TimeInterval, closure: @escaping () -> Void) {
        let queue = DispatchQueue.main
        queue.asyncAfter(deadline: DispatchTime.now() + wait, execute: closure)
    }

}
