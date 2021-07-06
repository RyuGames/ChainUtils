//
//  Utils.swift
//  ChainUtils
//
//  Created by Wyatt Mufson on 2/15/19.
//  Copyright © 2021 Ryu Games. All rights reserved.
//

import Foundation
import Neoutils

public extension Data {
    var bytesToHex: String {
        return NeoutilsBytesToHex(self)
    }
}

public extension String {
    var hexToBytes: Data? {
        return NeoutilsHexTobytes(self)
    }

    var isValidAddress: Bool {
        return NeoutilsValidateNEOAddress(self)
    }
}
