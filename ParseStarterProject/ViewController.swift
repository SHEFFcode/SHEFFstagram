//
//  ViewController.swift
//
//  Copyright 2011-present Parse Inc. All rights reserved.
//

import UIKit
import Bolts
import Parse

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        println(PFUser.currentUser())
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if PFUser.currentUser() != nil {
            
            self.performSegueWithIdentifier("jumpToUserTable", sender: self)
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var signupActive = true
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    func displayAlert (title:String, error:String) {
        
        var alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
            
            self.dismissViewControllerAnimated(true, completion: nil)
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    @IBOutlet var signUpLabel: UILabel!
    
    @IBOutlet var submitButtonOutlet: UIButton!
    
    @IBAction func toggleSignup(sender: AnyObject) {
        
        if signupActive == true {
            
            signupActive = false
            
            signUpLabel.text = "Use the form below to log in"
            
            submitButtonOutlet.setTitle("Log In", forState: UIControlState.Normal)
            
            alreadyRegisteredOutlet.text = "Not registered?"
            
            signupToggleButtonOutlet.setTitle("Sign up", forState: UIControlState.Normal)
            
        } else {
            
            signupActive = true
            
            signUpLabel.text = "Use the form below to sign up"
            
            submitButtonOutlet.setTitle("Sign Up", forState: UIControlState.Normal)
            
            alreadyRegisteredOutlet.text = "Already registered?"
            
            signupToggleButtonOutlet.setTitle("Login", forState: UIControlState.Normal)
            
        }
        
    }
    
    @IBOutlet var signupToggleButtonOutlet: UIButton!
    
    @IBOutlet var username: UITextField!
    
    @IBOutlet var password: UITextField!
    
    @IBOutlet var alreadyRegisteredOutlet: UILabel!
    
    
    @IBAction func submitButton(sender: AnyObject) {
        
        var error = ""
        
        if username.text == "" || password.text == "" {
            
            error = "Please enter a username and password"
            
        }
        
        if error != "" {
            
            displayAlert("Error in form", error: error)
            
            
        } else {
            
            //MARK: Activity indicator.
            
            activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            
            
            //MARK: Toggle sign in / sign up in parse.
            
            if signupActive == true {
                
                var user = PFUser()
                user.username = username.text
                user.password = password.text
                
                user.signUpInBackgroundWithBlock {(succeeded: Bool, signupError: NSError?) -> Void in
                    self.activityIndicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    
                    if signupError == nil {
                        // Hooray! Let them use the app now.
                        
                        self.performSegueWithIdentifier("jumpToUserTable", sender: self)
                        
                    } else {
                        if let errorString = signupError!.userInfo?["error"] as? NSString {
                            
                            error = errorString as String
                            
                        } else {
                            
                            error = "Please try again later"
                            
                        }
                        // Show the errorString somewhere and let the user try again.
                        self.displayAlert("Could not sign up", error: error)
                        
                    }
                    
                }

                
            } else {
                
                PFUser.logInWithUsernameInBackground(username.text, password: password.text) { (user: PFUser?, signupError: NSError?) -> Void in
                    
                    self.activityIndicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    
                    if signupError == nil {
                        
                        //Mark: Perform a segue
                        
                        self.performSegueWithIdentifier("jumpToUserTable", sender: self)
                        
                        println("logged in")
                        
                    } else {
                        
                        if let errorString = signupError!.userInfo?["error"] as? NSString {
                            
                            error = errorString as String
                            
                        } else {
                            
                            error = "Please try again later"
                            
                        }
                        // Show the errorString somewhere and let the user try again.
                        self.displayAlert("Could not log in", error: error)
                        
                    }

                    }
            }
        }
    }
    
    //Mark: Navigation Bar Hiding / adding.
    
    override func viewWillAppear(animated: Bool) {
        
        self.navigationController?.navigationBarHidden = true
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        self.navigationController?.navigationBarHidden = false
        
    }
}

