//
//  ContentViewController.swift
//  Hemlock
//
//  Created by Sylvan Martin on 7/29/24.
//

import Cocoa

class ContentViewController: NSViewController {
    
    // MARK: Properties
    
    var sharesVC: SharesViewController!
    var filesVC: FilesViewController!
    var accountVC: AccountViewController!
    
    // MARK: View Controller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sharesVC = (NSStoryboard.main!.instantiateController(withIdentifier: "sharesView") as! SharesViewController)
        filesVC = (NSStoryboard.main!.instantiateController(withIdentifier: "filesView") as! FilesViewController)
        accountVC = (NSStoryboard.main!.instantiateController(withIdentifier: "accountView") as! AccountViewController)
        
        let bounds = self.view.bounds
        
        for vc in [sharesVC, filesVC, accountVC] {
            
            addChild(vc!)
            view.addSubview(vc!.view)
//            vc!.view.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                vc!.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                vc!.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                vc!.view.topAnchor.constraint(equalTo: self.view.topAnchor),
                vc!.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])
            
            self.view.layoutSubtreeIfNeeded()
            
        }
        
        for vc in [sharesVC, filesVC, accountVC] {
            self.view.frame = NSRect(x: 0, y: 0, width: 700, height: 600)
            vc!.view.frame = view.bounds
        }
        
        showSharesView()
    }
    
    // MARK: Methods
    
    func showSharesView() {
        sharesVC.view.isHidden = false
        filesVC.view.isHidden = true
        accountVC.view.isHidden = true
    }
    
    func showFilesView() {
        sharesVC.view.isHidden = true
        filesVC.view.isHidden = false
        accountVC.view.isHidden = true
    }
    
    func showAccountView() {
        sharesVC.view.isHidden = true
        filesVC.view.isHidden = true
        accountVC.view.isHidden = false
    }
    
    
    
}
