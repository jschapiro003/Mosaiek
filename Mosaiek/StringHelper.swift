//
//  StringHelper.swift
//  Mosaiek
//
//  Created by Jonathan Schapiro on 3/16/16.
//  Copyright © 2016 Jonathan Schapiro. All rights reserved.
//

import Foundation


class StringHelper {
    class func removeSpecialCharsFromString(text: String) -> String {
        let okayChars : Set<Character> =
        Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890+-*=(),.:!_".characters)
        return String(text.characters.filter {okayChars.contains($0) })
    }
}