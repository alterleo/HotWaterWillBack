//
//  ViewController.swift
//  HotWaterWillBack
//
//  Created by Alexander Konovalov on 16.06.2021.
//

import UIKit
import MapKit
import AVFoundation

class MapViewController: UIViewController {
    
    private var viewModel: MapViewModelProtocol! {
        didSet {
            viewModel.loadSavedData {
                self.refreshData()
            }
        }
    }
    
    var player: AVAudioPlayer?
    
    var warningAboutWrongCity = false
    let regionInMeters = 500.00
    let locationManager = CLLocationManager()
    var couchHidden = false
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var currentAddress: UITextField!
    @IBOutlet weak var addressOnMap: UITextField!
    @IBOutlet weak var beginDate: UITextField!
    @IBOutlet weak var endDate: UITextField!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var firstView: UIView!
    
    
    @IBOutlet weak var triangleFirst: UIImageView!
    @IBOutlet weak var firstCouchLabel: UILabel!
    @IBOutlet weak var triangleSecond: UIImageView!
    @IBOutlet weak var secondCouchLabel: LabelWithInsets!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startPlayingMP3()
        
        // необходимо дать время для определения местоположения
        sleep(1)
        mapView.delegate = self
        
        checkLocationServices()
        viewModel = MapViewModel()
        
        startIntroduction()
        
    }
    
    func startPlayingMP3() {
        let urlString = Bundle.main.path(forResource: "startingSound.mp3", ofType: nil)
        
        do {
            try AVAudioSession.sharedInstance().setMode(.default)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
            
            guard let urlString = urlString else { return }
            
            player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: urlString))
            guard let player = player else { return }
            
//            player.delegate = self
//            player.numberOfLoops = -1
//            player.prepareToPlay()
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    // Начальные подсказки
    private func startIntroduction() {
        if couchHidden {
            self.firstCouchLabel.isHidden = true
            self.triangleFirst.isHidden = true
        }
        self.secondCouchLabel.isHidden = true
        self.triangleSecond.isHidden = true
    }
    
    // MARK: IBActions
    
    @IBAction func changeAddressButton(_ sender: UIButton) {
        
        // отключить 2ю подсказку
        DispatchQueue.main.async() {
            self.secondCouchLabel.isHidden = true
            self.triangleSecond.isHidden = true
            self.couchHidden = true
        }
        
        viewModel.fetchDataFromNet(url: addressOnMap.text!) {
            self.refreshData()
        }
    }
    
    // центрирование позиции по локализации пользователя на карте
    @IBAction func centerViewInUserLocation() {
        // отключить 1ю подсказку и включить 2ю
        if !couchHidden {
            DispatchQueue.main.async() {
                self.firstCouchLabel.isHidden = true
                self.triangleFirst.isHidden = true
                self.secondCouchLabel.isHidden = false
                self.triangleSecond.isHidden = false
            }
        }
        
        showUserLocation()
    }
    
    //
    func refreshData() {
        self.currentAddress.text = self.viewModel.currentAddress
        self.addressOnMap.text = self.viewModel.addressOnMap
        self.beginDate.text = self.viewModel.beginDate
        self.endDate.text = self.viewModel.endDate
        self.couchHidden = self.viewModel.couchHidden!
    }
    
    // MARK: Location operations
    
    private func showUserLocation() {
        
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: regionInMeters,
                                            longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    private func checkLocationServices() {
        
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(
                    title: "Location Services are Disabled",
                    message: "To enable it go: Settings -> Privacy -> Location Services and turn On"
                )
            }
        }
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        
        // точность определения
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:  // разрешено определение геолокации в момент использования приложения
            showUserLocation()
            break
        case .denied:               // запрет или отключена геолокация
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(
                    title: "Your Location is not Available",
                    message: "To give permission Go to: Setting -> MyPlaces -> Location"
                )
            }
            break
        case .notDetermined:        // пользователь еще не определил разрешить или нет геолокацию
            // запрашиваем разрешение
            // а пояснение прописано в файле .plist
            // в ветке Information Property List добавить Privacy - Location When In Use Usage Description
            // и необходимый текст с пояснением для чего
            locationManager.requestWhenInUseAuthorization()
        case .restricted:           // приложение не авторизовано для геолокации
            break
        case .authorizedAlways:     // приложению разрешена геолокация постоянно
            showUserLocation()
            break
        @unknown default:
            print("New case in authorization of location is available")
        }
    }
    
    private func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    // MARK: Alert
    
    private func showAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
}

// MARK: CLLocationManagerDelegate

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
}

// MARK: MKMapViewDelegate

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        let center = getCenterLocation(for: mapView)
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(center) { (placemarks, error) in
            
            if let error = error {
                print(error)
                return
            }
            
            guard let placemarks = placemarks else { return }
            
            let placemark = placemarks.first
            let streetName = placemark?.thoroughfare
            let buildNumber = placemark?.subThoroughfare
            
            if !self.warningAboutWrongCity && placemark?.locality != "Москва" {
                self.warningAboutWrongCity = true
                DispatchQueue.main.async() {
                    self.showAlert(
                        title: "Не Москва?",
                        message: "Программа получает данные только по г.Москва"
                    )
                }
            }
            
            DispatchQueue.main.async {
                if streetName != nil && buildNumber != nil {
                    let address = "\(streetName!), \(buildNumber!)"
                    self.addressOnMap.text = address
                    self.viewModel.setNewAddress(address: address)
                }
            }
        }
    }
}

extension MapViewController: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.player = nil
    }
}
