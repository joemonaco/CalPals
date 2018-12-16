
//
//  CustomCalendarCell.swift
//  GroupCalendar
//
//  Created by Joe Monaco on 11/26/18.
//  Copyright © 2018 Joe Monaco. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CustomCalendarCell: JTAppleCell {
    
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet weak var selectedView: UIView!
    @IBOutlet weak var eventDot: UIImageView!
    @IBOutlet weak var eventView: UIView!
    
    var dateHasEvent: Bool = false
}
