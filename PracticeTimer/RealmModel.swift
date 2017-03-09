//
//  RealmModel.swift
//  PracticeTimer
//
//  Created by Matthew Mauro on 2017-03-07.
//  Copyright © 2017 Matthew Mauro. All rights reserved.
//

import Foundation
import RealmSwift


class RealmModel: Object {

    // Specify properties to ignore (Realm won't persist these)
    //  override static func ignoredProperties() -> [String] {
    //    return []
    //  }
}

class Preset: Object {
    
    dynamic var title = ""
    dynamic var startingSound = ""
    dynamic var endingSound = ""
    dynamic var tapEnabled = false
    dynamic var tapSound:String? = nil
    dynamic var timeLength:Double = 0.0
    dynamic var warmupTime:Double = 0.0
    
}

class completedSession: Object {
    
    dynamic var elapsedTime:Double = 0.0
    dynamic var date = NSDate()
    
}
