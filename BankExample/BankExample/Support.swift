//
//  Support.swift
//  BankExample
//
//  Created by Ilya Nikokoshev on 24/04/15.
//  Copyright (c) 2015 ilya n. All rights reserved.
//

import Foundation

func CurrentUnixTime() -> time_t {
    return time_t(NSDate().timeIntervalSince1970)
}