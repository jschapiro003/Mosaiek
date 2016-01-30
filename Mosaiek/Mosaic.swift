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
    
    class func getUsersMosaics(user:PFUser, completion: (mosaics: [PFObject]?) -> Void){
        //query mosaic table for mosaices where user = current user
        let mosaicsQuery = PFQuery(className: "Mosaic");
        mosaicsQuery.whereKey("user", equalTo: user);
        mosaicsQuery.includeKey("user");
        
        mosaicsQuery.findObjectsInBackgroundWithBlock { (mosaics:[PFObject]?, error:NSError?) -> Void in
            if (error != nil){
                print("error ", error)
            } else {
                if var usersMosaics = mosaics {
                    print("successfully retrieved users mosaics");
                   
                    self.getUsersContributedMosaics(user, completion: { (mosaics) -> Void in
                        if let contributedMosaics = mosaics {
                            for contributed in contributedMosaics {
                                usersMosaics.append(contributed);
                            }
                            completion(mosaics: usersMosaics);
                        }
                    })
                    
                }
            }
        }
        
    }
    
    class func getUsersContributedMosaics(user:PFUser,completion: (mosaics: [PFObject]?) -> Void){
        let contributedMosaicsQuery = PFQuery(className: "Contributors");
        contributedMosaicsQuery.whereKey("user", equalTo: user);
        contributedMosaicsQuery.whereKey("status", equalTo: 1);
        contributedMosaicsQuery.includeKey("mosaic");
        contributedMosaicsQuery.includeKey("user");
        
        
        contributedMosaicsQuery.findObjectsInBackgroundWithBlock { (mosaics:[PFObject]?, error:NSError?) -> Void in
            if (error != nil){
                print("error",error);
            } else {
                print ("successfully retrieved users contributed mosaics");
                print(mosaics);
                completion(mosaics: mosaics);
            }
        }
    }
    
    class func updateMosaicContributor(user:PFObject,mosaic:PFObject) {
        
        let mosaicContributorQuery = PFQuery(className:"Contributors"); //grab mosaic
        mosaicContributorQuery.whereKey("mosaic", equalTo: mosaic);
        mosaicContributorQuery.whereKey("user", equalTo: user);
        
        
        mosaicContributorQuery.getFirstObjectInBackgroundWithBlock { (contribution:PFObject?, error:NSError?) -> Void in
            if (error != nil){
                print("mosaic error: ",error);
            } else {
                if let contributionVal = contribution {
                    contributionVal["status"] = 1; //update contribution record
                    contributionVal.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                        if (error != nil){
                            print("error",error);
                        } else {
                            print("mosaic contributor updated: ",success);
                        }
                    })
                }
            }
        }
        
    }
    
    class func addContributors(mosaicName:String?,contributors:Array<PFUser>){
        
        //get mosaic objects to act as pointer
        let mosaicQuery = PFQuery(className: "Mosaic");
        
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
                                if (success == true){
                                    //send notification to contributor
                                    let notification = Notification(user: contributor, type: 1, description: "You have been invited to contribute to \(mosaic!["name"])", status: 0,sender:nil,mosaic:mosaic);
                                    
                                    notification.createNotification();
                                }
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
