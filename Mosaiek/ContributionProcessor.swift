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
        
        //remainder 
        return position % 20;
        
    }
    
    class func getYPosition(position:Int)->Int{
        
        //get quotient without remainder
        return position / 20;
        
    }
}


/*
  0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19
 20                                              39
 40                                              59

 31
 41
 51
 61
 71
 81
 91
100
.
200
300
*/