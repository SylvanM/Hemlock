//
//  WelcomeViewController.swift
//  Hemlock
//
//  Created by Sylvan Martin on 7/25/24.
//

import Cocoa

class WelcomeViewController: NSViewController, NSTextFieldDelegate {
    
    // MARK: Properties

    var shouldCreateAccount = false
    
    @IBOutlet weak var emailTextField: NSTextField!
    @IBOutlet weak var passwordTextField: NSSecureTextField!
    @IBOutlet weak var confirmPasswordTextField: NSSecureTextField!
    
    @IBOutlet weak var confirmButton: NSButton!
    @IBOutlet weak var instructionLabel: NSTextField!
    
    // MARK: View Controller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if SavedUserData.savedDataExists() {
            
            confirmButton.title = "Login"
            instructionLabel.stringValue = "Please login"
            
            passwordTextField.delegate = self
            
            confirmPasswordTextField.isHidden = true
            confirmPasswordTextField.isEnabled = false
            
            
        } else {
            shouldCreateAccount = true
            
            // we need to create an account! and all that jazz!
            confirmButton.title = "Create Account"
            instructionLabel.stringValue = "Please create an account"
            
            confirmPasswordTextField.delegate = self
            
        }
    }
    
    override func viewDidAppear() {
        view.window?.isMovableByWindowBackground = true
    }

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    // MARK: Actions

    @IBAction func userDidPressEnter(_ sender: Any) {
        
        let email = emailTextField.stringValue
        let loginPassword = passwordTextField.stringValue
        
        if shouldCreateAccount {
            
            let confirmPassword = confirmPasswordTextField.stringValue
            
            if loginPassword != confirmPassword {
                
                let alert = NSAlert()
                alert.messageText = "Passwords do not match"
                alert.informativeText = "Please re-enter your login password"
                
                alert.beginSheetModal(for: self.view.window!) { response in
                    // reset the text for the password text fields!
                    self.passwordTextField.stringValue = ""
                    self.confirmPasswordTextField.stringValue = ""
                }
                
            } else {
                HLCore.Web.createUser(email: email) { result, userID, masterKey in
                    switch result {
                    case .success:
                        
                        SavedUserData.saveUserData(userID: userID, loginPassword: loginPassword, plaintextMasterKey: masterKey)
                        
                        DispatchQueue.main.async {
                            let alert = NSAlert()
                            alert.messageText = "Account Created"
                            alert.informativeText = "Your account has been created and your master key and ID have been saved."
                            alert.beginSheetModal(for: self.view.window!) { response in
                                
                            }
                        }
                        
                        
                        
                    case .emailTaken:
                        
                        DispatchQueue.main.async {
                            let alert = NSAlert()
                            alert.messageText = "Email in Use"
                            alert.informativeText = "The email you've entered is already in use. Please either negotiate with the other user, or use a different email."
                            alert.beginSheetModal(for: self.view.window!) { response in
                                
                            }
                        }
                        
                        
                        
                    case .connectionError:
                        
                        DispatchQueue.main.async {
                            let alert = NSAlert()
                            alert.messageText = "Server Error"
                            alert.informativeText = "A connection error occurred. Please try again."
                            alert.beginSheetModal(for: self.view.window!) { response in
                                
                            }
                        }
                        
                        
                        
                    case .unknownError:
                        
                        DispatchQueue.main.async {
                            let alert = NSAlert()
                            alert.messageText = "Unknown Error"
                            alert.informativeText = "An unknown error occurred. Please check the logs."
                            alert.beginSheetModal(for: self.view.window!) { response in
                                
                            }
                        }
                        
                        
                        
                    }
                }
            }
        } else {
            
        }
    }
    
    // MARK: Text Field Delegate
    
}

