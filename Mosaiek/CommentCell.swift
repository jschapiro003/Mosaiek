//
//  CommentCell.swift
//  Mosaiek
//
//  Created by Jonathan Schapiro on 2/2/16.
//  Copyright © 2016 Jonathan Schapiro. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {
    
    @IBOutlet weak var commentUserImage: UIImageView!
    
    @IBOutlet weak var commentText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib();
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        
    }

}
