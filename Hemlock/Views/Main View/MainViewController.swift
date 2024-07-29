//
//  MainViewController.swift
//  Hemlock
//
//  Created by Sylvan Martin on 7/29/24.
//

import Cocoa

class MainViewController: NSSplitViewController {
    
    // MARK: Properties
    
    public var tablePanelView: TablePanelViewController!
    public var contentViewController: ContentViewController!
    
    // MARK: View Controller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        tablePanelView = splitViewItems[0].viewController as? TablePanelViewController
        contentViewController = splitViewItems[1].viewController as? ContentViewController
        
        contentViewController.showSharesView()
    }
    
}
