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
        mosaicsQuery.orderByDescending("createdAt");
        
        print("beggining getUsers Mosaics");
        
        mosaicsQuery.findObjectsInBackgroundWithBlock { (mosaics:[PFObject]?, error:NSError?) -> Void in
            
            if (error != nil){
                print("error ", error)
            } else {
                
                if let usersMosaics = mosaics {
                    
                    print("successfully retrieved users mosaics");
                   
                    self.getUsersContributedMosaics(user, completion: { (mosaics) -> Void in
                        if let contributedMosaics = mosaics {
                            for contributed in contributedMosaics {
                                
                                if let contribMosaic = contributed["mosaic"] as? PFObject {
                                    Mosaic.getSingleMosaic(contribMosaic, completion: { (mosaic) -> Void in
                                        print("adding contributed mosaic",mosaic);
                                        completion(mosaics: [mosaic]);
                                    })
                                }
                                
                            }
                            completion(mosaics: usersMosaics);
                        } else {
                            completion(mosaics: usersMosaics);
                        }
                    })
                    
                }
            }
        }
        
    }
    
    class func getSingleMosaic(mosaic:PFObject,completion:(mosaic:PFObject)->Void) {
        let mosaicQuery = PFQuery(className: "Mosaic");
        mosaicQuery.whereKey("objectId", equalTo: mosaic.objectId!);
        mosaicQuery.includeKey("user");
        
        mosaicQuery.getFirstObjectInBackgroundWithBlock { (mosaic:PFObject?, error:NSError?) -> Void in
            if (error != nil){
                print("error ",error);
            }
            if let singleMosaic = mosaic {
                print("successfuly retrieved single mosaic");
                completion(mosaic: singleMosaic);
            }
        }
    
    }
    
    
    
    class func getUsersContributedMosaics(user:PFUser,completion: (mosaics: [PFObject]?) -> Void){
        let contributedMosaicsQuery = PFQuery(className: "Contributors");
        contributedMosaicsQuery.whereKey("user", equalTo: user);
        contributedMosaicsQuery.whereKey("status", equalTo: 1);
        contributedMosaicsQuery.orderByDescending("createdAt");
        contributedMosaicsQuery.includeKey("mosaic");
        contributedMosaicsQuery.includeKey("user");
        
        print("getting contributed mosaics");
        
        contributedMosaicsQuery.findObjectsInBackgroundWithBlock { (mosaics:[PFObject]?, error:NSError?) -> Void in
            if (error != nil){
                print("error",error);
            } else {
                print ("successfully retrieved contributed mosaics");
                completion(mosaics: mosaics);
            }
        }
    }
    
    class func updateMosaicContributor(user:PFObject,mosaic:PFObject) {
        
        let mosaicContributorQuery = PFQuery(className:"Contributors"); //grab mosaic
        mosaicContributorQuery.whereKey("mosaic", equalTo: mosaic);
        mosaicContributorQuery.whereKey("user", equalTo: user);
        mosaicContributorQuery.whereKey("status", equalTo: 0); //status must be 0
        
        print("begginning update mosaic contributor");
        
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
                            //update mosaics contributors
                            if let contributorsCount = mosaic["contributorsCount"] as? Int {
                                mosaic["contributorsCount"] = contributorsCount + 1;
                                mosaic.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                                    if (error != nil){
                                        print("error ",error);
                                    } else {
                                        print("mosaci contributors count updated: ",success);
                                    }
                                })
                            }
                        }
                    })
                }
            }
        }
        
    }
    
    class func addContributors(mosaicName:String?,contributors:Array<PFUser>){
        
        //get mosaic objects to act as pointer **** Refactor to use mosaic not mosaic name
        let mosaicQuery = PFQuery(className: "Mosaic");
        
        if let name = mosaicName {
          mosaicQuery.whereKey("name", equalTo: name);
            
        } else {
            return;
        }
        
        print("begginning add contributors");
        mosaicQuery.getFirstObjectInBackgroundWithBlock { (mosaic:PFObject?, error:NSError?) -> Void in
            
            if (mosaic != nil){
                
                print("mosaic found");
                
                if (contributors.count > 0){
                    for contributor in contributors {
                        
                        //check if contributor relationship exists
                        
                        let contributorsQuery = PFQuery(className: "Contributors");
                        contributorsQuery.whereKey("mosaic", equalTo: mosaic!);
                        contributorsQuery.whereKey("user",equalTo: contributor);
                        
                        contributorsQuery.getFirstObjectInBackgroundWithBlock({ (contributorRelationship:PFObject?, error:NSError?) -> Void in
                            
                            if (error != nil){
                                print("error: ",error);
                            }
                                
                                if contributorRelationship != nil {
                                    print("relationship already exists");
                                    return;
                                } else {
                                    
                                    //relationship does not exist - add it
                                    
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
                            
                        })
                        
                    }
                    
                }
                
            }
            
            if (error != nil){
                print(error);
            }
        
        }
        
    }
    
    class func likeMosaic(mosaic:PFObject){
        
        //query likes table for like relationship
        //if exists return
        //else create the relationship and increment that mosaics likes
        let likesQuery = PFQuery(className: "Likes");
        likesQuery.whereKey("mosaic", equalTo: mosaic);
        likesQuery.whereKey("user", equalTo: PFUser.currentUser()!);
        
        likesQuery.getFirstObjectInBackgroundWithBlock { (like:PFObject?, error:NSError?) -> Void in
            
            if (error != nil){
                
                print("error: ",error);
                
            }
                
            if (like != nil){
                print("like exists");
                return;
                
            } else {
                
                let likeSave = PFObject(className: "Likes");
                
                likeSave["user"] = PFUser.currentUser()!;
                likeSave["mosaic"] = mosaic;
                
                likeSave.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                    
                    if (error != nil){
                        print("error: ",error);
                    } else {
                        print("saved like save", success);
                    }
                })
                
                if let mosaicLikes = mosaic["likes"] as? Int {
                    mosaic["likes"] = mosaicLikes + 1;
                }
                
                mosaic.saveInBackgroundWithBlock { (success:Bool, error:NSError?) -> Void in
                    if (error != nil){
                        print("error: ",error);
                    } else {
                        print("successfully liked mosaic",success);
                    }
                }
                
            }
        }
        
        
    }
    
    class func isOwner(mosaic:PFObject,completion:(owner:Bool)->Void){
        
        let isOwnerQuery = PFQuery(className: "Mosaic");
        isOwnerQuery.whereKey("objectId", equalTo: mosaic.objectId!);
        isOwnerQuery.whereKey("user", equalTo: PFUser.currentUser()!);
        
        isOwnerQuery.getFirstObjectInBackgroundWithBlock { (owner:PFObject?, error:NSError?) -> Void in
            
            if (error != nil) {
                
                print("error ",error);
            }
            
            if (owner != nil) {
                
                print("current user is the owner of this mosaic");
                completion(owner: true);
            } else {
                print("current users is NOT owner of this mosaic");
                completion(owner:false);
            }
        }
    }
    
    class func hasLikedMosaic(mosaic:PFObject,completion:(liked:Bool)->Void){
        let likesQuery = PFQuery(className: "Likes");
        likesQuery.whereKey("mosaic", equalTo: mosaic);
        likesQuery.whereKey("user", equalTo: PFUser.currentUser()!);
        
        
        likesQuery.getFirstObjectInBackgroundWithBlock { (like:PFObject?, error:NSError?) -> Void in
            if (error != nil){
                print("error ",error);
            }
            
            if (like != nil){
                completion(liked: true);
            } else {
                completion(liked:false);
            }
        }
    }
    
    class func updateContributorCount(mosaic:PFObject,completion:(count:Int)->Void){
        
        let contributorCountQuery = PFQuery(className: "Contributors");
        contributorCountQuery.whereKey("mosaic", equalTo: mosaic);
        contributorCountQuery.whereKey("status", equalTo: 1);
        
        contributorCountQuery.countObjectsInBackgroundWithBlock { (count:Int32, error:NSError?) -> Void in
            if (error != nil){
                print("error ",error);
            }
            
            mosaic["contributorsCount"] = Int(count);
            mosaic.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                if (error != nil){
                    print("error ",error);
                }
                print("mosaic contributor count updated");
                completion(count: Int(count));
                
            })
        }
    }
    
    class func editMosaic(mosaic:PFObject,mosaicName:String,mosaicDescription:String,completion:(success:Bool)->Void){
        
        mosaic["name"] = mosaicName;
        mosaic["description"] = mosaicDescription;
        
        mosaic.saveInBackgroundWithBlock { (success:Bool, error:NSError?) -> Void in
            if (error != nil){
                print("error ",error);
            }
            
            if (success != true){
                print("mosaic could not be updated");
                completion(success: false);
            } else {
                print("mosaic succesfully updated");
                completion(success:true);
            }
        }
    }
    
    class func getMosaicContributorsWithLimit(mosaic:PFObject,completion:(contributors:[PFObject]?)-> Void){
        let mosaicContributorsQuery = PFQuery(className: "Contributors");
        mosaicContributorsQuery.whereKey("mosaic", equalTo: mosaic);
        mosaicContributorsQuery.limit = 10;
        mosaicContributorsQuery.includeKey("user");
        
        mosaicContributorsQuery.findObjectsInBackgroundWithBlock { (results:[PFObject]?, error:NSError?) -> Void in
            if (error != nil){
                print("error ",error);
            }
            print("Got \(results!.count) contributors for \(mosaic["name"])")
            completion(contributors: results);
        }
        
    }
}
