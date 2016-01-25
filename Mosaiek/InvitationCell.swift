//
//  InvitationCell.swift
//  Mosaiek
//
//  Created by Jonathan Schapiro on 1/24/16.
//  Copyright © 2016 Jonathan Schapiro. All rights reserved.
//

import UIKit

class InvitationCell: UITableViewCell {

    @IBOutlet weak var notificationDescriptionLabel: UILabel!
    
    @IBOutlet weak var notificationButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib();
        print("awaking from nib");
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        
    }

    
}
