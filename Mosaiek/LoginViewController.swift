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
        
        let permissions = ["email","public_profile","user_friends","user_photos"]
        
        //login with facebook
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions) {
            (user: PFUser?, error: NSError?) -> Void in
            if let user = user {
                if user.isNew {
                    print("User signed up and logged in through Facebook!")
                    self.getFacebookDetails();
                    
                } else {
                    print("User logged in through Facebook!")
                    self.getFacebookDetails();
                }
            } else {
                print("Uh oh. The user cancelled the Facebook login.")
            }
        }
       
    }
    
    // Login Actions
    func getFacebookDetails(){
        let this = self;
        
        if((FBSDKAccessToken.currentAccessToken()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).startWithCompletionHandler({ (connection, result, error) -> Void in
                let facebookDictionary:NSDictionary?
                if (error == nil){
                    facebookDictionary = result as? NSDictionary
                    
                    if let userInfo = facebookDictionary {
                        
                        if let profileName = userInfo.objectForKey("name"){
                            PFUser.currentUser()!["profileName"] = profileName;
                        }
                        
                        if let profilePic = userInfo.objectForKey("picture")?.objectForKey("data")?.objectForKey("url") {
                            //PFUser.currentUser()!["profilePic"] = profilePic;
                            PFUser.currentUser()!["profilePic"] = profilePic;
                        }
                        
                        PFUser.currentUser()!.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                            if (error != nil){
                                print("error", error);
                            } else {
                                print("Successfully saved user's facebook details", success);
                                 self.performSegueWithIdentifier("showTimeline", sender: this)
                            }
                           
                        })
                    }
                }
            })
        }
    }
    
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

