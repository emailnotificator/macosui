//
//  EmailCheckerViewController.swift
//  Email Checker
//
//  Created by user on 01.07.2020.
//  Copyright © 2020 user. All rights reserved.
//

import Cocoa


class EmailCheckerViewController: NSViewController {

    @IBOutlet weak var unreadCountField: NSTextField!
    @IBOutlet weak var mailListField: NSTextField!
    @IBOutlet weak var lastCheckField: NSTextField!
    @IBOutlet weak var unreadWait: NSProgressIndicator!
    @IBOutlet weak var lastCheckWait: NSProgressIndicator!
    @IBOutlet weak var mailListWait: NSProgressIndicator!

    private var checkTimer: DispatchSourceTimer?
    private var checkPeriod: Double = 0


    override func viewDidLoad() {
        super.viewDidLoad()

        unreadWait.startAnimation(nil)
        mailListWait.startAnimation(nil)
        lastCheckWait.startAnimation(nil)

        if IsSetup() == 0 {
            setData()
        } else {
            let timer = DispatchSource.makeTimerSource()
            timer.schedule(deadline: .now(), repeating: 1)
            timer.resume()
            timer.setEventHandler(handler: { [weak self] in
                if IsSetup() == 0 {
                    DispatchQueue.main.async {
                        self?.setData()
                    }

                    timer.suspend()
                }
            })
        }
    }

    override func viewWillAppear() {
        super.viewWillAppear()

        let unreadCount = GetUnreadCount()

        unreadCountField.stringValue = "\(unreadCount)"

        createTimer()
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()

        checkTimer?.cancel()
    }

    @IBAction func quitAction(_ sender: NSButtonCell) {
        Shutdown()
        NSApplication.shared.terminate(sender)
    }

    @IBAction func openMailAppAction(_ sender: Any) {
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

    private func createTimer() {
        let config = try? JSONDecoder().decode(Config.self, from: String(cString: GetConfig()).data(using: .utf8) ?? Data())

        checkPeriod = Double(config?.check_period ?? 0)
        var timerPeriod = checkPeriod

        if checkPeriod > 0 {
            timerPeriod = (checkPeriod / 2) * 60
        }

        checkTimer = DispatchSource.makeTimerSource()
        checkTimer?.schedule(deadline: .now(), repeating: timerPeriod)
        checkTimer?.setEventHandler(handler: { [weak self] in
            DispatchQueue.main.async {
                self?.update()
            }
        })
        checkTimer?.resume()
    }

    private  func setData() {
        let decoder = JSONDecoder()
        let unreadCount = GetUnreadCount()
        let lastUnreadJson = String(cString: GetUnread())
        let lastUnread = try? decoder.decode([Email].self, from: lastUnreadJson.data(using: .utf8) ?? Data())
        let lastUpdate = String(cString: GetLastUpdate())

        unreadWait.stopAnimation(nil)
        mailListWait.stopAnimation(nil)
        lastCheckWait.stopAnimation(nil)

        var boxCount = [String: Int]()
        var boxes = ""

        for email in lastUnread ?? [Email]() {
            if boxCount[email.mail_box] == nil {
                boxCount[email.mail_box] = 0
            }
            boxCount[email.mail_box]! += 1
        }
        for (key, value) in boxCount {
            boxes += "\(key) - \(value)" + "\n"
        }

        mailListField.stringValue = boxes
        lastCheckField.stringValue = lastUpdate
        unreadCountField.stringValue = "\(unreadCount)"
    }

    private func update() {
        print("check")
        let decoder = JSONDecoder()

        let unreadCount = GetUnreadCount()
        let lastUnreadJson = String(cString: GetUnread())
        let lastUnread = try? decoder.decode([Email].self, from: lastUnreadJson.data(using: .utf8) ?? Data())
        let lastUpdate = String(cString: GetLastUpdate())
        var boxCount = [String: Int]()
        var boxes = ""

        for email in lastUnread ?? [Email]() {
            if boxCount[email.mail_box] == nil {
                boxCount[email.mail_box] = 0
            }
            boxCount[email.mail_box]! += 1
        }
        for (key, value) in boxCount {
            boxes += "\(key) - \(value)" + "\n"
        }

        mailListField.stringValue = boxes
        lastCheckField.stringValue = lastUpdate
        unreadCountField.stringValue = "\(unreadCount)"
    }
}

extension EmailCheckerViewController {
    // MARK: Storyboard instantiation
    static func freshController() -> EmailCheckerViewController {
        //1.
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        //2.
        let identifier = NSStoryboard.SceneIdentifier("EmailCheckerViewController")
        //3.
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? EmailCheckerViewController else {
          fatalError("Why cant i find EmailCheckerViewController? - Check Main.storyboard")
        }
        return viewcontroller
    }
}
