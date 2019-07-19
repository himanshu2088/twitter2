//
//  Comment.swift
//  twitter2
//
//  Created by Himanshu Joshi on 19/06/19.
//  Copyright © 2019 Himanshu Joshi. All rights reserved.
//

import UIKit
import Firebase

class Comment {
    
    private(set) var username: String!
    private(set) var timestamp: Date!
    private(set) var commentTxt: String!
    private(set) var numComments: Int!
    private(set) var documentId: String!
    private(set) var userId: String!
    
    init(username: String, timestamp: Date, commentTxt: String, numComments: Int,documentId: String, userId: String) {
        self.username = username
        self.timestamp = timestamp
        self.commentTxt = commentTxt
        self.numComments = numComments
        self.documentId = documentId
        self.userId = userId
    }
    
    class func parseData(snapshot: QuerySnapshot?) -> [Comment] {
        var comments = [Comment]()
        
        guard let snap = snapshot else { return comments}
        
        for document in snap.documents {
            let data = document.data()
            let username = data[USERNAME] as? String ?? "Anonymous"
            let timeStamp = data[TIMESTAMP] as? Timestamp ?? Timestamp()
            let commentTxt = data[COMMENT_TXT] as? String ?? ""
            let numComments = data[NUM_COMMENTS] as? Int ?? 0
            let documentId = document.documentID
            let userId = data[USER_ID] as? String ?? ""
            
            let newComment = Comment(username: username, timestamp: timeStamp.dateValue(), commentTxt: commentTxt, numComments: numComments, documentId: documentId, userId: userId)
            
            comments.append(newComment)
        }
        return comments
    }
    
}
