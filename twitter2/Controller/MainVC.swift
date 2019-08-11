//
//  ViewController.swift
//  twitter2
//
//  Created by Himanshu Joshi on 16/06/19.
//  Copyright © 2019 Himanshu Joshi. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class MainVC: UIViewController, UITableViewDelegate, UITableViewDataSource, ThoughtDelegate {
    
    //Outlets
    @IBOutlet weak var segmentController: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var usernameTxtField: UITextField!
    
    //Variables
    private var thoughtsArray = [Thought]()
    private var thoughtsListener: ListenerRegistration!
    private var selectedCategory = thoughtCategory.funny.rawValue
    private var handler: AuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    override func viewWillAppear(_ animated: Bool) {
        handler = Auth.auth().addStateDidChangeListener({ (auth, user) in
            if user == nil {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let loginVC = storyboard.instantiateViewController(withIdentifier: "loginVC")
                self.present(loginVC, animated: true, completion: nil)
            } else {
                self.setListener()
                self.usernameTxtField.text = Auth.auth().currentUser?.displayName
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if thoughtsListener != nil {
            thoughtsListener.remove()
        }
    }
    
    func thoughtOptionsTapped(thought: Thought) {
        let alert = UIAlertController(title: "Edit Thought", message: "You can edit or delete Thought", preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Delete Thought", style: .default) { (action) in
            Firestore.firestore().collection(THOUGHTS_REF).document(thought.documentId).delete(completion: { (error) in
                if let error = error {
                    debugPrint("Error while deleting thought \(error.localizedDescription)")
                } else {
                    return
                }
            })
        }
        let editAction = UIAlertAction(title: "Edit Thought", style: .default) { (action) in
            self.performSegue(withIdentifier: "toUpdateThoughtVC", sender: thought)
            alert.dismiss(animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(deleteAction)
        alert.addAction(editAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    func setListener() {
        if selectedCategory == thoughtCategory.popular.rawValue {
            thoughtsListener = Firestore.firestore().collection(THOUGHTS_REF)
                .order(by: NUM_LIKES, descending: true)
                .addSnapshotListener({ (snapshot, error) in
                    if let error = error {
                        debugPrint("Error while adding listener \(error.localizedDescription)")
                    } else {
                        self.thoughtsArray.removeAll()
                        self.thoughtsArray = Thought.parseData(snapshot: snapshot)
                        self.tableView.reloadData()
                    }
                }) 
        } else {
            thoughtsListener = Firestore.firestore().collection(THOUGHTS_REF)
                .whereField(CATEGORY, isEqualTo: selectedCategory)
                .order(by: TIMESTAMP, descending: true)
                .addSnapshotListener({ (snapshot, error) in
                    if let error = error {
                        debugPrint("Error while adding listener \(error.localizedDescription)")
                    } else {
                        self.thoughtsArray.removeAll()
                        self.thoughtsArray = Thought.parseData(snapshot: snapshot)
                        self.tableView.reloadData()
                    }
                })
        }
    }

    @IBAction func categoryChanged(_ sender: UISegmentedControl) {
        switch segmentController.selectedSegmentIndex {
        case 0:
            selectedCategory = thoughtCategory.funny.rawValue
        case 1:
            selectedCategory = thoughtCategory.serious.rawValue
        case 2:
            selectedCategory = thoughtCategory.crazy.rawValue
        default:
            selectedCategory = thoughtCategory.popular.rawValue
        }
        thoughtsListener.remove()
        setListener()
    }
    
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        SVProgressHUD.show(withStatus: "Logging Out")
        do {
            try Auth.auth().signOut()
            SVProgressHUD.dismiss()
            print("Successfullt signed out")
        } catch {
            debugPrint("Error while signing out, \(error.localizedDescription)")
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "thoughtCell", for: indexPath) as? ThoughtCell else { return UITableViewCell()}
        cell.configureCell(thought: thoughtsArray[indexPath.row], delegate: self)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return thoughtsArray.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toComments", sender: thoughtsArray[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toComments" {
            if let destinationVC = segue.destination as? CommentsVC {
                if let thought = sender as? Thought {
                    destinationVC.thought = thought
                }
            }
        } else if segue.identifier == "toUpdateThoughtVC" {
            if let destinationVC = segue.destination as? UpdateThoughtVC {
                if let thoughtData = sender as? (Thought) {
                    destinationVC.thoughtData = thoughtData
                }
            }
        }
    }
    
}



    
