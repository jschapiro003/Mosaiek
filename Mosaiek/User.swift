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
                print("Successfully retrieved \(objects!.count) users.")
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
    
    class func saveFriends(users: Array<User>?,completion: (success: String?) -> Void) {
        
        if let friendsToSave = users {
            print ("saving \(friendsToSave.count) friends");
            
            
            
            for friend in friendsToSave {
                
                //find friend in Users table
                var friendsTable = PFObject(className: "Friends");
                
                var query:PFQuery = PFQuery(className: "_User");
                
                var friendQuery = query.whereKey("username", equalTo: friend.username!);
                
                friendQuery.getFirstObjectInBackgroundWithBlock({ (object: PFObject?,error: NSError?) -> Void in
                    
                    //save into friends table where user1 = current user and user2 = friend, status = 0
                    
                    if (object != nil){
                        
                        completion(success: "Friend Found \(object?.objectId)");
                        
                        friendsTable["friend1"] = PFUser.currentUser();
                        
                        friendsTable["friend2"] = object;
                        
                        friendsTable["status"] = 0;
                        
                        friendsTable.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                            if (success == true){
                                completion(success: "Friend relationship saved \(success)")
                            } else {
                                print(error)
                                completion(success: "Friend relationship could not be saved");
                            }
                        })
                        
                    } else {
                        
                        print(error);
                        completion(success: "Could not find friend to add");
                    }
                    
                    
                })
                
            }
        }

        
    }
    
}