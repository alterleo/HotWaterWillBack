//
//  UserSettings.swift
//  HotWaterWillBack
//
//  Created by Alexander Konovalov on 19.06.2021.
//

import Foundation

class UserSettings {
    
    private enum SettingsKeys: String {
        case currentAddress
        case beginDate
        case endDate
        case couchHidden
    }
    
    static var currentAddress: String! {
        get {
            return UserDefaults.standard.string(forKey: SettingsKeys.currentAddress.rawValue)
        }
        set {
            if let newValue = newValue {
                UserDefaults.standard.set(newValue, forKey: SettingsKeys.currentAddress.rawValue)
            }
        }
    }
    
    static var beginDate: String! {
        get {
            return UserDefaults.standard.string(forKey: SettingsKeys.beginDate.rawValue)
        }
        set {
            if let newValue = newValue {
                UserDefaults.standard.set(newValue, forKey: SettingsKeys.beginDate.rawValue)
            }
        }
    }
    
    static var endDate: String! {
        get {
            return UserDefaults.standard.string(forKey: SettingsKeys.endDate.rawValue)
        }
        set {
            if let newValue = newValue {
                UserDefaults.standard.set(newValue, forKey: SettingsKeys.endDate.rawValue)
            }
        }
    }
    
    static var couchHidden: Bool! {
        get {
            return UserDefaults.standard.bool(forKey: SettingsKeys.couchHidden.rawValue)
        }
        set {
            if let newValue = newValue {
                UserDefaults.standard.set(newValue, forKey: SettingsKeys.couchHidden.rawValue)
            }
        }
    }
}
