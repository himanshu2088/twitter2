//
//  LoginVC.swift
//  twitter2
//
//  Created by Himanshu Joshi on 02/07/19.
//  Copyright © 2019 Himanshu Joshi. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController {
    
    //Outlets
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var passwordTxtField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func loginBtnPressed(_ sender: UIButton) {
        
        guard let email = emailTxtField.text, let password = passwordTxtField.text else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let error = error {
                debugPrint("Error signing in, \(error.localizedDescription)")
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
        
    }
    
    
}
