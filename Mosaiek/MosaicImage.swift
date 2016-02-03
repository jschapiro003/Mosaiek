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
        
        
        MosaicImageQuery.findObjectsInBackgroundWithBlock { (mosaicImages:[PFObject]?,error: NSError?) -> Void in
            if (error != nil){
                print("error: ", error);
            } else {
                completion(mosaicImages);
            }
        }
    }
    
    class func saveImageToMosaic(mosaic:PFObject,image:UIImage,completion: (success: Bool) -> Void){
        
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
        
        MosaicImageTable.saveInBackgroundWithBlock { (success:Bool,error: NSError?) -> Void in
            if (error != nil){
                print("error: ", error)
            } else {
                completion(success: success);
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