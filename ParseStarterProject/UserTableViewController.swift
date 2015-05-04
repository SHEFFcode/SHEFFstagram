//
//  UserTableViewController.swift
//  ParseStarterProject
//
//  Created by Yuriy Shefer on 5/3/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class UserTableViewController: UITableViewController {
    
    var users = [""]
    
    var Following = [Bool]()
    
    var refresher: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        updateUsers()
        
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refresher)
        
    }
    
    func updateUsers() {
        
        var query = PFUser.query()
        
        query!.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]?, error: NSError?) -> Void in
            
            self.users.removeAll(keepCapacity: true)
            
            if let objects = objects as? [PFObject] {
                for object in objects {for object in objects {
                
                var user: PFUser = object as! PFUser
                
                var isFollowing: Bool
                
                if user.username != PFUser.currentUser()!.username {
                    
                    self.users.append(user.username!)
                    
                    isFollowing = false
                    
                    var query = PFQuery(className:"Followers")
                    
                    query.whereKey("Follower", equalTo:PFUser.currentUser()!.username!)
                    query.whereKey("Following", equalTo:user.username!)
                    
                    query.findObjectsInBackgroundWithBlock {
                        
                        (objects: [AnyObject]?, error: NSError?) -> Void in
                        
                        if error == nil {
                            // The find succeeded.
                            println("Successfully retrieved \(objects!.count) scores.")
                            // Do something with the found objects
                            if let objects = objects as? [PFObject] {
                                
                                for object in objects {
                                    
                                    isFollowing = true
                                    
                                }
                                
                                self.Following.append(isFollowing)
                                
                                self.tableView.reloadData()
                                
                            }
                            
                        } else {
                            // Log details of the failure
                            println("Error: \(error) \(error!.userInfo!)")
                            
                        }
                        
                        self.refresher.endRefreshing()
                        
                    }
                    
                }
                    }
                
            }
            }
            
        })
        
        
    }
    
    
    func refresh() {
        
        println("refreshed")
        
        updateUsers()
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return users.count
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell
        
        if Following.count > indexPath.row {
            
            
            if Following[indexPath.row] {
                
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                
            }
        }
        
        cell.textLabel?.text = users[indexPath.row]
        
        return cell
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var cell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        
        if cell.accessoryType == UITableViewCellAccessoryType.Checkmark {
            
            cell.accessoryType = UITableViewCellAccessoryType.None
            
            //MARK: PF Query
            var query = PFQuery(className:"Followers")
            
            query.whereKey("Follower", equalTo:PFUser.currentUser()!.username!)
            query.whereKey("Following", equalTo:cell.textLabel!.text!)
            
            query.findObjectsInBackgroundWithBlock {
                
                (objects: [AnyObject]?, error: NSError?) -> Void in
                
                if error == nil {
                    // The find succeeded.
                    println("Successfully retrieved \(objects!.count) scores.")
                    // Do something with the found objects
                    if let objects = objects as? [PFObject] {
                        
                        for object in objects {
                            
                            object.delete()
                            
                        }
                        
                    }
                    
                } else {
                    // Log details of the failure
                    println("Error: \(error) \(error!.userInfo!)")
                    
                }
            }
            
            
        } else {
            
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            
            var Following = PFObject(className: "Followers")
            
            Following["Following"] = cell.textLabel?.text
            Following["Follower"] = PFUser.currentUser()!.username
            
            
            Following.save()
        }
        
    }
    
}