//
//  MosaicImage.swift
//  Mosaiek
//
//  Created by Jonathan Schapiro on 1/19/16.
//  Copyright © 2016 Jonathan Schapiro. All rights reserved.
//

import Foundation

class MosaicImage {
    
    init(){
        
    }
    
    class func getCurrentMosaicImages(mosaic:PFObject,completion:(Array<PFObject>?)-> Void){
        let MosaicImageQuery = PFQuery(className: "MosaicImage");
        MosaicImageQuery.whereKey("mosaic", equalTo: mosaic);
        MosaicImageQuery.includeKey("user");
        
        print("MosaicImage.swift - getCurrentMosaicImages");
        MosaicImageQuery.findObjectsInBackgroundWithBlock { (mosaicImages:[PFObject]?,error: NSError?) -> Void in
            if (error != nil){
                print("An error occurred in MosaicImage.swift - getCurrentMosaicImages ", error!.code);
            } else {
                completion(mosaicImages);
            }
        }
    }
    
    class func saveImageToMosaic(mosaic:PFObject,image:UIImage,completion: (success: Bool,mosaicImage:PFObject) -> Void){
        
        let thumbnail = self.generateJPEG(image);
        let hirez = self.generateJPEG(image);
        
        let mosaicImageFile = PFFile(name: "image.jpeg" , data: hirez);
        let mosaicImageThumbnailFile = PFFile(name: "image_thumbnail.jpeg" , data: thumbnail);
        
        let MosaicImageTable = PFObject(className: "MosaicImage");
        
        MosaicImageTable["name"] = "";
        MosaicImageTable["description"] = "";
        MosaicImageTable["likes"] = 0;
        MosaicImageTable["image"] = mosaicImageFile;
        MosaicImageTable["thumbnail"] = mosaicImageThumbnailFile;
        MosaicImageTable["mosaic"] = mosaic;
        MosaicImageTable["user"] = PFUser.currentUser()!;
        
        print("MosaicImage.swift - saveImageToMosasic");
        
        MosaicImageTable.saveInBackgroundWithBlock { (success:Bool,error: NSError?) -> Void in
            if (error != nil){
                print("An error occurred at MosaicImage.swift - saveImageToMosasic ", error!.code)
            }
            if (success == true){
                completion(success: success,mosaicImage: MosaicImageTable);
            }
        }
        
        
    }
    
    class func likeMosaicImage(mosaicImage:PFObject){
        self.mosaicImageIsLiked(mosaicImage) { (liked,likeRelationship) -> Void in
            if (liked != true) {
                let mosaicImageLike = PFObject(className: "Likes");
                mosaicImageLike["user"] = PFUser.currentUser()!;
                mosaicImageLike["mosaicImage"] = mosaicImage;
                
                mosaicImageLike.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                    if (error != nil) {
                        print("An error occurred at MosaicImage.swift - likeMosaicImage", error?.code);
                    }
                    
                    if (success) {
                        if let likeCount = mosaicImage["likes"] as? Int {
                            mosaicImage["likes"] = likeCount + 1;
                        }
                        
                    }
                    
                })
                
            } else {
                
                return;
            }
        }
    }
    
    class func removeMosaicImageLike(mosaicImage:PFObject){
        
        self.mosaicImageIsLiked(mosaicImage) { (liked,likedRelationship) -> Void in
            if (liked == true) {
                if let likeRel = likedRelationship {
                    likeRel.deleteInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                        print("like relationship remvoed");
                        if (error != nil){
                            print("An error occurred in MosaicImage.swift - removeMosaicLike");
                        }
                        if let likeCount = mosaicImage["likes"] as? Int {
                            mosaicImage["likes"] = likeCount - 1;
                        }
                    })
                }
                
            } else {
                
                return;
            }
        }

        
    }
    
    class func mosaicImageIsLiked(mosaicImage:PFObject,completion:(liked:Bool,likeRelationship:PFObject?)->Void){
        
        let mosaicImageQuery = PFQuery(className: "Likes");
        mosaicImageQuery.whereKey("mosaicImage", equalTo: mosaicImage);
        mosaicImageQuery.whereKey("user", equalTo: PFUser.currentUser()!);
        
        print("MosaicImage.swift - mosaicImageIsLiked");
        
        mosaicImageQuery.getFirstObjectInBackgroundWithBlock { (like:PFObject?, error:NSError?) -> Void in
            
            if (error != nil){
                print("An error occurred in MosaicImage.swift - mosaicImageIsLiked");
            }
            
            if (like != nil) {
                completion(liked: true,likeRelationship: like);
            } else {
                completion(liked: false,likeRelationship: nil);
            }
        }
        
    }
    
    class func fileToImage(file:PFFile, completion: (mosaicImage: UIImage?) -> Void){
        
        file.getDataInBackgroundWithBlock { (data: NSData?, error:NSError?) -> Void in
            if (error != nil){
                print("error ",error);
            } else {
                if let imageData = data {
                    let image = UIImage(data:imageData);
                    completion(mosaicImage: image);
                }
            }
            
        }
    }
    
    class func generateJPEG(image:UIImage) -> NSData {
        
        return UIImageJPEGRepresentation(image, 0.8)!;
    }
    
    class func generateThumbnail(image:UIImage) -> NSData{
        let imageData = UIImageJPEGRepresentation(image, 0.0) //lowest quality
        return imageData!;
    }
}