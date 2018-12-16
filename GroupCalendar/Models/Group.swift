//
//  Group.swift
//  GroupCalendar
//
//  Created by Joe Monaco on 12/1/18.
//  Copyright © 2018 Joe Monaco. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

class Group {
    
    static let sharedInstance = Group()
    var eventDates: [String] = []
    
    init(){}
    
    
    func checkGroupCredentials(forGroupID groupID: String, forGroupPW groupPW: String,  completionHandler: @escaping (_ sucess: Bool)  -> ()) {
        
        
        let ref = Database.database().reference().child("Groups").child(groupID)
        
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if !snapshot.exists() {
                completionHandler(false)
            }
            else {
                let value = snapshot.value as? NSDictionary
                
                let groupPassword = value!["groupPW"] as! String
                if groupPW == groupPassword {
                    completionHandler(true)
                }
                else {
                    completionHandler(false)
                }
            }
        }
    }
    
    
    func setUpGroupEvents(forGroupName groupName: String, completionHandler: @escaping (_ sucess: Bool)  -> ()){
        
        
        let ref = Database.database().reference().child("Groups").child(groupName)
        var arr: [String] = []
        
        ref.observeSingleEvent(of: .value) { (snapshot) in
            
            
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                if(!(child.key == "groupID" || child.key == "groupPW")){
                    arr.append(child.key)
                }
            }
            self.eventDates = arr
            completionHandler(true)
        }
        
        
        completionHandler(false)
    }
    
    
    
}
