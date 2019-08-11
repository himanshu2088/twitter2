//
//  UpdateThoughtVC.swift
//  twitter2
//
//  Created by Himanshu Joshi on 21/07/19.
//  Copyright © 2019 Himanshu Joshi. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class UpdateThoughtVC: UIViewController {

    //Outlets
    @IBOutlet weak var updateThoughtTxt: UITextView!
    @IBOutlet weak var updateBtn: UIButton!
    
    //Variables
    var thoughtData: (Thought)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateThoughtTxt.text = thoughtData.thoughtTxt
    }

    @IBAction func updateBtnPressed(_ sender: UIButton) {
        
            SVProgressHUD.show()
        Firestore.firestore().collection(THOUGHTS_REF).document(thoughtData.documentId).updateData([THOUGHT_TXT : updateThoughtTxt.text]) { (error) in
            if let error = error {
                debugPrint("Error while updating Thought")
            } else {
                SVProgressHUD.dismiss()
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}
