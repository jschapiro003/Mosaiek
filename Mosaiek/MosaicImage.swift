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
    
    class func fileToImage(file:PFFile, completion: (mosaicImage: UIImage?) -> Void){
        
        file.getDataInBackgroundWithBlock { (data: NSData?, error:NSError?) -> Void in
            if (error != nil){
                print("error ",error);
            } else {
                if let imageData = data {
                    print("converting image data");
                    let image = UIImage(data:imageData);
                    completion(mosaicImage: image);
                }
            }
            
        }
    }
}