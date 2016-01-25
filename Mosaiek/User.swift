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
    
    class func loadAllFriends(completion:(Array<PFObject>?)-> Void){
        //query the friends table where friend 1 = current user and status = 1
        //use include to get the user associated with the user pointer
        var friends:Array<PFObject>;
        
        //friend1 = current user
        let contributorsQuery = PFQuery(className: "Friends");
        contributorsQuery.whereKey("friend1", equalTo: PFUser.currentUser()!);
        contributorsQuery.whereKey("status", equalTo: 1);
        contributorsQuery.includeKey("friend2");// include data associated with friend2 user object
        
        //friend2 = current user
        let contributorsQuery1 = PFQuery(className: "Friends");
        contributorsQuery1.whereKey("friend2", equalTo: PFUser.currentUser()!);
        contributorsQuery1.whereKey("status", equalTo: 1);
        contributorsQuery1.includeKey("friend1"); // include data associated with friend1 user object
        
         friends = Array();
        
        contributorsQuery.findObjectsInBackgroundWithBlock { (friend2: [PFObject]?, error: NSError?) -> Void in
            
            if let friends2 = friend2{
                for friend in friends2{
                    friends.append(friend["friend2"] as! PFObject);
                }
            }
            
            if (error != nil){
                print (error)
            }
            
            contributorsQuery1.findObjectsInBackgroundWithBlock({ (friend1: [PFObject]?, error: NSError?) -> Void in
                
                if let friends1 = friend1{
                    for friend in friends1{
                         friends.append(friend["friend1"] as! PFObject);
                    }
                }
                
                completion(friends);
                
                if (error != nil){
                    print (error)
                }
                
            })
        }
        
        
    }
    
    class func saveFriends(users: Array<User>?,completion: (success: String?) -> Void) {
        
        if let friendsToSave = users {
            print ("saving \(friendsToSave.count) friends");
            
            
            for friend in friendsToSave {
                
                //find friend in Users table
                let friendsTable = PFObject(className: "Friends");
                
                let query:PFQuery = PFQuery(className: "_User");
                
                let friendQuery = query.whereKey("username", equalTo: friend.username!);
                
                friendQuery.getFirstObjectInBackgroundWithBlock({ (object: PFObject?,error: NSError?) -> Void in
                    
                    //save into friends table where user1 = current user and user2 = friend, status = 0
                    print("searching for user");
                    
                    if (object != nil){
                        
                        completion(success: "Friend Found \(object?.objectId)");
                        
                        friendsTable["friend1"] = PFUser.currentUser();
                        
                        friendsTable["friend2"] = object;
                        
                        friendsTable["status"] = 0;
                        
                        friendsTable.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                            if (success == true){
                                completion(success: "Friend relationship saved \(success)")
                                
                                //create new notification
                                let notification = Notification(user: object, type: 0, description: "You have a friend request from \(PFUser.currentUser()!["username"])", status: 0, sender: PFUser.currentUser(),mosaic:nil);
                                
                                notification.createNotification(); // race condition :(
                                
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
    
    class func getNotificiations(completion:(Array<PFObject>?)-> Void){
        
        let notificationsQuery = PFQuery(className: "Notifications");
        notificationsQuery.whereKey("user", equalTo: PFUser.currentUser()!);
        notificationsQuery.whereKey("status", equalTo: 0);
        
        notificationsQuery.findObjectsInBackgroundWithBlock { (notifications: [PFObject]?, error: NSError?) -> Void in
            
            if (error != nil){
                print("error:",error);
            }
            
            if (notifications != nil){
                completion(notifications);
            }
        }
        
    }
    
}