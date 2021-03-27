//
//  Login.swift
//  chatting-application
//
//  Created by Omar Amer on 05/03/2021.
//

import SwiftUI

struct Login: View {
    
    @State private var email = ""
    @State private var password = ""
    @State private var error = ""
    
    @ObservedObject var sessionStore = SessionStore()
    
    var body: some View {
        
        NavigationView {
        
            ZStack {

                Color("background")
                    .ignoresSafeArea()
                
                VStack {
                    
                    Loading(loadingPercentage: sessionStore.loadingPercentage)
                    
                    Text(error)
                        .foregroundColor(.red)
                        .padding()


                    inputField(name: "Email", saving: $email, secure: false)
                        .padding()
                        .background(Color("searchBarColor"))
                        .cornerRadius(10.0)
                        .textContentType(.emailAddress)
                        .onChange(of: email, perform: { value in
                            error = ""
                        })

                    inputField(name: "Password", saving: $password, secure: true)
                        .padding()
                        .background(Color("searchBarColor"))
                        .cornerRadius(10.0)
                        .textContentType(.password)
                        .onChange(of: password, perform: { value in
                            error = ""
                        })

                    Spacer()
                    
                }
                .navigationTitle("Login")
                .navigationBarItems(

                    leading:
                        NavigationLink(destination: Signin(), label: {
                            Text("Sign in")
                        })
                        .disabled(sessionStore.loading),

                    trailing:
                        Button("Login") {

                            if email != "" && password != "" {

                                sessionStore.signIn(email: email, password: password) { (done, err) in
                                    if !done {
                                        error = err
                                    } else {
                                        error = ""
                                    }
                                }

                            } else {
                                error = "Fill all empty fields"
                            }
                        }
                        .disabled(sessionStore.loading)
                )
                .navigationBarBackButtonHidden(true)

            }
        }
    }
}

struct Signin: View {

    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var email = ""
    @State private var username = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var error = ""
    @State private var emailErr = false
    @State private var usernameErr = false
    
    @ObservedObject var sessionStore = SessionStore()

    var body: some View {

        ZStack {

            Color("background")
                .ignoresSafeArea()

            VStack {
                
                Loading(loadingPercentage: sessionStore.loadingPercentage)
                
                Text(error)
                    .foregroundColor(.red)
                    .padding()
                
                inputField(name: "Username", saving: $username, secure: false)
                    .padding()
                    .background(usernameErr ? Color.red : Color("searchBarColor"))
                    .cornerRadius(10.0)
                    .textContentType(.username)
                    .onChange(of: username, perform: { value in
                        usernameErr = false
                    })
                
                inputField(name: "First Name", saving: $firstName, secure: false)
                    .padding()
                    .background(Color("searchBarColor"))
                    .cornerRadius(10.0)
                    .textContentType(.givenName)
                
                inputField(name: "Last Name", saving: $lastName, secure: false)
                    .padding()
                    .background(Color("searchBarColor"))
                    .cornerRadius(10.0)
                    .textContentType(.familyName)
                
                inputField(name: "Email", saving: $email, secure: false)
                    .padding()
                    .background(emailErr ? Color.red : Color("searchBarColor"))
                    .cornerRadius(10.0)
                    .onChange(of: email, perform: { value in
                        emailErr = false
                    })
                    .textContentType(.emailAddress)

                inputField(name: "Password", saving: $password, secure: true)
                    .padding()
                    .background(Color("searchBarColor"))
                    .cornerRadius(10.0)
                    .textContentType(.password)

                inputField(name: "Confirm Password", saving: $confirmPassword, secure: true)
                    .padding()
                    .background(Color("searchBarColor"))
                    .cornerRadius(10.0)
                    .textContentType(.password)

                Spacer()
            }
            .navigationTitle("Sign In")
            .navigationBarBackButtonHidden(sessionStore.loading)
            .navigationBarItems(

                trailing:
                    Button("Sign In") {

                        if username != "" && firstName != "" && lastName != "" && email != "" && password != "" && confirmPassword != "" {

                            if !username.contains(" ") && !firstName.contains(" ") && !lastName.contains(" ") && !email.contains(" ") && !password.contains(" ") {

                                if password == confirmPassword {
                                    sessionStore.signUp(username: username, email: email, password: password, firstName: firstName, lastName: lastName) { (done, err) in
                                        if !done {
                                            if err == "email" {
                                                emailErr = true
                                                usernameErr = false
                                                error = ""
                                            } else if err == "username" {
                                                emailErr = false
                                                usernameErr = true
                                                error = ""
                                            } else {
                                                emailErr = false
                                                usernameErr = false
                                                error = "cannot sign up"
                                            }
                                        }
                                    }
                                    

                                } else {
                                    error = "passwords are not matched"
                                }

                            } else {
                                error = "spaces are not allowed"
                            }

                        } else {
                            error = "fill all empty fields"
                        }

                    }
                    .disabled(sessionStore.loading)
            )
        }
    }
}
