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
    private var deleteCallback: ((Int) -> Void)? = nil


    override func viewDidLoad() {
        super.viewDidLoad()

        mailTableView.delegate = self
        mailTableView.dataSource = self

        deleteCallback = { [weak self] (id: Int) in
//            let unreadsJson = String(cString: GetUnread())
//
//            if let data = try? JSONDecoder().decode([Email].self, from: unreadsJson.data(using: .utf8) ?? Data()) {
//                self?.unreads.append(contentsOf: data)
//            }

            for (idx, data) in self?.unreads.enumerated() ?? [Email]().enumerated() {
                if data.id == id {
                    self?.unreads.remove(at: idx)

                    DispatchQueue.main.async {
                        self?.mailTableView.reloadData()
                    }

                    break
                }
            }

        }
    }

    override func viewWillAppear() {
        super.viewWillAppear()

        let unreadsJson = String(cString: GetUnread())

        if let data = try? JSONDecoder().decode([Email].self, from: unreadsJson.data(using: .utf8) ?? Data()) {
            unreads.append(contentsOf: data)
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
