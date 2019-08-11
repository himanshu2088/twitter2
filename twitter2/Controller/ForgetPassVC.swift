//
//  ForgetPassVC.swift
//  twitter2
//
//  Created by Himanshu Joshi on 08/08/19.
//  Copyright © 2019 Himanshu Joshi. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class ForgetPassVC: UIViewController {

    //Outlets
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var confirmPasswordTxt: UITextField!
    
    //Variables
    var emailArray = [String]()
    var id: String?
   
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func loginBtnPressed(_ sender: UIButton) {
        
        SVProgressHUD.show(withStatus: "Updating Password")
        
        guard let email = emailTxt.text, let password = passwordTxt.text, let confirmPassword = confirmPasswordTxt.text else { return }
        
        if email == "" || password == "" || confirmPassword == "" {
            SVProgressHUD.dismiss()
            let alert = UIAlertController(title: "Error", message: "Please fill all the fields to continue login.", preferredStyle: .alert)
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
                let usedEmail = data[CURRENT_EMAIL] as? String ?? ""
                self.emailArray.append(usedEmail)
            }
            
            if !self.emailArray.contains(email) {
                SVProgressHUD.dismiss()
                let alert = UIAlertController(title: "Error", message: "Email is not in our records. Please write correct email or sign up with this email.", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            } else {
                
                SVProgressHUD.dismiss()
                
                Firestore.firestore().collection(USERS_REF).getDocuments(completion: { (snapshot, error) in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                    for document in (snapshot?.documents)! {
                        let typedEmail = document.data()[CURRENT_EMAIL] as? String ?? ""
                        if typedEmail == email {
                            self.id = document.documentID
                        }
                        
                    }
                    
                    let ref = Firestore.firestore().collection(USERS_REF).document(self.id!)
                    ref.updateData([
                        CURRENT_PASSWORD : password
                        ], completion: { (error) in
                        if let error = error {
                            print(error.localizedDescription)
                        }
                    })
                    
                })
                
                let alert = UIAlertController(title: "Success", message: "Successfully updated password. Login with this password to continue.", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
                
            }
            
        }
        
    }
    
    
    @IBAction func cancelBtnPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
}
