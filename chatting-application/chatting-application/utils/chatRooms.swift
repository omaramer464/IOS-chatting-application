//
//  chatRooms.swift
//  chatting-application
//
//  Created by Omar Amer on 05/03/2021.
//

import Foundation
import Firebase

struct Chatroom: Codable, Identifiable {
    var id: String
    var title: String
    var image: String
    var time: String
    var new: Bool
    var lastMessage: String
    var typing: Bool
    var unreadMessages: Int
}

struct SearchResults: Codable, Identifiable {
    var id: String
    var username: String
    var image: String
    var status: String
}

struct Messages: Codable, Identifiable, Equatable, Hashable {
    var id: String
    var mine: Bool
    var message: String
    var time: String
    var seen: Bool
    var isAI:Bool
}

struct CurrentUser: Codable, Identifiable, Equatable {
    var id: String
    var username: String
    var firstName: String
    var lastName: String
    var image: String
    var email: String
}

class ChatroomsViewModel: ObservableObject {
    
    @Published var chatrooms = [Chatroom]()
    @Published var searchResults = [SearchResults]()
    @Published var messages = [Messages]()
    @Published var currentUser = [CurrentUser]()
    @Published var typing = false
    @Published var loading = false
    @Published var loadingPercentage: CGFloat = 0.0
    private var db = Firestore.firestore()
    private var user = Auth.auth().currentUser
    
    func offline() {
        if user != nil {
            self.db.collection("users").whereField("uid", isEqualTo: self.user!.uid).addSnapshotListener { (data, err) in
                
                guard let document = data?.documents else {
                    print("no docs found")
                    return
                }
                
                if document.count != 0 {
                    if document[0].data()["uid"] != nil {
                        document[0].reference.updateData(["online" : false])
                    }
                }
            }
        }
    }
    
    func online() {
        if user != nil {
            self.db.collection("users").whereField("uid", isEqualTo: self.user!.uid).addSnapshotListener { (data, err) in
                
                guard let document = data?.documents else {
                    print("no docs found")
                    return
                }
                
                if document.count != 0 {
                    if document[0].data()["uid"] != nil {
                        document[0].reference.updateData(["online" : true])
                    }
                }
            }
        }
    }
    
    func getUserData() {
        if user != nil {
            db.collection("users").whereField("uid", isEqualTo: self.user!.uid).addSnapshotListener { (data, err) in
                if let document = data?.documents {
                    self.currentUser = document.map({ (data2) -> CurrentUser in
                        
                        let all = data2.data()
                        
                        let id = all["uid"] as? String ?? ""
                        let username = all["username"] as? String ?? ""
                        let firstName = all["firstName"] as? String ?? ""
                        let lastName = all["lastName"] as? String ?? ""
                        let image = all["image"] as? String ?? ""
                        let email = all["email"] as? String ?? ""
                        
                        return CurrentUser(id: id, username: username, firstName: firstName, lastName: lastName, image: image, email: email)
                        
                    })
                }
            }
        }
    }
    
    func inChat(_ status:Bool, id:String) {
        if user != nil {
            if status {
                
                db.collection("chats").document(id).getDocument { (data, err) in
                    if let document = data?.data(), data?.data() != nil {
                        
                        var allMessages:[[String:Any]] = []
                        
                        for message in document["messages"] as! [[String:Any]] {
                            if !(message["seen"] as! Bool) {
                                if message["senderUID"] as! String != self.user!.uid {
                                    let obj = [
                                        "message":message["message"] as? String ?? "",
                                        "messageID": message["messageID"] as? String ?? "",
                                        "senderUID": message["senderUID"] as? String ?? "",
                                        "time": message["time"] as Any,
                                        "seen": true
                                    ]
                                    
                                    allMessages.append(obj)
                                } else {
                                    allMessages.append(message)
                                }
                            } else {
                                allMessages.append(message)
                            }
                        }
                        
                        self.db.collection("chats").document(id).updateData(["online" : FieldValue.arrayUnion([self.user!.uid]), "messages": allMessages])
                    }
                }
            } else {
                
                self.db.collection("chats").document(id).getDocument { (data, err) in
                    if let document = data?.data(), data?.data() != nil {
                        
                        for i in document["messages"] as! [[String:Any]] {
                            if (i["senderUID"] as! String).contains("UNREADAI") {
                                if (i["senderUID"] as! String).components(separatedBy: ".")[1] != self.user!.uid {
                                    
                                    self.db.collection("chats").document(id).updateData(["messages" : FieldValue.arrayRemove([i])])
                                }
                            }
                        }
                        
                    }
                }
                
                self.db.collection("chats").document(id).updateData(["online" : FieldValue.arrayRemove([self.user!.uid])])
            }
        }
    }
    
    func fetchData() {
        if user != nil {
            
            loading = true
            loadingPercentage = 0.0
            
            db.collection("chats").addSnapshotListener { (result, err) in
                self.db.collection("chats").whereField("users", arrayContains: self.user!.uid).order(by: "finalMessage", descending: false).addSnapshotListener { (snapshot, err) in
                    guard let documents = snapshot?.documents else {
                        print("no docs found")
                        return
                    }
                    
                    self.loadingPercentage = 0.1
                    
                    var allIds:[String] = []
                    
                    for x in documents {
                        let data = x.data()
                        
                        for i in data["users"] as! [String] {
                            if i != self.user!.uid {
                                allIds.append(i)
                            }
                        }
                    }
                    
                    self.loadingPercentage = 0.2
                    
                    self.db.collection("users").whereField("uid", in: allIds).getDocuments { (snapshot2, err) in
                        guard let documents2 = snapshot2?.documents else {
                            print("no docs found")
                            return
                        }
                        
                        var allUsers:[String:[String:String]] = [:]
                        
                        self.loadingPercentage = 0.3

                        for j in documents2 {
                            let data2 = j.data()
                            allUsers[data2["uid"] as? String ?? ""] = ["username": data2["username"] as? String ?? "", "image": data2["image"] as? String ?? ""]
                        }
                        
                        self.loadingPercentage = 0.6

                        for doc in documents {
                            
                            let docId = doc.documentID
                            
                            self.db.collection("chats").document(docId).addSnapshotListener { (snapshot3, err) in
                                
                                if let data3 = snapshot3?.data(), snapshot3?.data() != nil {
                                    
                                    self.chatrooms = documents.map({ document -> Chatroom in
                                        
                                        let docId = document.documentID
                                    
                                        var time = ""
                                        var new = false
                                        var lastMessage = ""

                                        if (data3["messages"] as! [[String:Any]]).count != 0 {
                                            time = ChatDateAndTime(timestamp: data3["finalMessage"] as Any)
                                            new = false

                                            if ((data3["messages"] as! [[String:Any]])[(data3["messages"] as! [[String:Any]]).count - 1]["senderUID"] as! String) == self.user!.uid {
                                                lastMessage = "You: \(String(describing: (data3["messages"] as! [[String:Any]])[(data3["messages"] as! [[String:Any]]).count - 1]["message"]!))"
                                            } else {
                                                lastMessage = "\(String(describing: (data3["messages"] as! [[String:Any]])[(data3["messages"] as! [[String:Any]]).count - 1]["message"]!))"
                                            }
                                        } else {
                                            time = ChatDateAndTime(timestamp: data3["created"] as Any)
                                            new = true
                                            lastMessage = ""
                                        }
                                        
                                        var unreadMessages = 0
                                        
                                        for message in data3["messages"] as! [[String:Any]] {
                                            if !(message["seen"] as! Bool) {
                                                if message["senderUID"] as! String != self.user!.uid {
                                                    unreadMessages += 1
                                                }
                                            }
                                        }
                                        
                                        var all:[String] = data3["users"] as! [String]
                                        let index = all.firstIndex(of: self.user!.uid)
                                        all.remove(at: index!)
                                        
                                        var typing = false
                                        
                                        if (data3["typing"] as? [String] ?? []).contains(all[0]) {
                                            typing = true
                                        } else {
                                            typing = false
                                        }
                                        
                                        let title = (allUsers[all[0]])?["username"] ?? ""
                                        let image = (allUsers[all[0]])?["image"] ?? ""
                                        
                                        return Chatroom(id: docId, title: title, image: image, time:time, new:new, lastMessage: lastMessage, typing: typing, unreadMessages: unreadMessages)
                                    })
                                }
                                
                            }
                        }
                    }
                }
            }
            
            self.loadingPercentage = 1
            self.loading = false
        }
    }
    
    func AddChat(uid:String, type:String, handler: @escaping (Bool) -> Void) {
        if user != nil {
            db.collection("chats").addDocument(data: ["type": type, "users": [user!.uid, uid], "messages": [], "created": Timestamp(date: Date()), "typing": [], "finalMessage":Timestamp(date:Date()), "online":[]]) { err in
                if let err = err {
                    print("there is an error in adding chat: \(err)")
                    handler(false)
                } else {
                    handler(true)
                }
            }
        }
    }
    
    func removeChat(id:String) {
        if user != nil {
            db.collection("chats").document(id).delete()
        }
    }
    
    func Search(_ search: String, handler: @escaping (Bool) -> Void) {
        if user != nil {
            db.collection("users").whereField("username", isGreaterThanOrEqualTo: search).order(by: "username", descending: false).addSnapshotListener { (data, err) in
                guard let documents = data?.documents else {
                    print("no docs found")
                    handler(false)
                    return
                }
                
                self.db.collection("chats").whereField("users", arrayContains: self.user!.uid).addSnapshotListener { (data, err) in
                    guard let document = data?.documents else {
                        print("no docs found")
                        handler(false)
                        return
                    }
                    
                    var inChat = [""]
                    
                    for i in document {
                        let data = i.data()
                        let all:[String] = data["users"] as! [String]
                        
                        for x in all {
                            if x != self.user!.uid {
                                inChat.append(x)
                            }
                        }
                    }
                    
                    self.searchResults = documents.map({ docSnapshot -> SearchResults in
                        let data = docSnapshot.data()
                        let username = data["username"] as? String ?? ""
                        let image = data["image"] as? String ?? ""
                        let uid = data["uid"] as? String ?? ""
                        var status = ""
                        
                        if uid == self.user!.uid {
                            status = "me"
                        } else {
                            if inChat.contains(uid) {
                                status = "added"
                            } else {
                                status = "add"
                            }
                        }
                        
                        return SearchResults(id: uid, username: username, image: image, status: status)
                    })
                    
                    handler(true)
                }
            }
        }
    }
    
    func getMessages(_ id:String, handler: @escaping (Bool) -> Void) {
        if user != nil {
            
            loading = true
            loadingPercentage = 0.0
            
            db.collection("chats").document(id).addSnapshotListener({ (data, err) in
                if let document = data?.data(), data?.data() != nil {
                    
                    self.loadingPercentage = 0.4
                    
                    var messagesLoadingPercentage = 0
                    
                    if (document["messages"] as! [[String:Any]]).count != 0 {
                        messagesLoadingPercentage = 5 / (document["messages"] as! [[String:Any]]).count
                    }
                    
                    self.messages = (document["messages"] as! [[String:Any]]).map({ message -> Messages in
                        
                        self.loadingPercentage += CGFloat(messagesLoadingPercentage)
                        
                        var id = ""
                        var mine = false
                        let text = message["message"] as? String ?? ""
                        var time = MessageTime(timestamp: message["time"] as Any)
                        let seen = message["seen"] as? Bool ?? false
                        var isAI = false
                        
                        let sender = message["senderUID"] as? String ?? ""
                        
                        if sender == self.user!.uid {
                            mine = true
                            isAI = false
                            id = "\(message["messageID"] as? String ?? "")"
                            
                        } else if sender.contains("UNREADAI") {
                                   
                            if (sender.components(separatedBy: "."))[1] == self.user!.uid {
                                mine = true
                            } else {
                                mine = false
                            }
                            
                            isAI = true
                            id = "UNREADAI.\(message["messageID"] as? String ?? "")"
                            
                        } else if sender == "AI" {
                            isAI = true
                            mine = false
                            time = ChatMessagesDateAndTime(timestamp: message["time"] as Any)
                            id = "AI.\(message["messageID"] as? String ?? "")"
                        } else {
                            
                            mine = false
                            isAI = false
                            id = "\(message["messageID"] as? String ?? "")"
                            
                        }
                        
                        
                        
                        return Messages(id: id, mine: mine, message: text, time: time, seen: seen,isAI: isAI)
                    })
                    
                    self.loadingPercentage = 1
                    self.loading = false
                    
                } else {
                    handler(false)
                }
            })
                
                
        }
    }
    
    func sendMessage(id:String, message:String, handler: @escaping (Bool) -> Void) {
        if user != nil {
            
            db.collection("chats").document(id).getDocument { (data, err) in
                guard let document = data?.data() else {
                    return
                }
                
                if (document["messages"] as? [[String:Any]] ?? []).count == 0 {
                    
                    self.db.collection("chats").document(id).updateData([
                        "messages": FieldValue.arrayUnion([[
                            "message": "",
                            "messageID": UUID().uuidString,
                            "senderUID": "AI",
                            "seen": true,
                            "time": Timestamp(date: Date())
                        ]])
                    ])
                    
                } else {
                    if DateChecker(timestamp: document["finalMessage"] as Any ) != "today" {
                        self.db.collection("chats").document(id).updateData([
                            "messages": FieldValue.arrayUnion([[
                                "message": "",
                                "messageID": UUID().uuidString,
                                "senderUID": "AI",
                                "seen": true,
                                "time": Timestamp(date: Date())
                            ]])
                        ])
                    }
                }
                
                if (document["online"] as? [String] ?? []).count == 1 {
                    
                    if (((document["messages"] as! [[String:Any]])[(document["messages"] as! [[String:Any]]).count - 1])["seen"] as! Bool) {
                        
                        self.db.collection("chats").document(id).updateData([
                            "messages": FieldValue.arrayUnion([[
                                "message": "New Messages",
                                "messageID": UUID().uuidString,
                                "senderUID": "UNREADAI.\(self.user!.uid)",
                                "seen": true,
                                "time": Timestamp(date: Date())
                            ],
                            [
                                "message": message,
                                "messageID": UUID().uuidString,
                                "senderUID": self.user!.uid,
                                "seen": false,
                                "time": Timestamp(date: Date())
                            ]]),
                            "finalMessage": Timestamp(date:Date()),
                        ])
                        
                    } else {
                        self.db.collection("chats").document(id).updateData([
                            "messages": FieldValue.arrayUnion([[
                                "message": message,
                                "messageID": UUID().uuidString,
                                "senderUID": self.user!.uid,
                                "seen": false,
                                "time": Timestamp(date: Date())
                            ]]),
                            "finalMessage": Timestamp(date:Date()),
                        ])
                    }
                } else if (document["online"] as? [String] ?? []).count != 1 {
                    self.db.collection("chats").document(id).updateData([
                        "messages": FieldValue.arrayUnion([[
                            "message": message,
                            "messageID": UUID().uuidString,
                            "senderUID": self.user!.uid,
                            "seen": true,
                            "time": Timestamp(date: Date())
                        ]]),
                        "finalMessage": Timestamp(date:Date()),
                    ])
                }
                
                self.db.collection("chats").document(id).getDocument { (data, err) in
                    if let document = data?.data(), data?.data() != nil {
                        
                        for i in document["messages"] as! [[String:Any]] {
                            if (i["senderUID"] as! String).contains("UNREADAI") {
                                if ((i["senderUID"] as! String).components(separatedBy: "."))[1] != self.user!.uid {
                                    self.db.collection("chats").document(id).updateData([
                                        "messages" : FieldValue.arrayRemove([i])
                                    ])
                                }
                            }
                        }
                        
                    }
                }
                
            }
        }
    }
    
    func deleteMessage(id:String, messageID: String) {
        if user != nil {
            
            db.collection("chats").document(id).getDocument { (data, err) in
                if let document = data?.data(), data?.data() != nil {
                    
                    for x in document["messages"] as! [[String:Any]] {
                        if x["messageID"] as! String == messageID {
                            
                            if ((document["messages"] as! [[String:Any]])[(document["messages"] as! [[String:Any]]).count - 1])["messageID"] as! String == x["messageID"] as! String {
                                
                                if ((document["messages"] as! [[String:Any]])[(document["messages"] as! [[String:Any]]).count - 2])["senderUID"] as! String == "AI" {
                                    
                                    if (document["messages"] as! [[String:Any]]).count > 2 {
                                        self.db.collection("chats").document(id).updateData([
                                            "messages": FieldValue.arrayRemove([x,(document["messages"] as! [[String:Any]])[(document["messages"] as! [[String:Any]]).count - 2]]),
                                            "finalMessage": ((document["messages"] as! [[String:Any]])[(document["messages"] as! [[String:Any]]).count - 3])["time"] as Any
                                        ])
                                    } else {
                                        self.db.collection("chats").document(id).updateData([
                                            "messages": FieldValue.arrayRemove([x,(document["messages"] as! [[String:Any]])[(document["messages"] as! [[String:Any]]).count - 2]]),
                                            "finalMessage": (document["created"] as Any)
                                        ])
                                    }
                                    
                                } else {
                                    
                                    if (document["messages"] as! [[String:Any]]).count > 1 {
                                        self.db.collection("chats").document(id).updateData([
                                            "messages": FieldValue.arrayRemove([x]),
                                            "finalMessage": ((document["messages"] as! [[String:Any]])[(document["messages"] as! [[String:Any]]).count - 2])["time"] as Any
                                        ])
                                    } else {
                                        self.db.collection("chats").document(id).updateData([
                                            "messages": FieldValue.arrayRemove([x]),
                                            "finalMessage": (document["created"] as Any)
                                        ])
                                    }
                                }
                                
                            } else {
                                self.db.collection("chats").document(id).updateData([
                                    "messages": FieldValue.arrayRemove([x])
                                ])
                            }
                        }
                    }
                }
            }
            
        }
    }
    
    func typing(_ id:String, handler: @escaping (Bool) -> Void) {
        if user != nil {
            db.collection("chats").document(id).addSnapshotListener({ (data, err) in
                if let document = data?.data(), data?.data() != nil {
                    
                    var them = ""
                    
                    for x in document["users"] as? [String] ?? [] {
                        if x != self.user!.uid {
                            them = x
                        }
                    }
                    
                    if (document["typing"] as? [String] ?? []).count != 0 {
                        if (document["typing"] as? [String] ?? []).contains(them) {
                            self.typing = true
                        } else {
                            self.typing = false
                        }
                    }
                    
                } else {
                    handler(false)
                }
            })
        }
    }
    
    func IsTyping(_ id:String, typing:Bool) {
        if user != nil {
            
            if typing {
                db.collection("chats").document(id).updateData([
                    "typing": FieldValue.arrayUnion([self.user!.uid])
                ])
            } else {
                db.collection("chats").document(id).updateData([
                    "typing": FieldValue.arrayRemove([self.user!.uid])
                ])
            }
            
            
        }
    }
}
