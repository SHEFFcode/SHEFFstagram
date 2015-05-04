//
//  postViewController.swift
//  instaGram
//
//  Created by Yuriy Shefer on 3/27/15.
//  Copyright (c) 2015 SHEFFcode. All rights reserved.
//

import Foundation
import UIKit
import Parse

class postViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    func displayAlert (title:String, error:String) {
        
        var alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
            
            self.dismissViewControllerAnimated(true, completion: nil)
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    var photoSelected: Bool = false
    
    @IBOutlet var imageToPost: UIImageView!
    
    @IBAction func logout(sender: AnyObject) {
        
        PFUser.logOut()
        
        self.performSegueWithIdentifier("logout", sender: self)
        
    }
    @IBAction func chooseImage(sender: AnyObject) {
        
        var image = UIImagePickerController()
        
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        image.allowsEditing = false
        
        self.presentViewController(image, animated: true, completion: nil)
        
    }
    
    @IBOutlet var shareText: UITextField!
    
    @IBOutlet var postImage: UIButton!
    
    @IBAction func postImageButton(sender: AnyObject) {
        
        var error = ""
        
        if photoSelected == false {
            
            error = "please select an image to post"
            
        } else if shareText.text == "" {
            
            error = "Please enter a message"
            
        }
        
        if error != "" {
            
            displayAlert("Cannot post image.", error: error)
            
        } else {
            
            activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            
            var post = PFObject(className: "Post")
            
            post["Title"] = shareText.text
            
            post["username"] = PFUser.currentUser()!.username
            
            post.saveInBackgroundWithBlock{(sucess:Bool, error: NSError?) -> Void in
                
                if sucess == false {
                    
                    self.displayAlert("Could not post image", error: "Please try again later")
                    
                    
                } else {
                    
                    let imageData = UIImagePNGRepresentation(self.imageToPost.image)
                    
                    let imageFile = PFFile(name: "Image.png", data: imageData)
                    
                    post["imageFile"] = imageFile
                    
                    post.saveInBackgroundWithBlock{(sucess:Bool, error: NSError?) -> Void in
                        
                        if sucess == false {
                            
                            self.activityIndicator.stopAnimating()
                            UIApplication.sharedApplication().endIgnoringInteractionEvents()
                            
                            self.displayAlert("Could not post image", error: "Please try again later")
                            
                            
                        } else {
                            
                            self.activityIndicator.stopAnimating()
                            UIApplication.sharedApplication().endIgnoringInteractionEvents()
                            
                            self.photoSelected = false
                            
                            self.imageToPost.image = UIImage(named: "placeholder.png")
                            
                            self.shareText.text = ""
                            
                            self.displayAlert("Image Posted", error: "Your image has been posted sucessfully")
                            
                        }
                    }
                }
                
            }
            
            
        }
        
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        
        println("Image selected")
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        imageToPost.image = image
        
        
        photoSelected = true
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        photoSelected = false
        
        imageToPost.image = UIImage(named: "placeholder.png")
        
        shareText.text = ""
        
        println(PFUser.currentUser()!.password)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}
