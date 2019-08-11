//
//  UpdateCommentVC.swift
//  twitter2
//
//  Created by Himanshu Joshi on 21/07/19.
//  Copyright © 2019 Himanshu Joshi. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class UpdateCommentVC: UIViewController {
    
    //Outlets
    @IBOutlet weak var commentUpdateLbl: UITextView!
    @IBOutlet weak var updateBtn: UIButton!
    
    //Variables
    var commentData: (comment: Comment, thought: Thought)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commentUpdateLbl.text = commentData.comment.commentTxt
    }
    
    @IBAction func updateBtnPressed(_ sender: UIButton) {
        
            SVProgressHUD.show()
        Firestore.firestore().collection(THOUGHTS_REF).document(commentData.thought.documentId).collection(COMMENTS_REF).document(commentData.comment.documentId).updateData([COMMENT_TXT : commentUpdateLbl.text]) { (error) in
            if let error = error {
                debugPrint("Error while updating comment text")
            } else {
                SVProgressHUD.dismiss()
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
}
