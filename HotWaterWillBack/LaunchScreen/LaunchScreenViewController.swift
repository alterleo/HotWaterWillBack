//
//  LaunchScreenViewController.swift
//  HotWaterWillBack
//
//  Created by Alexander Konovalov on 22.06.2021.
//

import UIKit
import AVFoundation

class LaunchScreenViewController: UIViewController {

    var player: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

         
        let urlString = Bundle.main.path(forResource: "startingSound", ofType: "mp3")
        
        do {
            try AVAudioSession.sharedInstance().setMode(.default)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
            
            guard let urlString = urlString else { return }
            
            player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: urlString))
            guard let player = player else { return }
            
            player.play()
            
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    

}
