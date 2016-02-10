//
//  ContributorImageView.swift
//  Mosaiek
//
//  Created by Jonathan Schapiro on 2/9/16.
//  Copyright © 2016 Jonathan Schapiro. All rights reserved.
//

import UIKit

class ContributorImageView: UIImageView {
    
    override init (frame : CGRect) {
        super.init(frame : frame)
        customizeView()
    }
    
    convenience init (imageString:String,x:Int,y:Int,width:Int,height:Int) {
        
        self.init(frame:CGRect(x: x, y: y, width: width, height: height));
        
        if let url = NSURL(string: imageString) {
            
            if let data = NSData(contentsOfURL: url) {
                
                self.image = UIImage(data: data)
            }
        }
        self.customizeView();

    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    func customizeView (){
        self.layer.cornerRadius = self.frame.size.width / 2;
        self.clipsToBounds = true;
    }
    

}
