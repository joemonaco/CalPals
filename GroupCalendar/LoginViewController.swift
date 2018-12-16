//
//  LoginViewController.swift
//  GroupCalendar
//
//  Created by Joe Monaco on 11/27/18.
//  Copyright © 2018 Joe Monaco. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    let userModel = User.sharedInstance
    
    var userID: String! = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTF.placeholder = "Enter you Email"
        passwordTF.placeholder = "Enter your Password"
        passwordTF.isSecureTextEntry = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        emailTF.text = ""
        passwordTF.text = ""
        emailTF.placeholder = "Enter you Email"
        passwordTF.placeholder = "Enter your Password"
    }
    
    var stringA: String?
    

    @IBAction func signInAction(_ sender: Any) {
        
        userModel.signInUser(withEmail: emailTF.text!, withPass: passwordTF.text!) { (success) in
            if success {
                self.performSegue(withIdentifier: "details", sender: self)
            }
            else {
                let alert = UIAlertController(title: "SIGN IN ERROR", message: "Wrong email or password", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        
    }
    
    
    
    @IBAction func registerAction(_ sender: Any) {

        let alert = UIAlertController(title: "Register",message: "Register", preferredStyle: .alert)

        let saveAction = UIAlertAction(title: "Save", style: .default) { action in
            
            let emailField = alert.textFields![0]
            let passwordField = alert.textFields![1]
            let nameField = alert.textFields![2]
            
            self.registerUser(withEmail: emailField.text!, withPass: passwordField.text!, withName: nameField.text!)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        
        alert.addTextField { textEmail in
            textEmail.placeholder = "Enter your email"
        }
        
        alert.addTextField { textPassword in
            textPassword.isSecureTextEntry = true
            textPassword.placeholder = "Enter your password"
        }
        alert.addTextField { textName in
            textName.placeholder = "Enter your name"
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
        
        
    
    }
    
    func registerUser(withEmail email: String ,withPass password: String, withName name: String) {
        
        userModel.registerUser(withEmail: email, withPass: password, withName: name) { (success) in
            if success {
                self.performSegue(withIdentifier: "details", sender: self)
            }
            else {
                print("ERROR")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navigation = segue.destination as! UINavigationController
        let userGroupsVC = navigation.topViewController as! UsersGroupsVC
        userGroupsVC.currentUID = userModel.getLoggedInUID()
    }
    
    
}
