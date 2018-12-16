//
//  User.swift
//  GroupCalendar
//
//  Created by Joe Monaco on 11/28/18.
//  Copyright © 2018 Joe Monaco. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth


class User {
    
    var currentUserID: String?
    var groupIDS: [String] = []
    var name: String?
    
    
    static let sharedInstance = User()
    
    init() {
    }
    
    func setCurID(withID id: String) {
        currentUserID = id
    }
    
    func logoutUser() {
        currentUserID = nil
        name = nil
        groupIDS.removeAll()
    }
    
    
    func registerUser(withEmail email: String, withPass password: String, withName name: String, completionHandler: @escaping (_ sucess: Bool)  -> ()) {
        
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            
            guard let user = authResult?.user else { return }
            
            let ref = Database.database().reference(withPath: "users")
            let newUser = RegisteredUser(uid: user.uid, email: email, password: password, name: name)
            ref.child(newUser.uid).setValue(newUser.toAnyObject())
            self.setCurID(withID: newUser.uid)
            completionHandler(true)
            
        }
    }
    
    
    
    func signInUser(withEmail email: String, withPass password: String, completionHandler: @escaping (_ sucess: Bool)  -> ()) {
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { (loggedInUser, error) in
            
            if error == nil {
                print ("login successful")
                
                if let uid = loggedInUser?.user.uid {
                    self.setCurID(withID: uid)
                }
                
                completionHandler(true)
                
            }
            else {
                print ("login failed")
                print ((error?.localizedDescription)!)
                completionHandler(false)
            }
        })
    }
    
    func getLoggedInUID () -> String {
        return currentUserID!
    }
    
    
    func getName() {
        let ref = Database.database().reference().child("users").child(currentUserID!)
        ref.observeSingleEvent(of: .value) { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let name = value?["name"] as? String ?? ""
            self.name = name
            UsersGroupsVC.nameCallDG.leave()
        }
    }
    
    func getGroupIDS(completionHandler: @escaping (_ sucess: Bool)  -> ()){
        
        
        let ref = Database.database().reference().child("users").child(currentUserID!).child("MyGroups")
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            var tempArr: [String] = []
            
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                tempArr.append(child.key)
            }
            
            self.groupIDS = tempArr
            completionHandler(true)
            
        })
        completionHandler(false)
    }
}
