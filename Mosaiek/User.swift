//
//  User.swift
//  Mosaiek
//
//  Created by Jonathan Schapiro on 1/19/16.
//  Copyright © 2016 Jonathan Schapiro. All rights reserved.
//

import Foundation

class User {
    
    let userObject:PFObject?
    let username:String?
    let profilePic:String?
    
    init(username:String?,profilePic:String?, userObject:PFObject?){
        
        self.username = username;
        self.profilePic = profilePic;
        self.userObject = userObject;
    }
    
    class func confirmFriendRequest(user:PFObject,friend:PFObject){
        
        //f1-user && f1=friend OR f1= user && f2 = friend, OR f2 = user && f1 = friend, OR f2 = user && f2 = friend
        //http://stackoverflow.com/questions/27893758/parse-compound-queries-with-or-and-and
        
        let friendQuery1 = PFQuery(className: "Friends");
        friendQuery1.whereKey("friend1", equalTo: user);
        friendQuery1.whereKey("friend1", equalTo: friend);
        
        let friendQuery2 = PFQuery(className: "Friends");
        friendQuery2.whereKey("friend1", equalTo: user);
        friendQuery2.whereKey("friend2", equalTo: friend);
        
        let friendQuery3 = PFQuery(className: "Friends");
        friendQuery3.whereKey("friend2", equalTo: user);
        friendQuery3.whereKey("friend1", equalTo: friend);
        
        let friendQuery4 = PFQuery(className: "Friends");
        friendQuery4.whereKey("friend2", equalTo: user);
        friendQuery4.whereKey("friend2", equalTo: friend);
        
        let finalFriendQuery = PFQuery.orQueryWithSubqueries([friendQuery1,friendQuery2,friendQuery3,friendQuery4]);
        
        print("User.swift - confirmFriendRequest");
        
        finalFriendQuery.findObjectsInBackgroundWithBlock { (friendRelations:[PFObject]?, error:NSError?) -> Void in
            
            if (error != nil){
                
                print("An error occurred at User.swift - confirmFriendRequest ",error);
            } else {
                
                if let friendships = friendRelations {
                    
                    for friendship in friendships {
                        
                        friendship["status"] = 1;
                        
                        friendship.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                            if (error != nil){
                                print("An error occurrred at User.swift - confirmFriendRequest ",error!.code);
                            } else {
                                //print("friendship successfully formed",success);
                            }
                        })
                    }
                }
            }
        }
        
        
    }
    
    class func loadAllUsers(completion:(Array<User>)-> Void) {
        
        let query = PFQuery(className: "_User");
        var users:Array<User> = [];
        
        print("User.swift - loadAllUsers");
        
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                
                // The find succeeded.
                // Do something with the found objects
                if let objects = objects {
                    for object in objects {
                        if let name = object["profileName"] as? String{
                            print("name",name)
                            var user:User?
                            if let picture = object["profilePic"] as? String{
                                user = User(username: name,profilePic: picture,userObject: object);
                            }else {
                                user = User(username: name,profilePic: nil, userObject: object);
                            }
                            
                            if let newUser = user {
                                users.append(newUser);
                            }
                        }
                        
                    }
                    
                    completion(users);
                }
            } else {
                // Log details of the failure
                print("An error occurred in User.swift - loadAllUsers ", error!.code);
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
        
        print("User.swift - loadAllFriends");
        
        contributorsQuery.findObjectsInBackgroundWithBlock { (friend2: [PFObject]?, error: NSError?) -> Void in
            
            if let friends2 = friend2{
                for friend in friends2{
                    friends.append(friend["friend2"] as! PFObject);
                }
            }
            
            if (error != nil){
                print ("An error occurred in User.swift - loadAllFriends ",error!.code);
            }
            
            contributorsQuery1.findObjectsInBackgroundWithBlock({ (friend1: [PFObject]?, error: NSError?) -> Void in
                
                if let friends1 = friend1{
                    for friend in friends1{
                         friends.append(friend["friend1"] as! PFObject);
                    }
                }
                
                completion(friends);
                
                if (error != nil){
                    print ("An error occurred in User.swift - loadAllFriends ", error!.code)
                }
                
            })
        }
        
        
    }
    
    class func saveFriends(users: Array<User>?,completion: (success: String?) -> Void) {
        
        if let friendsToSave = users {
           
            print("User.swift - saveFriends");
            
            for friend in friendsToSave {
                
                //find friend in Users table
                let friendsTable = PFObject(className: "Friends");
                
                let query:PFQuery = PFQuery(className: "_User");
                
                if let friendObject = friend.userObject {
                    
                    let friendQuery = query.whereKey("objectId", equalTo: friendObject.objectId!);
                    
                    friendQuery.getFirstObjectInBackgroundWithBlock({ (object: PFObject?,error: NSError?) -> Void in
                        
                        //check if friend relationship already exists
                        let friendRelationshipQuery = PFQuery(className: "Friends");
                        friendRelationshipQuery.whereKey("friend1", equalTo: PFUser.currentUser()!);
                        friendRelationshipQuery.whereKey("friend2", equalTo: object!);
                        
                        
                        friendRelationshipQuery.getFirstObjectInBackgroundWithBlock({ (friendRelationship:PFObject?, error:NSError?) -> Void in
                            if (error != nil) {
                                print("An error occurred in User.swift - saveFriends ", error);
                            }
                            if (friendRelationship != nil) {
                                
                                return;
                                
                            } else {
                                
                                //save into friends table where user1 = current user and user2 = friend, status = 0
                                if (object != nil){
                                    
                                    completion(success: "Friend Found \(object?.objectId)");
                                    
                                    friendsTable["friend1"] = PFUser.currentUser();
                                    
                                    friendsTable["friend2"] = object; //friend to add
                                    
                                    friendsTable["status"] = 0;
                                    
                                    friendsTable.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                                        if (success == true){
                                            
                                            //create new notification
                                            let notification = Notification(user: object, type: 0, description: "You have a friend request from \(PFUser.currentUser()!["profileName"])", status: 0, sender: PFUser.currentUser(),mosaic:nil);
                                            
                                            notification.createNotification(); // race condition :(
                                            
                                        } else {
                                            print("An error occured in User.swift - saveFriends ", error!.code);
                                            completion(success: "Friend relationship could not be saved");
                                        }
                                    })
                                    
                                } else {
                                    
                                    print("An error occured in User.swift - saveFriends ", error!.code);
                                    completion(success: "Could not find friend to add");
                                }
                                
                            }
                        })
                        
                    })
                    
                }
            }
                
        }

        
    }
    
    class func getNotificiations(completion:(Array<PFObject>?)-> Void){
        
        let notificationsQuery = PFQuery(className: "Notifications");
        notificationsQuery.whereKey("user", equalTo: PFUser.currentUser()!);
        notificationsQuery.whereKey("status", equalTo: 0);
        notificationsQuery.includeKey("sender");
        notificationsQuery.includeKey("mosaic");
        
        print("User.swift - getNotifications");
        
        notificationsQuery.findObjectsInBackgroundWithBlock { (notifications: [PFObject]?, error: NSError?) -> Void in
            
            if (error != nil){
                print("An error occurred in User.swift - getNotifications ",error!.code);
            }
            
            if (notifications != nil){
                completion(notifications);
            }
        }
        
    }
    
    class func isFriends(user1:PFObject,user2:PFObject,completion:(isFriend:Bool)-> Void) {
        
        let friendQuery1 = PFQuery(className: "Friends");
        friendQuery1.whereKey("friend1", equalTo: user1);
        friendQuery1.whereKey("friend2", equalTo: user2);
        friendQuery1.whereKey("status", equalTo: 1);
        
        let friendQuery2 = PFQuery(className: "Friends");
        friendQuery2.whereKey("friend1", equalTo: user2);
        friendQuery2.whereKey("friend2", equalTo: user1);
        friendQuery2.whereKey("status", equalTo: 1);
        
        let finalFriendQuery = PFQuery.orQueryWithSubqueries([friendQuery1,friendQuery2]);
        
        print("User.swift - isFriends");
        
        finalFriendQuery.getFirstObjectInBackgroundWithBlock { (friendship:PFObject?, error:NSError?) -> Void in
            if (error != nil) {
                
                print("An error occurred in  User.swift - isFriends ", error!.code);
                
            } else {
                
                if (friendship != nil){
                    completion(isFriend: true);
                    
                } else {
                    
                    completion(isFriend:false);
                }
                
            }
        }
        
    }
    
}