//
//  MailListViewController.swift
//  Email Checker
//
//  Created by user on 26.07.2020.
//  Copyright © 2020 user. All rights reserved.
//

import Cocoa

class MailListViewController: NSViewController {

    @IBOutlet var textView: NSTextView!


    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear() {
        super.viewWillAppear()

        textView.string = String(cString: GetUnreadList())
    }
    
    @IBAction func openAppAction(_ sender: Any) {
        guard
            let config = try? JSONDecoder().decode(Config.self, from: String(cString: GetConfig()).data(using: .utf8) ?? Data()),
            let mail = config.boxes.first?.login
        else {
            return
        }
        if let url = URL(string: "mailto:\(mail)") {
            NSWorkspace.shared.open(url)
        }
    }
}
