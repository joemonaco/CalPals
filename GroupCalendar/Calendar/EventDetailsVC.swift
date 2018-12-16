//
//  EventDetailsVC.swift
//  GroupCalendar
//
//  Created by Joe Monaco on 12/5/18.
//  Copyright © 2018 Joe Monaco. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class EventDetailsVC: UIViewController {

    
    var dateForEvent: String?
    var groupName: String?
    let userModel = User.sharedInstance
    var ref  = Database.database().reference()
    
    @IBOutlet weak var eventNameLbl: UILabel!
    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var creatorLbl: UILabel!
    
    var eventObject: Event?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let group = groupName {
            groupName = group
            ref = ref.child("Groups").child(groupName!)
        }
        
        
        if let date = dateForEvent {
            dateForEvent = date
            ref = ref.child(dateForEvent!)
        }
        
        showDetails { (eventMade) in
            if eventMade {
                self.eventNameLbl.text = self.eventObject!.eventName
                self.locationLbl.text = "Location: " + self.eventObject!.eventLocation
                self.timeLbl.text = "Time: " + self.eventObject!.eventTime
                self.creatorLbl.text = "Creator: " + self.eventObject!.eventCreator
            }
        }
        navigationItem.title = dateForEvent
        // Do any additional setup after loading the view.
    }
    
    func showDetails(completionHandler: @escaping (_ sucess: Bool)  -> ()) {
        ref.observeSingleEvent(of: .value) { (snapshot) in
            self.eventObject = Event(eventSnap: snapshot)
            completionHandler(true)
        }
        
        completionHandler(false)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
