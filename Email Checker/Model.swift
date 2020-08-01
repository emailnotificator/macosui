//
//  Model.swift
//  Email Checker
//
//  Created by user on 01.07.2020.
//  Copyright © 2020 user. All rights reserved.
//

import Foundation

struct Config: Decodable, Encodable {
    var check_period: Int
    var boxes = [MailBox]()

    var cString: UnsafeMutablePointer<Int8> {
        get {
            guard let json = try? String(data: JSONEncoder().encode(self), encoding: .utf8) else {
                // TODO: show alert
                return "{}".toC()
            }
            return json.toC()
        }
    }
}

struct MailBox: Decodable, Encodable {
    let host: String
    let port: String
    let login: String
    let password: String
}

struct Email: Decodable {
    let id: Int
    let subject: String
    let body: String
    let mail_box: String
    let from: String
}
