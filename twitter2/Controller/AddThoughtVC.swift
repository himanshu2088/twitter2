//
//  AddThoughtVC.swift
//  twitter2
//
//  Created by Himanshu Joshi on 16/06/19.
//  Copyright © 2019 Himanshu Joshi. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class AddThoughtVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    //Outlets
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var thoughtTextField: UITextField!
    @IBOutlet weak var keyboardView: UIView!
    
    //Variables
    private var selectedCategory = thoughtCategory.funny.rawValue
    private var username = Auth.auth().currentUser?.displayName
    private var userId = Auth.auth().currentUser?.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.bindToKeyboard()
        self.hideKeyboardWhenTappedAround()
    }
    
    @IBAction func segmentController(_ sender: UISegmentedControl) {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            selectedCategory = thoughtCategory.funny.rawValue
        case 1:
            selectedCategory = thoughtCategory.serious.rawValue
        default:
            selectedCategory = thoughtCategory.crazy.rawValue
        }
    }
    
    @IBAction func postBtnPressed(_ sender: UIButton) {
        
        SVProgressHUD.show()
        
        if thoughtTextField.text == "Add thought..." || thoughtTextField.text == "" {
            SVProgressHUD.dismiss()
            let alert = UIAlertController(title: "Error", message: "Please write something to post your thought.", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        } else {
            
            Firestore.firestore().collection(THOUGHTS_REF).addDocument(data: [
                CATEGORY : selectedCategory,
                NUM_COMMENTS : 0,
                NUM_LIKES : 0,
                THOUGHT_TXT : thoughtTextField.text!,
                TIMESTAMP : FieldValue.serverTimestamp(),
                USERNAME : username,
                USER_ID : userId
            ]) { (error) in
                if let error = error {
                    debugPrint("Error adding document, \(error.localizedDescription)")
                } else {
                    SVProgressHUD.dismiss()
                    self.navigationController?.popViewController(animated: true)
                    print("Successfully created Thought")
                }
            }
            }
        }
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(disissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func disissKeyboard() {
        view.endEditing(true)
    }
        
}
