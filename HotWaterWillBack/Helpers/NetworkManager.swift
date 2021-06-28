//
//  NetworkManager.swift
//  HotWaterWillBack
//
//  Created by Alexander Konovalov on 16.06.2021.
//

import Foundation

class NetworkManager {
    let shared = NetworkManager()
    private init() {}
    
    static func fetchData(url partOfURL: String, closure: @escaping (_ outageBegin: String, _ outageEnd: String) -> Void) {
        
        let mainURL = "https://www.mos.ru/aisearch/hwsuggest/api/v1/suggest/?q="
        let lastPartURL = "&house_only=1"
        let fullURL = (mainURL+partOfURL+lastPartURL)
        let fullURLEncoded = fullURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        print(fullURL)
        
        guard let url = URL(string: fullURLEncoded!) else { return }
        let session = URLSession.shared
        session.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            
            do {
                let decoder = JSONDecoder()
                let stateOfWater = try decoder.decode(StateOfWater.self, from: data)
                
                if stateOfWater.suggests.count > 0 {
                    closure(stateOfWater.suggests[0].OutageBegin, stateOfWater.suggests[0].OutageEnd)
                } else
                {
                    closure("", "")
                }
            } catch {
                print(error.localizedDescription)
            }
        }.resume()
    }
}
