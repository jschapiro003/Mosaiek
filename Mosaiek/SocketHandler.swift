//
//  SocketHandler.swift
//  Mosaiek
//
//  Created by Jonathan Schapiro on 2/27/16.
//  Copyright © 2016 Jonathan Schapiro. All rights reserved.
//

import Foundation

protocol ContributionMadeDelegate {
    func didMakeContribution(mosaicState:String,vc:TimelineDetailViewController);
}

class SocketHandler {
    
    var delegate:ContributionMadeDelegate?
    
    
    func layerContribution(mosaicState:String,vc:TimelineDetailViewController){
        
        if let del = self.delegate {
            del.didMakeContribution(mosaicState,vc: vc);
        }
       
    }
}