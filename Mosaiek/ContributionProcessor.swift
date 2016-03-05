//
//  ContributionProcessor.swift
//  Mosaiek
//
//  Created by Jonathan Schapiro on 2/29/16.
//  Copyright © 2016 Jonathan Schapiro. All rights reserved.
//

import Foundation

class ContributionProcessor {
    
    //20x20 cell
    
    class func getPosition(stringPosition:String) -> String {
        let stringArray = stringPosition.componentsSeparatedByCharactersInSet(
            NSCharacterSet.decimalDigitCharacterSet().invertedSet)
        let newString = stringArray.joinWithSeparator("")
        
        return newString;
        
    }
    
    class func getXPosition(position:Int)-> Int{
        
        return position % 10;
        
    }
    
    class func getYPosition(position:Int)->Int{
        
        return position / 10;
        
    }
}


