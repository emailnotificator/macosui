//
//  MailListViewController.swift
//  Email Checker
//
//  Created by user on 26.07.2020.
//  Copyright © 2020 user. All rights reserved.
//

import Cocoa

class MailListViewController: NSViewController {

    @IBOutlet weak var mailTableView: NSTableView!

    private var unreads = [Email]()
    private var deleteCallback: (() -> Void)? = nil


    override func viewDidLoad() {
        super.viewDidLoad()

        mailTableView.delegate = self
        mailTableView.dataSource = self

        deleteCallback = { [weak self] in
            let unreadsJson = String(cString: GetUnread())

            if let data = try? JSONDecoder().decode([String : [Email]].self, from: unreadsJson.data(using: .utf8) ?? Data()) {
                for (_, subjects) in data {
                    for subj in subjects {
                        self?.unreads.append(subj)
                    }
                }
            }

            self?.mailTableView.reloadData()
        }
    }

    override func viewWillAppear() {
        super.viewWillAppear()

        let unreadsJson = String(cString: GetUnread())

        if let data = try? JSONDecoder().decode([String : [Email]].self, from: unreadsJson.data(using: .utf8) ?? Data()) {
            for (_, subjects) in data {
                for subj in subjects {
                    unreads.append(subj)
                }
            }
        }

        mailTableView.reloadData()
    }

}

extension MailListViewController: NSTableViewDelegate {

}

extension MailListViewController: NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        return unreads.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard
            let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "mailCell"), owner: self) as? EmailTablelCell
        else {
            return nil
        }
        cell.email = unreads[row]
        cell.deleteCallback = deleteCallback
        cell.initCell()

        return cell
    }

}
