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
        print("here", self.sender, self.mosaic);
        if (self.user != nil && self.type != nil && self.description != nil && self.status != nil){
            print("hoping here");
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
            
            notificationTable.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                print("attempting to save a notification");
                if (error != nil){
                    print("error:",error);
                } else {
                    print("success:",success);
                    if (success == true){
                        print("Notification successfully created");
                    } else {
                        print("sucess",error);
                    }
                }
            })
        }
      
        
    }
}