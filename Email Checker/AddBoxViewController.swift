//
//  AddBoxViewController.swift
//  Email Checker
//
//  Created by user on 25.07.2020.
//  Copyright © 2020 user. All rights reserved.
//

import Cocoa


class AddBoxViewController: NSViewController {

    @IBOutlet weak var adressField: NSTextField!
    @IBOutlet weak var passwordField: NSSecureTextField!
    @IBOutlet weak var hostField: NSTextField!
    @IBOutlet weak var portFiel: NSTextField!

    var callback: ((_ box: MailBox) -> Void?)? = nil


    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func addAction(_ sender: Any) {
        // TODO: validation fields
        // TODO: check email already exist
        let mailBox = MailBox(
            host: hostField.stringValue,
            port: portFiel.stringValue,
            login: adressField.stringValue,
            password: passwordField.stringValue
        )
        let configJson = String(cString: GetConfig())
        guard var settings = try? JSONDecoder().decode(Config.self, from: configJson.data(using: .utf8) ?? Data()) else {
            // TODO: show alert
            return
        }

        settings.boxes.append(mailBox)
        SetConfig(settings.cString)

        if callback != nil {
            callback!(mailBox)
        }

        self.dismiss(sender)
    }
    
    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(sender)
    }

    private func allowSave() -> Bool {
        return !adressField.stringValue.isEmpty
            && !passwordField.stringValue.isEmpty
            && !hostField.stringValue.isEmpty
            && !portFiel.stringValue.isEmpty
    }
}
