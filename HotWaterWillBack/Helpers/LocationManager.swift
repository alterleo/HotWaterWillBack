//
//  LocationManager.swift
//  HotWaterWillBack
//
//  Created by Alexander Konovalov on 16.06.2021.
//

import Foundation
import CoreLocation

class LocationManager {
    let shared = LocationManager()
    private init() {}
    
    static func fetchLocationData(latitude pdblLatitude: Double, longitude pdblLongitude: Double) {
        var center = CLLocationCoordinate2D()
        let lat = Double("\(pdblLatitude)")!
        let lon = Double("\(pdblLongitude)")!
        let ceo = CLGeocoder()
        center.latitude = lat
        center.longitude = lon
        
        let loc = CLLocation(latitude:center.latitude, longitude: center.longitude)
        
        ceo.reverseGeocodeLocation(loc) { (placemarks, error) in
            if (error != nil)
            {
                print("reverse geodcode fail: \(error!.localizedDescription)")
            }
            
            var addressString = "г Москва, "
            let pm = placemarks! as [CLPlacemark]
            
            if pm.count > 0 {
                let pm = placemarks![0]
                print(pm.thoroughfare!)
                print(pm.subThoroughfare!)
                
                if pm.thoroughfare != nil {
                    addressString = addressString + pm.thoroughfare! + ", "
                }
                if pm.subThoroughfare != nil {
                    addressString = addressString + pm.subThoroughfare!
                }
                
//                let mainURL = "https://www.mos.ru/aisearch/hwsuggest/api/v1/suggest/?q="
//                let lastPartURL = "&house_only=1"
//                let fullURL = (mainURL+addressString+lastPartURL)
//                let fullURLEncoded = fullURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                
//                NetworkManager.fetchData(url: fullURLEncoded)
            }
        }
    }
}
