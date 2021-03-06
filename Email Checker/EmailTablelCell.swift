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
    @IBOutlet weak var buttonStackView: NSStackView!
    
    var email: Email? = nil
    var deleteCallback: ((Int) -> Void)? = nil


    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }

    func initCell() {
        emailLabel.stringValue = email?.mail_box ?? ""
        subjectLabel.stringValue = email?.subject ?? ""
    }
    
    @IBAction func deleteAction(_ sender: Any) {
        buttonStackView.isHidden = true
        deleteWaitIndicator.startAnimation(sender)

        guard let id = email?.id else {
            return
        }
        let login = emailLabel.stringValue

        DispatchQueue.global(qos: .utility).async { [weak self] in
            DeleteEmail(login.toC(), Int64(id))
            self?.deleteCallback?(id)
        }
    }

    @IBAction func seenAction(_ sender: Any) {
        buttonStackView.isHidden = true
        deleteWaitIndicator.startAnimation(sender)

        guard let id = email?.id else {
            return
        }
        let login = emailLabel.stringValue

        DispatchQueue.global(qos: .utility).async { [weak self] in
            SetSeen(login.toC(), Int64(id))
            self?.deleteCallback?(id)
        }
    }
}
