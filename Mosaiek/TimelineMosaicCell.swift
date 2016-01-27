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
    
    override func awakeFromNib() {
        super.awakeFromNib();
       
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        
    }
    
}