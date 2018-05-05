//
//  String+NumberFormat.swift
//  TiagoDias
//
//  Created by Tiago Novaes Dias on 05/05/18.
//  Copyright © 2018 Tiago Novaes Dias. All rights reserved.
//

import Foundation

extension String {
    struct NumFormatter {
        static let instance = NumberFormatter()
    }
    
    var doubleValue: Double? {
        return NumFormatter.instance.number(from: self)?.doubleValue
    }
}
