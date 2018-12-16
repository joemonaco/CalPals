//
//  RegisteredUser.swift
//  GroupCalendar
//
//  Created by Joe Monaco on 11/27/18.
//  Copyright © 2018 Joe Monaco. All rights reserved.
//

/*
 Users.swift
 */

import Foundation
import FirebaseDatabase

struct RegisteredUser {
    
    let uid: String
    let email: String
    let password: String
    let name: String
    let ref: DatabaseReference?
    
    init (userSnap: DataSnapshot) {
        let value = userSnap.value as! Dictionary<String, String>
        uid = value["uid"]!
        email = value["email"]!
        password = value["password"]!
        name = value["name"]!
        ref = userSnap.ref
    }
    
    init(uid: String, email: String, password: String, name: String) {
        self.uid = uid
        self.email = email
        self.password = password
        self.name = name
        ref = nil
    }
    
    func toAnyObject() -> Any {
        return [
            "uid": uid,
            "email" : email,
            "password": password,
            "name": name
        ]
    }

}
