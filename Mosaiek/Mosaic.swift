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
        
        print("Mosaic.swift - getUsersMosaics");
        
        mosaicsQuery.findObjectsInBackgroundWithBlock { (mosaics:[PFObject]?, error:NSError?) -> Void in
            
            if (error != nil){
                print("An error occurred in Mosaic.swift - getUsersMosaics ", error!.code)
            } else {
                
                if let usersMosaics = mosaics {
                   
                    self.getUsersContributedMosaics(user, completion: { (mosaics) -> Void in
                        if let contributedMosaics = mosaics {
                            for contributed in contributedMosaics {
                                
                                if let contribMosaic = contributed["mosaic"] as? PFObject {
                                    Mosaic.getSingleMosaic(contribMosaic, completion: { (mosaic) -> Void in
                                        
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
        
        print("Mosaic.swift - getSingleMosaic");
        
        mosaicQuery.getFirstObjectInBackgroundWithBlock { (mosaic:PFObject?, error:NSError?) -> Void in
            if (error != nil){
                print("An error occurred in Mosaic.swift - getSingleMosaic ",error!.code);
            }
            if let singleMosaic = mosaic {
                
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
        
        print("Mosaic.swift- getUsersContributedMosaics");
        
        contributedMosaicsQuery.findObjectsInBackgroundWithBlock { (mosaics:[PFObject]?, error:NSError?) -> Void in
            if (error != nil){
                print("An error occurred in Mosaic.swift- getUsersContributedMosaics ",error!.code);
            } else {
                
                completion(mosaics: mosaics);
            }
        }
    }
    
    class func updateMosaicContributor(user:PFObject,mosaic:PFObject) {
        
        let mosaicContributorQuery = PFQuery(className:"Contributors"); //grab mosaic
        mosaicContributorQuery.whereKey("mosaic", equalTo: mosaic);
        mosaicContributorQuery.whereKey("user", equalTo: user);
        mosaicContributorQuery.whereKey("status", equalTo: 0); //status must be 0
        
        print("Mosaic.swift- updateMosaicContributor");
        
        mosaicContributorQuery.getFirstObjectInBackgroundWithBlock { (contribution:PFObject?, error:NSError?) -> Void in
            if (error != nil){
                print("An error occurred in Mosaic.swift- updateMosaicContributor ",error!.code);
            } else {
                if let contributionVal = contribution {
                    contributionVal["status"] = 1; //update contribution record
                    contributionVal.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                        if (error != nil){
                            print("An error occurred in Mosaic.swift- updateMosaicContributor ",error);
                        } else {
                            
                            //update mosaics contributors
                            if let contributorsCount = mosaic["contributorsCount"] as? Int {
                                mosaic["contributorsCount"] = contributorsCount + 1;
                                mosaic.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                                    if (error != nil){
                                        print("An error occurred in Mosaic.swift- updateMosaicContributor ",error!.code);
                                    } else {
                                        
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
        
        print("Mosaic.swift - addContributors");
        
        mosaicQuery.getFirstObjectInBackgroundWithBlock { (mosaic:PFObject?, error:NSError?) -> Void in
            
            if (mosaic != nil){
                
                if (contributors.count > 0){
                    for contributor in contributors {
                        
                        //check if contributor relationship exists
                        
                        let contributorsQuery = PFQuery(className: "Contributors");
                        contributorsQuery.whereKey("mosaic", equalTo: mosaic!);
                        contributorsQuery.whereKey("user",equalTo: contributor);
                        
                        contributorsQuery.getFirstObjectInBackgroundWithBlock({ (contributorRelationship:PFObject?, error:NSError?) -> Void in
                            
                            if (error != nil){
                                print("An error occurred in Mosaic.swift - addContributors: ",error!.code);
                            }
                                
                                if contributorRelationship != nil {
                                    return;
                                } else {
                                    
                                    //relationship does not exist - add it
                                    
                                    let contributorsTable = PFObject(className: "Contributors");
                                    contributorsTable["mosaic"] = mosaic;
                                    contributorsTable["user"] = contributor;
                                    contributorsTable["status"] = 0;
                                    
                                    contributorsTable.saveInBackgroundWithBlock({ (success: Bool, error:NSError?) -> Void in
                                        if (error != nil){
                                            print("An error occurred in Mosaic.swift - addContributors:",error);
                                        } else {
                                           
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
                print("Mosaic.swift - addContributors ",error);
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
        
        print ("Mosaic.swift - likeMosaic");
        likesQuery.getFirstObjectInBackgroundWithBlock { (like:PFObject?, error:NSError?) -> Void in
            
            if (error != nil){
                
                print("An error occurred in Mosaic.swift - likeMosaic: ",error!.code);
                
            }
                
            if (like != nil){
                return;
                
            } else {
                
                let likeSave = PFObject(className: "Likes");
                
                likeSave["user"] = PFUser.currentUser()!;
                likeSave["mosaic"] = mosaic;
                
                likeSave.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                    
                    if (error != nil){
                        print("An error occurred in Mosaic.swift - likeMosaic: ",error!.code);
                    } else {
                        
                    }
                })
                
                if let mosaicLikes = mosaic["likes"] as? Int {
                    mosaic["likes"] = mosaicLikes + 1;
                }
                
                mosaic.saveInBackgroundWithBlock { (success:Bool, error:NSError?) -> Void in
                    if (error != nil){
                        print("An error occurred in Mosaic.swift - likeMosaic: ",error!.code);
                    } else {
                       
                    }
                }
                
            }
        }
        
        
    }
    
    class func removeLike(mosaic:PFObject,completion:(success:Bool)->Void){
        
        let like = PFQuery(className: "Likes");
        like.whereKey("mosaic", equalTo: mosaic);
        like.whereKey("user", equalTo: PFUser.currentUser()!);
        
        print ("Mosaic.swift - removeLike");
        
        like.getFirstObjectInBackgroundWithBlock { (likeRecord:PFObject?, error:NSError?) -> Void in
            if (error != nil){
                print("An error occurred in Mosaic.swift - removeLike ", error);
            }
            if let lR = likeRecord {
                lR.deleteInBackgroundWithBlock({ (deleted:Bool, error:NSError?) -> Void in
                    if (error != nil){
                        print("An error occurred in Mosaic.swift - removeLike ", error);
                    }
                    
                })
            }
        }
    }
    
    class func isOwner(mosaic:PFObject,completion:(owner:Bool)->Void){
        
        let isOwnerQuery = PFQuery(className: "Mosaic");
        isOwnerQuery.whereKey("objectId", equalTo: mosaic.objectId!);
        isOwnerQuery.whereKey("user", equalTo: PFUser.currentUser()!);
        
        print ("Mosaic.swift - isOwner");
        
        isOwnerQuery.getFirstObjectInBackgroundWithBlock { (owner:PFObject?, error:NSError?) -> Void in
            
            if (error != nil) {
                
                print("An error occurred in Mosaic.swift ",error!.code);
            }
            
            if (owner != nil) {
                completion(owner: true);
            } else {
                completion(owner:false);
            }
        }
    }
    
    class func hasLikedMosaic(mosaic:PFObject,completion:(liked:Bool)->Void){
        let likesQuery = PFQuery(className: "Likes");
        likesQuery.whereKey("mosaic", equalTo: mosaic);
        likesQuery.whereKey("user", equalTo: PFUser.currentUser()!);
        
        print("Mosaic.swift - hasLikedMosaic");
        
        likesQuery.getFirstObjectInBackgroundWithBlock { (like:PFObject?, error:NSError?) -> Void in
            if (error != nil){
                print("An error occurred in Mosaic.swift - hasLikedMosaic",error!.code);
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
        
        print("Mosaic.swift - updateContributorCount");
        
        contributorCountQuery.countObjectsInBackgroundWithBlock { (count:Int32, error:NSError?) -> Void in
            if (error != nil){
                print("An error occurred in Mosaic.swift - updateContributorCount ",error!.code);
            }
            
            mosaic["contributorsCount"] = Int(count);
            mosaic.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                if (error != nil){
                    print("An error occurred in Mosaic.swift - updateContributorCount ",error!.code);
                }
               
                completion(count: Int(count));
                
            })
        }
    }
    
    class func editMosaic(mosaic:PFObject,mosaicName:String,mosaicDescription:String,completion:(success:Bool)->Void){
        
        mosaic["name"] = mosaicName;
        mosaic["description"] = mosaicDescription;
        
        print("Mosaic.swift - editMosaic");
        
        mosaic.saveInBackgroundWithBlock { (success:Bool, error:NSError?) -> Void in
            if (error != nil){
                print("An error occurred in Mosaic.swift - editMosaic ",error!.code);
            }
            
            if (success != true){
               
                completion(success: false);
            } else {
                
                completion(success:true);
            }
        }
    }
    
    class func getMosaicContributorsWithLimit(mosaic:PFObject,completion:(contributors:[PFObject]?)-> Void){
        let mosaicContributorsQuery = PFQuery(className: "Contributors");
        mosaicContributorsQuery.whereKey("mosaic", equalTo: mosaic);
        mosaicContributorsQuery.limit = 10;
        mosaicContributorsQuery.includeKey("user");
        
        print("Mosaic.swift - getMosaicContributorsWithLimit");
        mosaicContributorsQuery.findObjectsInBackgroundWithBlock { (results:[PFObject]?, error:NSError?) -> Void in
            if (error != nil){
                print("An error occurred at Mosaic.swift - getMosaicContributorsWithLimit ",error!.code);
            }
            
            completion(contributors: results);
        }
        
    }
}
