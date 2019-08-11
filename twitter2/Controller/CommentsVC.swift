//
//  CommentsVC.swift
//  twitter2
//
//  Created by Himanshu Joshi on 19/06/19.
//  Copyright © 2019 Himanshu Joshi. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class CommentsVC: UIViewController, CommentDelegate {
    
    var thought: Thought!
    var username: String!
    var commentListener: ListenerRegistration!
    var commentsArray = [Comment]()
    var thoughtRef: DocumentReference!
    let firestore = Firestore.firestore()

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addCommentTxt: UITextField!
    @IBOutlet weak var keyboardView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        thoughtRef = firestore.collection(THOUGHTS_REF).document(thought.documentId)
        if let name = Auth.auth().currentUser?.displayName {
            username = name
        }
        self.view.bindToKeyboard()
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        commentListener = firestore.collection(THOUGHTS_REF).document(self.thought.documentId).collection(COMMENTS_REF)
            .order(by: TIMESTAMP, descending: true)
            .addSnapshotListener({ (snapshot, error) in
                guard let snapshot = snapshot else {
                    debugPrint("Error fetching comments \(error?.localizedDescription)")
                    return
                }
                
                self.commentsArray.removeAll()
                self.commentsArray = Comment.parseData(snapshot: snapshot)
                self.tableView.reloadData()
                
            })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        commentListener.remove()
    }
    
    func commentOptionsTapped(comment: Comment) {
        let alert = UIAlertController(title: "Edit Comment", message: "You can edit or delete Comment", preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Delete Comment", style: .default) { (action) in
            
            self.firestore.runTransaction({ (transaction, errorPointer) -> Any? in
                
                let thoughtDocument: DocumentSnapshot
                
                do {
                    try thoughtDocument = transaction.getDocument(Firestore.firestore().collection(THOUGHTS_REF).document(self.thought.documentId))
                } catch let error as NSError {
                    debugPrint("Fetch error, \(error.localizedDescription)")
                    return nil
                }
                
                guard let oldNumComments = thoughtDocument.data()![NUM_COMMENTS] as? Int else { return nil}
                
                transaction.updateData([NUM_COMMENTS: oldNumComments - 1], forDocument: self.thoughtRef)
                
                let newCommentRef = self.firestore.collection(THOUGHTS_REF).document(self.thought.documentId).collection(COMMENTS_REF).document(comment.documentId)
                
                transaction.deleteDocument(newCommentRef)
                
                return nil
                
            }) { (object, error) in
                if let error = error {
                    debugPrint("Transaction failed, \(error.localizedDescription)")
                } else {
                    alert.dismiss(animated: true, completion: nil)
                    self.navigationController?.popViewController(animated: true)
                }
            }
            
        }
        let editAction = UIAlertAction(title: "Edit Comment", style: .default) { (action) in
            self.performSegue(withIdentifier: "toUpdateCommentVC", sender: (comment, self .thought))
            alert.dismiss(animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(deleteAction)
        alert.addAction(editAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? UpdateCommentVC {
            if let commentData = sender as? (comment: Comment, thought: Thought) {
                destinationVC.commentData = commentData
            }
        }
    }
    
    @IBAction func sendBtnTapped(_ sender: UIButton) {
        
        SVProgressHUD.show()
        
        guard let commentTxt = addCommentTxt.text else { return }
        
        if commentTxt == "" {
            SVProgressHUD.dismiss()
            let alert = UIAlertController(title: "Error", message: "Please write something to add comment.", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            return
        }
        
        firestore.runTransaction({ (transaction, errorPointer) -> Any? in
            
            let thoughtDocument: DocumentSnapshot
            
            do {
                try thoughtDocument = transaction.getDocument(self.thoughtRef)
            } catch let error as NSError {
                debugPrint("Fetch error, \(error.localizedDescription)")
                return nil
            }
            
            guard let oldNumComments = thoughtDocument.data()![NUM_COMMENTS] as? Int else { return nil}
            
            transaction.updateData([NUM_COMMENTS: oldNumComments + 1], forDocument: self.thoughtRef)
            
            let newCommentRef = self.firestore.collection(THOUGHTS_REF).document(self.thought.documentId).collection(COMMENTS_REF).document()
            
            transaction.setData([
                COMMENT_TXT: commentTxt,
                TIMESTAMP: FieldValue.serverTimestamp(),
                USERNAME: self.username,
                USER_ID: Auth.auth().currentUser?.uid ?? ""
                ], forDocument: newCommentRef)
            
            return nil
            
        }) { (object, error) in
            if let error = error {
                debugPrint("Transaction failed, \(error.localizedDescription)")
            } else {
                SVProgressHUD.dismiss()
                self.addCommentTxt.text = ""
                self.addCommentTxt.resignFirstResponder()
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

extension CommentsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as? CommentCell {
            cell.configureCell(comment: commentsArray[indexPath.row], delegate: self)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentsArray.count
    }
    
}
