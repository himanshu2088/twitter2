//
//  ThoughtCell.swift
//  twitter2
//
//  Created by Himanshu Joshi on 17/06/19.
//  Copyright © 2019 Himanshu Joshi. All rights reserved.
//

import UIKit
import Firebase

class ThoughtCell: UITableViewCell {

    //Outlets
    @IBOutlet weak var timestampLbl: UILabel!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var thoughtTxtLbl: UILabel!
    @IBOutlet weak var likesImg: UIImageView!
    @IBOutlet weak var numLikesLbl: UILabel!
    @IBOutlet weak var numCommentsLbl: UILabel!
    @IBOutlet weak var optionsMenu: UIImageView!
    
    //Variables
    private var thought: Thought!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        likesImg.addGestureRecognizer(tap)
        likesImg.isUserInteractionEnabled = true
    }
    
    @objc func likeTapped() {
        Firestore.firestore().collection(THOUGHTS_REF).document(thought.documentId).updateData([NUM_LIKES : thought.numLikes + 1])
    }

    func configureCell(thought: Thought) {
        optionsMenu.isHidden = true
        self.thought = thought
        usernameLbl.text = thought.username
        thoughtTxtLbl.text = thought.thoughtTxt
        numLikesLbl.text = String(thought.numLikes)
        numCommentsLbl.text = String(thought.numComments)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, hh:mm"
        let timestamp = formatter.string(from: thought.timestamp)
        timestampLbl.text = timestamp
        
        if thought.userId == Auth.auth().currentUser?.uid {
            optionsMenu.isHidden = false
            optionsMenu.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(optionsMenuTapped))
            optionsMenu.addGestureRecognizer(tap)
        }
    }
    
    @objc func optionsMenuTapped() {
        // send that thought to the mainVC to delete or edit that thought using protocols and delegates.
    }
    
}
