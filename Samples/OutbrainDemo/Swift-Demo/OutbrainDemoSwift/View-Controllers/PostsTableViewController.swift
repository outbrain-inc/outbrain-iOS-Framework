//
//  ViewController.swift
//  OutbrainDemoSwift
//
//  Created by Oded Regev on 1/24/16.
//  Copyright © 2016 Oded Regev. All rights reserved.
//

import UIKit

class PostsTableViewController : UITableViewController {
    
    var posts = [Post]()
    
    let kNetowrkErrorMsg = "Unable to fetch articles from the server"
    let kShowArticleSegue = "ShowArticle"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        OBHelper.addOutbrainLogoTopBar(self)
        self.refreshPostsList()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshPostsList() {
       // let refreshStart = NSDate();
        self.refreshControl?.addTarget(self, action: #selector(PostsTableViewController.refresh(_:)), for: UIControlEvents.valueChanged)
        self.refreshControl?.beginRefreshing();
        
        OBNetworkManager.sharedInstance.loadPostsFromServer { (posts, error) -> Void in
            if posts != nil {
                // Success
                self.posts = posts!
                self.tableView.reloadData();
                self.refreshControl?.endRefreshing()
            }
            else {
                // Handle error
                OBHelper.displaySimpleAlert("Server Error", msg: self.kNetowrkErrorMsg, currentVC: self)
                
                self.refreshControl?.endRefreshing()
            }
        }        
}
    
    @objc func refresh(_ sender:AnyObject)
    {
        // Updating your data here...
        
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
}

extension PostsTableViewController {
    override func numberOfSections(in tableView: UITableView?) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as UITableViewCell;
        let post = self.posts[indexPath.row]

        cell.textLabel!.text = post.title
        cell.detailTextLabel!.text = post.summary.stringByStrippingHTML
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {        
        self.performSegue(withIdentifier: kShowArticleSegue, sender: indexPath);
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == kShowArticleSegue) {
            let destinationVC = segue.destination as! ArticleTableViewController
            let row = (sender as! IndexPath).row; //we know that sender is an NSIndexPath here.
            
            destinationVC.post = self.posts[row]
        }
    }
    
}


