//
//  SettingsViewControlller.swift
//  Email Checker
//
//  Created by user on 19.07.2020.
//  Copyright © 2020 user. All rights reserved.
//

import Cocoa


class SettingsViewControlller: NSViewController {

    @IBOutlet weak var checkPeriodField: NSTextField!
    @IBOutlet weak var mailTableView: NSTableView!

    private var settings: Config?


    override func viewDidLoad() {
        super.viewDidLoad()

        mailTableView.delegate = self
        mailTableView.dataSource = self

        let cfg = String(cString: GetConfig())
        settings = try? JSONDecoder().decode(Config.self, from: cfg.data(using: .utf8) ?? Data())
        mailTableView.reloadData()

        if let checkPeriod = settings?.check_period {
            checkPeriodField.stringValue = "\(String(describing: checkPeriod))"
        }
    }
    
    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(sender)
    }
    
    @IBAction func savaAction(_ sender: Any) {
        settings?.check_period = Int(checkPeriodField.intValue)

        guard let json = settings?.cString else {
            // TODO: show alert
            return
        }
        SetConfig(json)
        self.dismiss(sender)
    }

    @IBAction func segmentAction(_ sender: NSSegmentedControl) {
        if sender.selectedSegment == 0 {
            // add
            let sb = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
            if let vc: AddBoxViewController = sb.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("AddPopover")) as? AddBoxViewController {
                vc.callback = { box in
                    self.settings?.boxes.append(box)
                    self.mailTableView.reloadData()

                    return nil
                }
                present(vc, asPopoverRelativeTo: (sender.bounds), of: sender, preferredEdge: NSRectEdge.maxX, behavior: NSPopover.Behavior.transient)
            }
        }
        if sender.selectedSegment == 1 {
            // remove
            settings?.boxes.remove(at: mailTableView.selectedRow)
            mailTableView.reloadData()
        }
    }

}

extension SettingsViewControlller: NSTableViewDelegate {



}

extension SettingsViewControlller: NSTableViewDataSource {

    fileprivate enum CellIdentifiers {
      static let MailCell = "MailCellId"
      static let PasswordCell = "PasswordCellId"
      static let PortCell = "PortCellId"
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        return settings?.boxes.count ?? 0
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var text = ""
        var cellId = ""

        switch tableColumn {
        case mailTableView.tableColumns[0]:
            text = settings?.boxes[row].login ?? ""
            cellId = CellIdentifiers.MailCell
        case mailTableView.tableColumns[1]:
            text = settings?.boxes[row].password ?? ""
            cellId = CellIdentifiers.PasswordCell
        case mailTableView.tableColumns[2]:
            text = settings?.boxes[row].port ?? ""
            cellId = CellIdentifiers.PortCell
        default:
            return nil
        }

        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellId), owner: nil) as? NSTableCellView {
          cell.textField?.stringValue = text
          return cell
        }

        return nil
    }

}
