//
//  User.swift
//  Mosaiek
//
//  Created by Jonathan Schapiro on 1/19/16.
//  Copyright © 2016 Jonathan Schapiro. All rights reserved.
//

import Foundation

class User {
    
    let username:String?
    
    init(username:String?){
        
        self.username = username;
    }
    
    class func loadAllUsers(completion:(Array<User>)-> Void) {
        
        let query = PFQuery(className: "_User");
        var users:Array<User> = [];
        
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) scores.")
                // Do something with the found objects
                if let objects = objects {
                    for object in objects {
                        
                        let user = User(username: object["username"] as? String);
                        
                        users.append(user);
                    }
                    
                    completion(users);
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
        
        
    }
    
}