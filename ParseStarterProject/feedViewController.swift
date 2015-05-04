//
//  feedViewController.swift
//  instaGram
//
//  Created by Yuriy Shefer on 3/29/15.
//  Copyright (c) 2015 SHEFFcode. All rights reserved.
//

import UIKit
import Parse

class feedViewController: UITableViewController {
    
    //Mark: Titles and usernames.
    
    var titles = [String]()
    
    var userNames = [String]()
    
    var images = [UIImage]()
    
    var imageFiles = [PFFile]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        var followedUser = ""
        
        var getFollowedUsersQuery = PFQuery(className: "Followers")
        
        getFollowedUsersQuery.whereKey("Follower", equalTo:PFUser.currentUser()!.username!)
        
        getFollowedUsersQuery.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            if error == nil {
                
                if let objects = objects as? [PFObject] {
                for object in objects {
                    
                    followedUser = object["Following"] as! String
                    
                    var query = PFQuery(className:"Post")
                    query.whereKey("username", equalTo: followedUser)
                    query.findObjectsInBackgroundWithBlock {
                        (objects: [AnyObject]?, error: NSError?) -> Void in
                        if error == nil {
                            // The find succeeded.
                            println("Successfully retrieved \(objects!.count) scores.")
                            // Do something with the found objects
                            if let objects = objects as? [PFObject] {
                                for object in objects {
                                    println(object.objectId)
                                    
                                    self.titles.append(object["Title"] as! String)
                                    
                                    self.userNames.append(object["username"] as! String)
                                    
                                    self.imageFiles.append(object["imageFile"] as! PFFile)
                                    
                                    self.tableView.reloadData()
                                }
                            }
                        } else {
                            // Log details of the failure
                            println("Error: \(error) \(error!.userInfo!)")
                        }
                    }
                    
                }
                
            }
            }
            
        }
    }
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return titles.count
        
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 250
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var myCell:instaCell = self.tableView.dequeueReusableCellWithIdentifier("instaCell") as! instaCell
        
        myCell.title.text = titles[indexPath.row]
        
        myCell.userName.text = userNames[indexPath.row]
        
        imageFiles[indexPath.row].getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
            
            if error == nil {
                
                let image = UIImage(data: (imageData as NSData?)!)
                
                myCell.postedImage.image = image
                
            }
            
        }
        
        return myCell
        
    }
    
}
