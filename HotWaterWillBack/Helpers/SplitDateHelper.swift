//
//  SplitDateHelper.swift
//  HotWaterWillBack
//
//  Created by Alexander Konovalov on 19.06.2021.
//

import Foundation

struct SplitDateHelper {
    let fullString: String
    
    var year: String {
        String(fullString[...fullString.index(fullString.startIndex, offsetBy: 3)])
    }
    
    var month: String {
        String(fullString[fullString.index(fullString.startIndex, offsetBy: 5)...fullString.index(fullString.startIndex, offsetBy: 6)])
    }
    
    var day: String {
        String(fullString[fullString.index(fullString.startIndex, offsetBy: 8)...fullString.index(fullString.startIndex, offsetBy: 9)])
    }
    
    var hour: String {
        String(fullString[fullString.index(fullString.startIndex, offsetBy: 11)...fullString.index(fullString.startIndex, offsetBy: 12)])
    }
    
    var minutes: String {
        String(fullString[fullString.index(fullString.startIndex, offsetBy: 14)...fullString.index(fullString.startIndex, offsetBy: 15)])
    }
}
