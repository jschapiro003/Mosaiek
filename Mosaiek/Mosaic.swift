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
                   
                    print("Received \(usersMosaics.count) mosaics");
                    
                    self.getUsersContributedMosaics(user, completion: { (mosaics) -> Void in
                        if let contributedMosaics = mosaics {
                            for contributed in contributedMosaics {
                                
                                if let contribMosaic = contributed["mosaic"] as? PFObject {
                                    Mosaic.getSingleMosaic(contribMosaic, completion: { (mosaic) -> Void in
                                        print("Mosaic search index",usersMosaics.indexOf(mosaic));
                                        if usersMosaics.indexOf(mosaic) > -1 {
                                            completion(mosaics: [mosaic]);
                                        }
                                        
                                    })
                                }
                                
                            }
                            
                            self.getFriendsMosaics({ (mosaics) -> Void in
                                print("retrieved friends mosaics \(mosaics!.count)");
                                print("friends mosaics",mosaics!);
                                completion(mosaics: mosaics);
                            })
                            
                            print("sending back mosaics");
                            //completion(mosaics: usersMosaics);
                        } else {
                            print("sending back mosaics too");
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
    
    class func getFriendsMosaics(completion: (mosaics: [PFObject]?) -> Void){
        
        User.loadAllFriends { (friendsResults:Array<PFObject>?) -> Void in
            if let friends = friendsResults {
                let friendsMosaicsQuery = PFQuery(className: "Mosaic");
                friendsMosaicsQuery.whereKey("user", containedIn: friends);
                friendsMosaicsQuery.includeKey("user");
                friendsMosaicsQuery.orderByDescending("createdAt");
                friendsMosaicsQuery.findObjectsInBackgroundWithBlock({ (friendsMosaics:[PFObject]?, error:NSError?) -> Void in
                    if (error != nil){ print("Mosaic.swift: error while getting friends mosaics",error); }
                    else {
                        print("Received \(friendsMosaics!.count) friends mosaics");
                        completion(mosaics: friendsMosaics);
                    }
                    
                })
            }
        }
        //get a list of your friends
        //if the user field of the mosaic is a friend retrieve it
        
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
    
    
    class func addContributors(mosaicObjectId:String?,contributors:Array<PFUser>){
        
        //get mosaic objects to act as pointer **** Refactor to use mosaic not mosaic name
        let mosaicQuery = PFQuery(className: "Mosaic");
        
        if let objectId = mosaicObjectId {
          
            mosaicQuery.whereKey("objectId", equalTo: objectId);
            
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
                                    
                                   //update contrib count
                                   
                                    
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
                
                if let currentLikes = mosaic["likes"] as? Int {
                    mosaic["likes"] = currentLikes - 1;
                    mosaic.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                        if (error != nil){
                            print("An error occurred in Mosaic.swift - removLike ",error);
                        }
                        
                    })
                }
                
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
        mosaicContributorsQuery.whereKey("status", equalTo: 1);
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
    
    class func isContributor(mosaic:PFObject,user:PFObject,completion:(contributor:Bool)->Void){
        
        let contributorQuery = PFQuery(className: "Contributors");
        contributorQuery.whereKey("mosaic", equalTo: mosaic);
        contributorQuery.whereKey("user", equalTo: user);
        contributorQuery.whereKey("status", equalTo: 1);
        
        print("Mosaic.swift - isContributor");
        
        contributorQuery.getFirstObjectInBackgroundWithBlock { (relationship:PFObject?, error:NSError?) -> Void in
            if (error != nil){
                
                print("An error occurred in Mosaic.swift - isContributor",error?.code);
            }
            
            if (relationship != nil){
                
                completion(contributor: true);
                
            } else {
                
                completion(contributor: false);
            }
        }
    }
    
    class func saveMosaicState(mosaic:PFObject,image:UIImage,completion:(success:Bool)->Void){
        let stateImageData = generateJPEG(image);
        let stateImageFile = PFFile(name: "state_image.jpeg" , data: stateImageData);
        
        mosaic["currentState"] = stateImageFile;
        
        mosaic.saveInBackgroundWithBlock { (saved:Bool, error:NSError?) -> Void in
            if (error != nil){
                print("Mosaic.swift: error while saving mosaic state: ",error);
            } else {
                completion(success: saved);
            }
        }
        
    }
    
    class func captureCurrentState(view:UIView) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, UIScreen.mainScreen().scale);
        //UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, [[UIScreen mainScreen] scale]);
        view.layer.renderInContext(UIGraphicsGetCurrentContext()!);
        //[view.layer renderInContext:UIGraphicsGetCurrentContext()];
        let img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return img;
    }
    
    class func generateJPEG(image:UIImage) -> NSData {
        
        return UIImageJPEGRepresentation(image, 0.8)!;
    }
    
    class func generateThumbnail(image:UIImage) -> NSData{
        let imageData = UIImageJPEGRepresentation(image, 0.0) //lowest quality
        return imageData!;
    }
    
    class func containsMosaic(mosaicArray:[PFObject],mosaic:PFObject)->Bool {
        var contains = false;
        
        for (var i = 0; i < mosaicArray.count; i++){
            if (mosaic.objectId == mosaicArray[i].objectId){
                contains = true;
            }
        }
        return contains;
    }
    
}
