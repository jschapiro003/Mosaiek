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
    
    init (user:PFObject?,type:Int?,description:String?,status:Int?){
        self.user = user;
        self.type = type;
        self.description = description;
        self.status = status;
    }
    
    func createNotification(){
        if (self.user != nil && self.type != nil && self.description != nil && self.status != nil){
            let notificationTable = PFObject(className: "Notifications");
            notificationTable["user"] = self.user;
            notificationTable["type"] = self.type;
            notificationTable["description"] = self.description;
            notificationTable["status"] = self.status;
            
            notificationTable.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                if (error != nil){
                    print("error:",error);
                } else {
                    print("success:",success);
                    if (success == true){
                        print("Notification successfully created");
                    }
                }
            })
        }
      
        
    }
}