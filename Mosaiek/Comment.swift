//
//  Comment.swift
//  Mosaiek
//
//  Created by Jonathan Schapiro on 1/19/16.
//  Copyright © 2016 Jonathan Schapiro. All rights reserved.
//

import Foundation

class Comment {
    
    class func saveComment(mosaicImage:PFObject,comment:String,completion:(success:String,comment:PFObject)->Void){
        
        let commentsTable = PFObject(className: "Comments");
        commentsTable["mosaicImage"] = mosaicImage;
        commentsTable["user"] = PFUser.currentUser()!;
        commentsTable["comment"] = comment;
        commentsTable["likes"] = 0;
        
        commentsTable.saveInBackgroundWithBlock { (success:Bool, error:NSError?) -> Void in
           
            if (error != nil){
               
                print("error: ", error);
                
            } else {
                
                completion(success: "Successfully saved comment" + String(success),comment: commentsTable);
            }
        }
        
    }
    
    class func getUserComments(mosaicImage:PFObject,completion:(comments:[PFObject]?)->Void) {
        
        let commentQuery = PFQuery(className: "Comments");
        
        commentQuery.whereKey("mosaicImage", equalTo: mosaicImage);
        commentQuery.includeKey("user");
        
        commentQuery.findObjectsInBackgroundWithBlock { (comments:[PFObject]?, error:NSError?) -> Void in
            
            if (error != nil) {
                print("error: ", error);
                
            } else {
                
                completion(comments: comments);
            }
        }
    }
    
}
