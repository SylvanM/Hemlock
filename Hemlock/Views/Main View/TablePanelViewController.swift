//
//  TablePanelViewController.swift
//  Hemlock
//
//  Created by Sylvan Martin on 7/29/24.
//

import Cocoa

class TablePanelViewController: NSSplitViewController {
    
    // MARK: Properties
    
    var mainViewController: MainViewController {
        self.parent! as! MainViewController
    }
    
    @IBOutlet weak var sharesButton: NSButton!
    @IBOutlet weak var filesButton: NSButton!
    @IBOutlet weak var accountButton: NSButton!
    
    
    // MARK: View Controller

    override func viewDidLoad() {
        
    }
    
    // MARK: Actions
    
    @IBAction func sharesButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func filesButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func accountButtonPressed(_ sender: Any) {
        
    }
}
