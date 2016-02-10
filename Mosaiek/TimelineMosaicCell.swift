//
//  TimelineMosaicCell.swift
//  Mosaiek
//
//  Created by Jonathan Schapiro on 1/26/16.
//  Copyright © 2016 Jonathan Schapiro. All rights reserved.
//

import UIKit

class TimelineMosaicCell: UITableViewCell {
    
    @IBOutlet weak var mosaicThumbnailImageView: UIImageView!
   
    @IBOutlet weak var mosaicName: UILabel!
    
    @IBOutlet weak var mosaicDescription: UILabel!
    
    @IBOutlet weak var mosaicOwnerPhoto: UIImageView!
    
    @IBOutlet weak var username: UILabel!
    
    @IBOutlet weak var mosaicLikes: UILabel!
    
    @IBOutlet weak var mosaicCreationDate: UILabel!
    
    
    @IBOutlet weak var likeButton: UIButton!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib();
       
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        
    }
    
}
