//
//  sessionStorage.swift
//  chatting-application
//
//  Created by Omar Amer on 05/03/2021.
//

import Foundation
import Firebase

struct User {
    var uid: String
    var email: String
}

class SessionStore: ObservableObject {
    @Published var session: User?
    @Published var isAnon: Bool = false
    @Published var loading: Bool = false
    @Published var loadingPercentage: CGFloat = 0.0
    private var db = Firestore.firestore()
    var handle: AuthStateDidChangeListenerHandle?
    var authRef = Auth.auth()
    
    
    func listen() {
        handle = authRef.addStateDidChangeListener({(auth, user) in
            if let user = user {
                self.isAnon = false
                self.session = User(uid: user.uid, email: user.email!)
                
                self.db.collection("users").whereField("email", isEqualTo: user.email!).addSnapshotListener { (data, err) in
                    
                    guard let document = data?.documents else {
                        print("no docs found")
                        return
                    }
                    
                    if document.count != 0 {
                        if document[0].data()["uid"] != nil {
                            if document[0].data()["uid"] as! String == "" {
                                document[0].reference.updateData(["uid" : user.uid])
                            }
                        }
                    }
                }
                
            } else {
                self.isAnon = true
                self.session = nil
            }
        })
    }
    
    func signIn(email: String, password: String, handler: @escaping (Bool, String) -> Void) {
        
        loading = true
        loadingPercentage = 0.0
        
        authRef.signIn(withEmail: email, password: password) { (results, err) in
            self.loadingPercentage = 0.6
            if let err = err {
                print(err)
                handler(false, "incorrect username or password")
            }
        }
        
        loadingPercentage = 1
        loading = false
    }
    
    func signUp(username: String, email: String, password: String, firstName: String, lastName: String, handler: @escaping (_ done: Bool,_ err: String) -> Void) {
        
        loading = true
        loadingPercentage = 0.0
        
        checkUsername(username, handler: { (done) in
            
            self.loadingPercentage = 0.2
            
            if done {
                self.checkEmail(email) { (done) in
                    if done {
                        self.loadingPercentage = 0.4
                        
                        self.db.collection("users").addDocument(data: ["uid": "", "username": username, "email": email, "firstName": firstName, "lastName": lastName, "image": "", "online":false]) { (err) in
                            if let err = err {
                                print(err)
                                handler(false, "")
                            } else {
                                self.loadingPercentage = 0.7
                                self.authRef.createUser(withEmail: email, password: password)
                            }
                        }
                    } else {
                        handler(false, "email")
                    }
                }
            } else {
                handler(false, "username")
            }
                
        })
        self.loadingPercentage = 1
        loading = false
    }
    
    func signOut() -> Bool {
        do {
            try authRef.signOut()
            self.session = nil
            self.isAnon = true
            return true
        } catch {
            return false
        }
    }
    
    func unbind() {
        if let handle = handle {
            
            authRef.removeStateDidChangeListener(handle)
        }
    }
    
    func checkUsername(_ username: String, handler: @escaping (Bool) -> Void) {
        
        db.collection("users").whereField("username", isEqualTo: username).addSnapshotListener { (data, err) in
            guard let document = data?.documents else {
                return
            }

            print(document)

            if document.count == 0 {
                handler(true)
            } else {
                handler(false)
            }
        }
    }
    
    func checkEmail(_ email: String, handler: @escaping (Bool) -> Void) {
        db.collection("users").whereField("email", isEqualTo: email).addSnapshotListener { (data, err) in
            guard let document = data?.documents else {
                return
            }
            
            if document.count == 0 {
                handler(true)
            } else {
                handler(false)
            }
        }
    }
}

