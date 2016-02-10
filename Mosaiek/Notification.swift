//
//  Notification.swift
//  Mosaiek
//
//  Created by Jonathan Schapiro on 1/24/16.
//  Copyright © 2016 Jonathan Schapiro. All rights reserved.
//

import Foundation

class Notification {
    
    var user:PFObject?
    var type:Int?
    var description:String?
    var status:Int?
    var sender:PFObject?
    var mosaic:PFObject?
    
    init (user:PFObject?,type:Int?,description:String?,status:Int?,sender:PFObject?,mosaic:PFObject?){
        self.user = user;
        self.type = type;
        self.description = description;
        self.status = status;
        self.sender = sender; //if notification type is friendship
        self.mosaic = mosaic; //if notification type is contribution
    }
    
    func createNotification(){
        
        
        if (self.user != nil && self.type != nil && self.description != nil && self.status != nil){
            
            //check if notification already exists
            self.notificationExists({ (notificationExists) -> Void in
                if (notificationExists == true){
                    return;
                } else {
                    
                    // notification does not exist - create it
                    
                    let notificationTable = PFObject(className: "Notifications");
                    notificationTable["user"] = self.user;
                    notificationTable["type"] = self.type;
                    notificationTable["description"] = self.description;
                    notificationTable["status"] = self.status;
                    
                    if (self.mosaic != nil){
                        notificationTable["mosaic"] = self.mosaic;
                    }
                    
                    if (self.sender != nil){
                        notificationTable["sender"] = self.sender;
                    }
                    
                    print("Notification.swift - createNotification");
                    notificationTable.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                        
                        if (error != nil){
                            print("error:",error);
                        } else {
                            if (success == true){
                                print("Notification successfully created");
                            } else {
                                print("sucess",error);
                            }
                        }
                    })
                    
                }
            })
            
        }
      
    }
    
    func notificationExists(completion:(notificationExists:Bool)-> Void){
        let notificationQuery = PFQuery(className: "Notifications");
        notificationQuery.whereKey("user", equalTo:self.user!);
        notificationQuery.whereKey("type", equalTo: self.type!);
        notificationQuery.whereKey("description", equalTo: self.description!);
        
        print ("Notification.swift - notificationExists");
        
        notificationQuery.getFirstObjectInBackgroundWithBlock { (notification:PFObject?, error:NSError?) -> Void in
            if (error != nil){
                print("An error occurred in Notification.swift ",error);
            }
            if (notification != nil){
                completion(notificationExists: true);
            } else {
                completion(notificationExists: false);
            }
        }
        
    }
}