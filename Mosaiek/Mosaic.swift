//
//  Mosaic.swift
//  Mosaiek
//
//  Created by Jonathan Schapiro on 1/19/16.
//  Copyright © 2016 Jonathan Schapiro. All rights reserved.
//

import Foundation

class Mosaic {
    
    var mosaicName:String?
    var mosaicDescription:String?
    var mosaicImage:NSData?
    var mosaicImageThumbnail:NSData?
    var mosaicCreator:PFUser?
    
    init(mosaicName:String?,mosaicDescription:String?,mosaicImage:NSData?,mosaicImageThumbnail:NSData?,mosaicCreator:PFUser?){
        self.mosaicName = mosaicName;
        self.mosaicDescription = mosaicDescription;
        self.mosaicImage = mosaicImage;
        self.mosaicImageThumbnail = mosaicImageThumbnail;
        self.mosaicCreator = mosaicCreator;
    }
    
    class func addContributors(mosaicName:String?,contributors:Array<PFUser>){
        
        //get mosaic objects to act as pointer
        var mosaicQuery = PFQuery(className: "Mosaic");
        
        if let name = mosaicName {
          mosaicQuery.whereKey("name", equalTo: name);
            
        } else {
            return;
        }
        
        mosaicQuery.getFirstObjectInBackgroundWithBlock { (mosaic:PFObject?, error:NSError?) -> Void in
            
            if (mosaic != nil){
                
                print("mosaic found");
                
                if (contributors.count > 0){
                    for contributor in contributors {
                        
                        let contributorsTable = PFObject(className: "Contributors");
                        contributorsTable["mosaic"] = mosaic;
                        contributorsTable["user"] = contributor;
                        contributorsTable["status"] = 0;
                        
                        contributorsTable.saveInBackgroundWithBlock({ (success: Bool, error:NSError?) -> Void in
                            if (error != nil){
                                print("error:",error);
                            } else {
                                print("success:",success);
                            }
                        })
                    }
                    
                }
                
            }
            
            if (error != nil){
                print(error);
            }
        
        }
        
        
    }
}
