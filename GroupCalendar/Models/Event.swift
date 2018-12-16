//
//  Event.swift
//  GroupCalendar
//
//  Created by Joe Monaco on 11/30/18.
//  Copyright © 2018 Joe Monaco. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct Event {
    
    let eventCreator: String
    let eventName: String
    let eventLocation: String
    let eventTime: String
    let ref: DatabaseReference?
    
    init (eventSnap: DataSnapshot) {
        let value = eventSnap.value as! Dictionary<String, String>
        eventCreator = value["eventCreator"]!
        eventName = value["eventName"]!
        eventLocation = value["eventLocation"]!
        eventTime = value["eventTime"]!
        ref = eventSnap.ref
    }
    
    init(eventCreator: String, eventName: String, eventLocation: String, eventTime: String) {
        
        self.eventCreator = eventCreator
        self.eventName = eventName
        self.eventLocation = eventLocation
        self.eventTime = eventTime
        ref = nil
    }
    
    func toAnyObject() -> Any {
        return [
            "eventCreator": eventCreator,
            "eventName" : eventName,
            "eventLocation": eventLocation,
            "eventTime": eventTime
            
        ]
    }
    
}
