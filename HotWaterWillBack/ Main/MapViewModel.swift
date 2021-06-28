//
//  MapViewModel.swift
//  HotWaterWillBack
//
//  Created by Alexander Konovalov on 21.06.2021.
//

import Foundation

protocol MapViewModelProtocol: AnyObject {
    var addressOnMap: String? { get }
    var currentAddress: String? { get }
    var beginDate: String? { get }
    var endDate: String? { get }
    var couchHidden: Bool? { get }
    func loadSavedData(completion: @escaping() -> Void) -> Void
    func fetchDataFromNet(url: String, completion: @escaping() -> Void) -> Void
    func setNewAddress(address: String) -> Void
}

class MapViewModel: MapViewModelProtocol {
    
    private var mapModel = MapModel()
    var addressOnMap: String? {
        return mapModel.addressOnMap
    }
    var currentAddress: String? {
        return mapModel.currentAddress
    }
    var beginDate: String? {
        return mapModel.beginDate
    }
    var endDate: String? {
        return mapModel.endDate
    }
    var couchHidden: Bool? {
        return mapModel.couchHidden
    }
    
    func loadSavedData(completion: @escaping() -> Void) {
        guard let address = UserSettings.currentAddress,
              let begin = UserSettings.beginDate,
              let end = UserSettings.endDate,
              let couch = UserSettings.couchHidden
        else { return }
        mapModel.currentAddress = address
        mapModel.beginDate = begin
        mapModel.endDate = end
        mapModel.couchHidden = couch
        
        completion()
    }
    
    func fetchDataFromNet(url: String, completion: @escaping() -> Void) {
        mapModel.currentAddress = url
        
        NetworkManager.fetchData(url: url) { outageBegin, outageEnd in
            DispatchQueue.main.async {
                
                if outageBegin.count >= 12 && outageEnd.count >= 12 {
                    let splittedOutageBegin = SplitDateHelper(fullString: outageBegin)
                    let splittedOutageEnd = SplitDateHelper(fullString: outageEnd)
                    
                    let yearBegin = splittedOutageBegin.year
                    let monthBegin = splittedOutageBegin.month
                    let dayBegin = splittedOutageBegin.day
                    let hourBegin = splittedOutageBegin.hour
                    let minutesBegin = splittedOutageBegin.minutes
                    
                    let yearEnd = splittedOutageEnd.year
                    let monthEnd = splittedOutageEnd.month
                    let dayEnd = splittedOutageEnd.day
                    let hourEnd = splittedOutageEnd.hour
                    let minutesEnd = splittedOutageEnd.minutes
                    
                    self.mapModel.beginDate = "\(dayBegin).\(monthBegin).\(yearBegin) \(hourBegin):\(minutesBegin)"
                    self.mapModel.endDate = "\(dayEnd).\(monthEnd).\(yearEnd) \(hourEnd):\(minutesEnd)"
                } else {
                    self.mapModel.beginDate = ""
                    self.mapModel.endDate = ""
                }
                
                self.saveData()
            }
        }
        completion()
    }
    
    private func saveData() {
        guard let address = self.mapModel.addressOnMap,
              let beginDate = self.mapModel.beginDate,
              let endDate = self.mapModel.endDate
        else { return }
        UserSettings.currentAddress = address
        UserSettings.beginDate = beginDate
        UserSettings.endDate = endDate
        UserSettings.couchHidden = self.mapModel.couchHidden
        self.mapModel.currentAddress = address
    }
    
    func setNewAddress(address: String) {
        mapModel.addressOnMap = address
    }
}
