//
//  CreateUserVC.swift
//  twitter2
//
//  Created by Himanshu Joshi on 02/07/19.
//  Copyright © 2019 Himanshu Joshi. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class CreateUserVC: UIViewController {
    
    //Outlets
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var passwordTxtField: UITextField!
    @IBOutlet weak var confirmPasswordTxtField: UITextField!
    @IBOutlet weak var usernameTxtField: UITextField!
    
    //Variables
    var usernameArray = [String]()
    var emailArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func createUserBtnPressed(_ sender: UIButton) {
        
        SVProgressHUD.show(withStatus: "Creating User")
        
        guard let email = emailTxtField.text, let password = passwordTxtField.text, let confirmPassword = confirmPasswordTxtField.text, let username = usernameTxtField.text else { return }
        
        if email == "" || password == "" || confirmPassword == "" || username == "" {
            SVProgressHUD.dismiss()
            let alert = UIAlertController(title: "Error", message: "Please enter all the fields to continue.", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    
        if password != confirmPassword {
            SVProgressHUD.dismiss()
            let alert = UIAlertController(title: "Error", message: "Entered password and confirm password are not equal. Please write same details.", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        Firestore.firestore().collection(USERS_REF).getDocuments { (snapshot, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            let documents = snapshot?.documents
            for document in documents! {
                let data = document.data()
                let usedUsername = data[USERNAME] as? String ?? ""
                let usedEmail = data[CURRENT_EMAIL] as? String ?? ""
                self.usernameArray.append(usedUsername)
                self.emailArray.append(usedEmail)
            }
            if self.usernameArray.contains(username) {
                SVProgressHUD.dismiss()
                let alert = UIAlertController(title: "Error", message: "Username is already taken. Please try another one.", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
            else if self.emailArray.contains(email) {
                SVProgressHUD.dismiss()
                let alert = UIAlertController(title: "Error", message: "Email is already taken. Please try another one.", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
            else {
                self.createUser()
            }

        }
        
    }
    
    func createUser() {

        guard let email = emailTxtField.text, let password = passwordTxtField.text, let username = usernameTxtField.text else { return }

        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let error = error {
                debugPrint("Error while creating user, \(error.localizedDescription)")
            }

            let changeRequest = user?.user.createProfileChangeRequest()
            changeRequest?.displayName = username
            changeRequest?.commitChanges(completion: { (error) in
                if let error = error {
                    debugPrint(error.localizedDescription)
                }
            })

            guard let userId = user?.user.uid else { return }
            Firestore.firestore().collection(USERS_REF).document(userId).setData([
                USERNAME : username,
                CURRENT_EMAIL : email,
                CURRENT_PASSWORD : password,
                OLD_PASSWORD : "",
                DATE_CREATED : FieldValue.serverTimestamp()
                ], completion: { (error) in
                    if let error = error {
                        debugPrint(error.localizedDescription)
                        print("Error while creating user")
                    } else {
                        SVProgressHUD.dismiss()
                        self.showAlert()
                    }
            })
        }

    }
    
    func showAlert() {
        let alert = UIAlertController(title: "Success", message: "Account created successfully. Please go to the login page to continue login.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func cancelBtnPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
