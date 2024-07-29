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
                            alert.informativeText = "Your account has been created and the following master key has been generated. Write this down on paper somewhere secure, it will not be saved on your computer, and is not recoverable if forgotten."
                            
                            let masterKeyView = NSTextView(frame: NSRect(x: 0, y: 0, width: 600, height: 20))
                            
                            #warning("A fix should be made for this, since not all computers have SF Mono installed. Instead, the font should come with the app.")
                            
                            let style = NSMutableParagraphStyle()
                            style.alignment = .center
                            
                            let attributes : [NSAttributedString.Key: Any] = [
                                .font: NSFont(name: "SFMono-Regular", size: 13) as Any,
                                .foregroundColor: NSColor.textColor,
                                .paragraphStyle : style
                            ]
                            
                            var accessoryText = masterKey.hexString
                            let splittingCharacter = " "
                            
                            var insertionIndex = accessoryText.index(accessoryText.startIndex, offsetBy: 8)
                            
                            for _ in 0..<7 {
                                accessoryText.insert(contentsOf: splittingCharacter, at: insertionIndex)
                                insertionIndex = accessoryText.index(insertionIndex, offsetBy: 9)
                            }
                            
                            let accessoryAttributedText = NSAttributedString(string: accessoryText, attributes: attributes)
                            masterKeyView.textStorage!.setAttributedString(accessoryAttributedText)
                            masterKeyView.isEditable = false
                            masterKeyView.drawsBackground = false
                            masterKeyView.isSelectable = false
                            masterKeyView.alignCenter(nil)
                            alert.accessoryView = masterKeyView
                            
                            alert.beginSheetModal(for: self.view.window!) { response in
                                self.performSegue(withIdentifier: "showMainViewSegue", sender: self)
                                self.view.window?.windowController?.close()
                            }
                        }
                    case .emailTaken:
                        DispatchQueue.main.async {
                            let alert = NSAlert()
                            alert.messageText = "Email in Use"
                            alert.informativeText = "The email you've entered is already in use. Please either negotiate with the other user, or use a different email."
                            alert.beginSheetModal(for: self.view.window!)
                        }
                    case .connectionError:
                        DispatchQueue.main.async {
                            let alert = NSAlert()
                            alert.messageText = "Server Error"
                            alert.informativeText = "A connection error occurred. Please try again."
                            alert.beginSheetModal(for: self.view.window!)
                        }
                    case .unknownError:
                        DispatchQueue.main.async {
                            let alert = NSAlert()
                            alert.messageText = "Unknown Error"
                            alert.informativeText = "An unknown error occurred. Please check the logs."
                            alert.beginSheetModal(for: self.view.window!)
                        }
                    }
                }
            }
        } else {
            
        }
    }
    
    // MARK: Text Field Delegate
    
}

