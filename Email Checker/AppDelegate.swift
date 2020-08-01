//
//  AppDelegate.swift
//  Email Checker
//
//  Created by user on 30.06.2020.
//  Copyright © 2020 user. All rights reserved.
//

import Cocoa


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    let popover = NSPopover()
    private var checkTimer: DispatchSourceTimer?
    private var checkPeriod: Double = 0
    private var unreadEmails = [String]()


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let button = statusItem.button {
            button.image = NSImage(named: NSImage.Name("StatusBarButtonImage"))
            button.action = #selector(togglePopover(_:))
        }

        popover.contentViewController = EmailCheckerViewController.freshController()

        let queue = DispatchQueue.global(qos: .utility)
        queue.async{
            Setup()

            if IsSetup() == 0 {
                self.createTimer()
            } else {
                let t = DispatchSource.makeTimerSource()
                t.schedule(deadline: .now(), repeating: 1)
                t.setEventHandler(handler: { [weak self] in
                    if IsSetup() == 0 {
                        self?.createTimer()
                        t.cancel()
                    }
                })
                t.resume()
            }
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        print("terminate")
    }


    func constructMenu() {
      let menu = NSMenu()
//      menu.addItem(NSMenuItem(title: "Print Quote", action: #selector(AppDelegate.printQuote(_:)), keyEquivalent: "P"))
      menu.addItem(NSMenuItem.separator())
      menu.addItem(NSMenuItem(title: "Quit Quotes", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

      statusItem.menu = menu
    }

    @objc func togglePopover(_ sender: Any?) {
        if popover.isShown {
            closePopover(sender: sender)
        } else {
            showPopover(sender: sender)
        }
    }

    func showPopover(sender: Any?) {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
    }

    func closePopover(sender: Any?) {
      popover.performClose(sender)
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
            self?.update()
        })
        checkTimer?.resume()
    }

    private func update() {
        print("update", Date())
        let decoder = JSONDecoder()
        let config = try? decoder.decode(Config.self, from: String(cString: GetConfig()).data(using: .utf8) ?? Data())
        let cfgCheckPeriod = Double(config?.check_period ?? 0)

        if let newEmails = try? decoder.decode([String].self, from: String(cString: GetNewEmails()).data(using: .utf8) ?? Data()) {
            var cnt = 0

            for mail in newEmails {
                if !unreadEmails.contains(mail) {
                    cnt += 1
                }
            }
            if cnt != 0 {
                let notification = NSUserNotification()
                notification.title = "You have \(cnt) unread email(s)"
                notification.deliveryDate = Date(timeIntervalSinceNow: 1)

                NSUserNotificationCenter.default.scheduleNotification(notification)
            }

            unreadEmails = newEmails
        }
        if checkPeriod != cfgCheckPeriod {
            checkPeriod = cfgCheckPeriod
            checkTimer?.cancel()
            createTimer()
        }
    }

}

