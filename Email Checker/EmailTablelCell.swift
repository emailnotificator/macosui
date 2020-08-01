//
//  EmailTablelCell.swift
//  Email Checker
//
//  Created by user on 30.07.2020.
//  Copyright © 2020 user. All rights reserved.
//

import Cocoa

class EmailTablelCell: NSTableCellView {

    @IBOutlet weak var emailLabel: NSTextField!
    @IBOutlet weak var subjectLabel: NSTextField!
    @IBOutlet weak var deleteWaitIndicator: NSProgressIndicator!
    @IBOutlet weak var deleteButton: NSButton!

    var email: Email? = nil
    var deleteCallback: (() -> Void)? = nil


    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }

    func initCell() {
        emailLabel.stringValue = email?.mail_box ?? ""
        subjectLabel.stringValue = email?.subject ?? ""
    }
    
    @IBAction func deleteAction(_ sender: Any) {
        deleteButton.isHidden = true
        deleteWaitIndicator.startAnimation(sender)

        if let id = email?.id {
            DeleteEmail(emailLabel.stringValue.toC(), Int64(id))
            deleteCallback?()
        }

    }
}
