//
//  Thought.swift
//  twitter2
//
//  Created by Himanshu Joshi on 17/06/19.
//  Copyright © 2019 Himanshu Joshi. All rights reserved.
//

import UIKit
import Firebase

class Thought {
    
    private(set) var username: String!
    private(set) var timestamp: Date!
    private(set) var thoughtTxt: String!
    private(set) var numLikes: Int!
    private(set) var numComments: Int!
    private(set) var documentId: String!
    private(set) var userId: String!
    
    init(username: String, timestamp: Date, thoughtTxt: String, numLikes: Int, numComments: Int, documentId: String, userId: String) {
        self.username = username
        self.timestamp = timestamp
        self.thoughtTxt = thoughtTxt
        self.numLikes = numLikes
        self.numComments = numComments
        self.documentId = documentId
        self.userId = userId
    }

    class func parseData(snapshot: QuerySnapshot?) -> [Thought] {
        var thoughts = [Thought]()
        guard let documents = snapshot?.documents else { return thoughts }
        for document in documents {
            let data = document.data()
            let username = data["username"] as? String ?? "Anonymous"
            let timestamp = data["timestamp"] as? Timestamp ?? Timestamp()
            let thoughtTxt = data["thoughtTxt"] as? String ?? ""
            let numLikes = data["numLikes"] as? Int ?? 0
            let numComments = data["numComments"] as? Int ?? 0
            let documentId = document.documentID
            let userId = data[USER_ID] as? String ?? ""
            
            let newThought = Thought(username: username, timestamp: timestamp.dateValue(), thoughtTxt: thoughtTxt, numLikes: numLikes, numComments: numComments, documentId: documentId, userId: userId)
            
            thoughts.append(newThought)
        }
        return thoughts
    }
    
}
