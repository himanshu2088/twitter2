//
//  AddThoughtVC.swift
//  twitter2
//
//  Created by Himanshu Joshi on 16/06/19.
//  Copyright © 2019 Himanshu Joshi. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation

class AddThoughtVC: UIViewController, UITextViewDelegate {
    
    //Outlets
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var thoughtTxtView: UITextView!
    
    //Variables
    private var selectedCategory = thoughtCategory.funny.rawValue
    private var username = Auth.auth().currentUser?.displayName
    private var userId = Auth.auth().currentUser?.uid
    
    var captureSession: AVCaptureSession!
    var cameraOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var photoData: Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        thoughtTxtView.text = "My random thought..."
        thoughtTxtView.textColor = UIColor.lightGray
        thoughtTxtView.delegate = self
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        thoughtTxtView.text = ""
        thoughtTxtView.textColor = UIColor.darkGray
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
        if thoughtTxtView.text == "My random thought..." || thoughtTxtView.text == "" {
            let alert = UIAlertController(title: "Error", message: "Please write something to post your thought.", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        } else {
            
            Firestore.firestore().collection(THOUGHTS_REF).addDocument(data: [
                CATEGORY : selectedCategory,
                NUM_COMMENTS : 0,
                NUM_LIKES : 0,
                THOUGHT_TXT : thoughtTxtView.text!,
                TIMESTAMP : FieldValue.serverTimestamp(),
                USERNAME : username,
                USER_ID : userId
            ]) { (error) in
                if let error = error {
                    debugPrint("Error adding document, \(error.localizedDescription)")
                } else {
                    self.navigationController?.popViewController(animated: true)
                    print("Successfully created Thought")
                }
            }
        }
    }
    
    @IBAction func addPhotoBtnPressed(_ sender: UIButton) {
        
        
        
    }
    
}
