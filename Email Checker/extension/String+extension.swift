//
//  String+extension.swift
//  Email Checker
//
//  Created by user on 26.07.2020.
//  Copyright © 2020 user. All rights reserved.
//

import Foundation


extension String {

    func toC() -> UnsafeMutablePointer<Int8> {
        let cs = (self as NSString).utf8String
        let cstr = UnsafeMutablePointer<Int8>(mutating: cs)!

        return cstr
    }

}
