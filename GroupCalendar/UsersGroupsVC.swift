//
//  TestingLoginVC.swift
//  GroupCalendar
//
//  Created by Joe Monaco on 11/28/18.
//  Copyright © 2018 Joe Monaco. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase

class UsersGroupsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    static let nameCallDG = DispatchGroup()
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var groupsTV: UITableView!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var nameLabel: UILabel!
    var selectedGroup = ""
    var currentUID: String?
    

    let userModel = User.sharedInstance
    let groupModel = Group.sharedInstance
    var usersGroups: [String] = []

    
    override func viewWillAppear(_ animated: Bool) {
       
        activityIndicator.startAnimating()
        userModel.getGroupIDS(completionHandler: { (done) in
            if done {
                self.usersGroups = self.userModel.groupIDS
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                self.groupsTV.reloadData()
            }
        })
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
//        navigationItem.title = "My Groups"
         activityIndicator.startAnimating()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.barTintColor = .clear
        self.navigationController?.navigationBar.backgroundColor = .clear

        
        navItem.titleView?.backgroundColor = .clear
//        navItem.
        
        userModel.setCurID(withID: currentUID!)
        
        UsersGroupsVC.nameCallDG.enter()
        userModel.getName()
        
        UsersGroupsVC.nameCallDG.notify(queue: .main) {
            self.navigationItem.title = "Hello " + self.userModel.name! + "!"
            self.navigationItem.titleView?.tintColor = .white
        }
        
        groupsTV.delegate = self
        groupsTV.dataSource = self
        groupsTV.backgroundColor = UIColor.clear
        groupsTV.rowHeight = 100
        
        userModel.getGroupIDS(completionHandler: { (done) in
            if done {
                self.usersGroups = self.userModel.groupIDS
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                self.groupsTV.reloadData()
            }
        })
        
    }
    
    @IBAction func logoutFunction(_ sender: Any) {
        
        userModel.logoutUser()
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    @IBAction func addGroup(_ sender: Any) {
        
        let alert = UIAlertController(title: "Add or Join",message: "Create or Join a Group", preferredStyle: .alert)
        
        let newGroup = UIAlertAction(title: "Create", style: .default) { action in
            self.createTapped()
        }
        
        let joinGroup = UIAlertAction(title: "Join", style: .default) { action in
            self.joinGroup()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .default)

    
        alert.addAction(newGroup)
        alert.addAction(joinGroup)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    func joinGroup() {
        
        let alert = UIAlertController(title: "Join",message: "Join a Group", preferredStyle: .alert)
        
        let join = UIAlertAction(title: "Join", style: .default) { action in
            
            let groupName = alert.textFields![0]
            let groupPassword = alert.textFields![1]
            self.joinNewGroup(forGroupID: groupName.text!, forGroupPW: groupPassword.text!)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        
        alert.addTextField { groupNameTF in
            groupNameTF.placeholder = "Enter Group Name"
        }
        
        alert.addTextField { passwordTF in
            passwordTF.isSecureTextEntry = true
            passwordTF.placeholder = "Enter Group Password"
        }
        
        alert.addAction(join)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
//    func checkGroupCredentials()
    
    func joinNewGroup(forGroupID groupID: String, forGroupPW groupPW: String) {
        
        print("IN JOIN NEW GROUP")
        
        self.groupModel.checkGroupCredentials(forGroupID: groupID, forGroupPW: groupPW, completionHandler: { (success) in
            if success {
                let userRef = Database.database().reference().child("users").child(self.currentUID!).child("MyGroups").child(groupID)
                
                userRef.setValue(["groupID": groupID])
                self.selectedGroup = groupID
                print("SEGUE FROM JOIN GROUP")
                self.performSegue(withIdentifier: "selectedGroupSegue", sender: self)
            }
            else {
                print("NO SUCH GROUP")
            }
        })
    }
    
    func createTapped() {
        
        let alert = UIAlertController(title: "Create Group",message: "Create a new Group", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Create", style: .default) { action in
            
            let groupName = alert.textFields![0]
            let groupPassword = alert.textFields![1]
            self.createNewGroup(withGroupName: groupName.text!, withGroupPassword: groupPassword.text!)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        
        alert.addTextField { groupNameTF in
            groupNameTF.placeholder = "Enter Group Name"
        }
        
        alert.addTextField { passwordTF in
            passwordTF.isSecureTextEntry = true
            passwordTF.placeholder = "Enter Group Password"
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    func createNewGroup(withGroupName groupName: String, withGroupPassword password: String) {
        
        
        let userRef = Database.database().reference().child("users").child(currentUID!).child("MyGroups").child(groupName)
        userRef.setValue(["groupID":groupName])
        
        let groupRef = Database.database().reference().child("Groups").child(groupName)
        groupRef.setValue(["groupID": groupName, "groupPW":password])

        
        userModel.groupIDS.append(groupName)
        usersGroups = userModel.groupIDS
        
        selectedGroup = groupName
        print("ABOUT TO SEGUE FROM CREATE NEW GROUP")
        performSegue(withIdentifier: "selectedGroupSegue", sender: self)
        
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersGroups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = usersGroups[indexPath.row]
        cell.textLabel?.textColor = .white
        cell.backgroundColor = UIColor.clear
        
        return cell
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedGroup = usersGroups[indexPath.row]
        print("SEGUE FROM TABLE VIEW INDEX PATH")
        performSegue(withIdentifier: "selectedGroupSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let calendarVC = segue.destination as! CalendarViewController
        calendarVC.groupToShow = selectedGroup
    }

}
