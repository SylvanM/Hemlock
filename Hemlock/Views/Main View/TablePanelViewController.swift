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
        sharesButton.state = .on
    }
    
    // MARK: Actions
    
    @IBAction func sharesButtonPressed(_ sender: Any) {
        filesButton.state = .off
        accountButton.state = .off
        mainViewController.contentViewController.showSharesView()
    }
    
    @IBAction func filesButtonPressed(_ sender: Any) {
        sharesButton.state = .off
        accountButton.state = .off
        mainViewController.contentViewController.showFilesView()
    }
    
    @IBAction func accountButtonPressed(_ sender: Any) {
        sharesButton.state = .off
        filesButton.state = .off
        mainViewController.contentViewController.showAccountView()
    }
}
