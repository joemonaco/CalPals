//
//  ViewController.swift
//  GroupCalendar
//
//  Created by Joe Monaco on 11/26/18.
//  Copyright © 2018 Joe Monaco. All rights reserved.
//

import UIKit
import JTAppleCalendar
import FirebaseDatabase

class CalendarViewController: UIViewController {


    
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    
    @IBOutlet weak var rightBarBtn: UIBarButtonItem!
    
    var addBtn = UIBarButtonItem()
    var eventDetsBtn = UIBarButtonItem()
    
    let formatter = DateFormatter()
    var curCalendar = Calendar.current
    
    var groupToShow: String?
    var groupEventDates: [String] = []
    var selectedDate: String = "yyyy MM dd"
    
    let groupModel = Group.sharedInstance
    
    let userModel = User.sharedInstance
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        addBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(createEvent))
        eventDetsBtn = UIBarButtonItem(title: "Event Dets", style: .plain, target: self, action: #selector(goToEventDets))
        addBtn.tintColor = .white
        eventDetsBtn.tintColor = .white
        navigationController?.navigationBar.tintColor = .white
        
        setupCalendarView()
        navigationItem.title = groupToShow!
        
         getDatesFromDB()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupCalendarView()
        navigationItem.title = groupToShow!
        
        getDatesFromDB()
    }

    func getDatesFromDB() {
        
        groupModel.setUpGroupEvents(forGroupName: groupToShow!) { (done) in
            if done {
                self.groupEventDates = self.groupModel.eventDates
                self.calendarView.reloadData()
            }
        }
    }
    
    func setupCalendarView() {
        
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
        
        calendarView.visibleDates { (visibleDates) in
            self.setUpViewForCalendar(from: visibleDates)
        }
    }
    
    func setUpViewForCalendar(from visibleDates: DateSegmentInfo) {
        let date = visibleDates.monthDates.first!.date
        
        formatter.dateFormat = "yyyy"
        yearLabel.text = formatter.string(from: date)
        
        formatter.dateFormat = "MMMM"
        monthLabel.text = formatter.string(from: date)
    }

    func handleCellTextColor(view: JTAppleCell?, cellState: CellState) {
        guard let validCell = view as? CustomCalendarCell else {return}
        
        if cellState.dateBelongsTo == .thisMonth {
            validCell.dateLabel.textColor = UIColor.black
        }
        else {
            validCell.dateLabel.textColor = UIColor.lightGray
        }
    }
    
    @objc func goToEventDets() {
        performSegue(withIdentifier: "eventDetails", sender: self)
    }

    
    @objc func createEvent() {
        
        let alert = UIAlertController(title: "Create Event", message: "Create an Event", preferredStyle: .alert)
        
        
        let createAction = UIAlertAction(title: "Create", style: .default) { action in
            let eventNameField = alert.textFields![0]
            let eventLocationField = alert.textFields![1]
            let eventTimeField = alert.textFields![2]
            
            let newEvent = Event(eventCreator: self.userModel.name!, eventName: eventNameField.text!, eventLocation: eventLocationField.text!, eventTime: eventTimeField.text!)
            let ref = Database.database().reference().child("Groups").child(self.groupToShow!).child(self.selectedDate)
            ref.setValue(newEvent.toAnyObject())
            self.performSegue(withIdentifier: "eventDetails", sender: self)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .default)
        
        alert.addTextField { eventNameText in
            eventNameText.placeholder = "Enter Event Name"
        }
        
        alert.addTextField { eventLocationText in
            eventLocationText.placeholder = "Enter Event Location"
        }
        alert.addTextField { eventTimeText in
            eventTimeText.placeholder = "Enter Time of Event"
        }
        
        alert.addAction(createAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let eventDVC = segue.destination as! EventDetailsVC
        eventDVC.dateForEvent = selectedDate
        eventDVC.groupName = groupToShow
        
        
    }
    

}

extension CalendarViewController: JTAppleCalendarViewDelegate, JTAppleCalendarViewDataSource {
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        
        // This function should have the same code as the cellForItemAt function
        let cell = cell as! CustomCalendarCell
        sharedFunctionToConfigureCell(myCustomCell: cell, cellState: cellState, date: date)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableCell(withReuseIdentifier: "CalendarCell", for: indexPath) as! CustomCalendarCell
        sharedFunctionToConfigureCell(myCustomCell: cell, cellState: cellState, date: date)
        return cell
    }
    
    func sharedFunctionToConfigureCell(myCustomCell: CustomCalendarCell, cellState: CellState, date: Date) {
        
        myCustomCell.dateLabel.text = cellState.text
        myCustomCell.eventView.isHidden = true
        
        if cellState.isSelected {
            myCustomCell.selectedView.isHidden = false
        }
        else{
            myCustomCell.selectedView.isHidden = true
        }
        
        if groupEventDates.contains(formatter.string(from: cellState.date)){
            myCustomCell.eventView.isHidden = false
//            myCustomCell.selectedView.backgroundColor = UIColor.red
        }
        
        handleCellTextColor(view: myCustomCell, cellState: cellState)
        
    }
    
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        
        setUpViewForCalendar(from: visibleDates)

    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard let validCell = cell as? CustomCalendarCell else {return}
        
        formatter.dateFormat = "yyyy MM dd"
        selectedDate = formatter.string(from: cellState.date)
        
        if groupEventDates.contains(formatter.string(from: cellState.date)){
            navigationItem.rightBarButtonItem = eventDetsBtn
            
        }
        else {
            navigationItem.rightBarButtonItem = addBtn
        }
        
        validCell.selectedView.isHidden = false
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        
        guard let validCell = cell as? CustomCalendarCell else {return}

        validCell.selectedView.isHidden = true
        validCell.eventView.isHidden = true
        
        if groupEventDates.contains(formatter.string(from: cellState.date)){
            validCell.eventView.isHidden = false
//            validCell.selectedView.backgroundColor = UIColor.red
        }
    }
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        let currentDate = Date()
        
        let startDate = formatter.date(from: formatter.string(from: currentDate))
        let endDate = formatter.date(from: "2019 12 31")!
        
        let parameters = ConfigurationParameters(startDate: startDate!, endDate: endDate)
        return parameters
    }
}

