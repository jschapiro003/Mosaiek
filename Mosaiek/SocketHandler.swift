//
//  SocketHandler.swift
//  Mosaiek
//
//  Created by Jonathan Schapiro on 2/27/16.
//  Copyright © 2016 Jonathan Schapiro. All rights reserved.
//

import Foundation

protocol ContributionMadeDelegate {
    func didMakeContribution(mosaicId:String,contributionId:String,position:String,vc:UIViewController);
}

class SocketHandler {
    
    var delegate:ContributionMadeDelegate?
    
    
    func layerContribution(mosaicId:String,contributionId:String,position:String,vc:UIViewController){
        
        if let del = self.delegate {
            del.didMakeContribution(mosaicId,contributionId: contributionId,position: position,vc:vc);
        }
       
    }
}