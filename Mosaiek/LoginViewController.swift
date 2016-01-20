//
//  ViewController.swift
//  Mosaiek
//
//  Created by Jonathan Schapiro on 1/19/16.
//  Copyright © 2016 Jonathan Schapiro. All rights reserved.
//

import UIKit
import ParseFacebookUtilsV4

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loginWithFacebook() {
        let this = self;
        let permissions = ["email","public_profile","user_friends","user_photos"]
        
        //login with facebook
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions) {
            (user: PFUser?, error: NSError?) -> Void in
            if let user = user {
                if user.isNew {
                    print("User signed up and logged in through Facebook!")
                    self.performSegueWithIdentifier("showTimeline", sender: this)
                } else {
                    print("User logged in through Facebook!")
                    self.performSegueWithIdentifier("showTimeline", sender: this)
                }
            } else {
                print("Uh oh. The user cancelled the Facebook login.")
            }
        }
       
    }
    
    // Login Actions
    
    
    // button handler for Login With Facebook
    @IBAction func userLogin(sender: AnyObject) {
        //user not already logged in
        if (PFUser.currentUser() == nil){
            self.loginWithFacebook()
            
        } else {
            print("User Already Logged In:", PFUser.currentUser()?.username)
            self.performSegueWithIdentifier("showTimeline", sender: self)
        }
    }

}

