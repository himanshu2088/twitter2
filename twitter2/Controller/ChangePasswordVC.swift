//
//  ChangePasswordVC.swift
//  twitter2
//
//  Created by Himanshu Joshi on 31/07/19.
//  Copyright © 2019 Himanshu Joshi. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class ChangePasswordVC: UIViewController {
    
    //Outlets
    @IBOutlet weak var currentPasswordTxt: UITextField!
    @IBOutlet weak var newPasswordTxt: UITextField!
    @IBOutlet weak var reTypePasswordTxt: UITextField!
    
    //Variables
    let currentUsername = Auth.auth().currentUser?.displayName
    let uid = Auth.auth().currentUser?.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func changePasswordBtnPressed(_ sender: UIButton) {
        
        SVProgressHUD.show(withStatus: "Changing Password")
        
        guard let currentPassword = currentPasswordTxt.text, let newPassword = newPasswordTxt.text, let reTypePassword = reTypePasswordTxt.text else { return }
        
        if currentPassword == "" || newPassword == "" || reTypePassword == "" {
            SVProgressHUD.dismiss()
            let alert = UIAlertController(title: "Error", message: "Please enter all the fields to continue.", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            return
        }
        
        if newPassword != reTypePassword {
            SVProgressHUD.dismiss()
            let alert = UIAlertController(title: "Error", message: "New Password and confirm password are not same.", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            return
        }
        
        Firestore.firestore().collection(USERS_REF).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error while fetching documents for changing password \(error.localizedDescription)")
            }
            
            let documents = snapshot?.documents
            for document in documents! {
                let data = document.data()
                let username = data[USERNAME] as? String ?? ""
                let password = data[CURRENT_PASSWORD] as? String ?? ""
                
                if self.currentUsername == username {
                    
                    if currentPassword != password {
                        SVProgressHUD.dismiss()
                        let alert = UIAlertController(title: "Error", message: "Current password is not same as entered. Please write correct current password.", preferredStyle: .alert)
                        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        Firestore.firestore().collection(USERS_REF).document(self.uid!).updateData([
                            OLD_PASSWORD : currentPassword,
                            CURRENT_PASSWORD : newPassword
                            ], completion: { (error) in
                                if let error = error {
                                    print("Error setting data while changing password \(error.localizedDescription)")
                                } else {
                                    SVProgressHUD.dismiss()
                                    self.navigationController?.popViewController(animated: true)
                                }
                        })
                    }
                    
                }
            }
            
        }
        
    }
    
}
