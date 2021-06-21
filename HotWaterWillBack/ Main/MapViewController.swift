//
//  ViewController.swift
//  HotWaterWillBack
//
//  Created by Alexander Konovalov on 16.06.2021.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    private var viewModel: MapViewModelProtocol! {
        didSet {
//            viewModel.fetchCourses {
//                self.tableView.reloadData()
//            }
        }
    }
    
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
        
        // необходимо дать время для определения местоположения
        sleep(1)
        mapView.delegate = self
        viewModel = MapViewModel()
        
        checkLocationServices()
        loadSavedData()
        
        startIntroduction()
        
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
    
    private func loadSavedData() {
        guard let address = UserSettings.currentAddress,
              let begin = UserSettings.beginDate,
              let end = UserSettings.endDate,
              let couch = UserSettings.couchHidden
        else { return }
        currentAddress.text = address
        beginDate.text = begin
        endDate.text = end
        couchHidden = couch
    }
    
    @IBAction func changeAddressButton(_ sender: UIButton) {
        
        // отключить 2ю подсказку
        DispatchQueue.main.async() {
            self.secondCouchLabel.isHidden = true
            self.triangleSecond.isHidden = true
            self.couchHidden = true
        }
        
        NetworkManager.fetchData(url: addressOnMap.text!) { outageBegin, outageEnd in
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
                    
                    self.beginDate.text = "\(dayBegin).\(monthBegin).\(yearBegin) \(hourBegin):\(minutesBegin)"
                    self.endDate.text = "\(dayEnd).\(monthEnd).\(yearEnd) \(hourEnd):\(minutesEnd)"
                } else {
                    self.beginDate.text = ""
                    self.endDate.text = ""
                }
                
                self.saveData()
            }
        }
    }
    
    private func saveData() {
        guard let address = addressOnMap.text,
              let beginDate = beginDate.text,
              let endDate = endDate.text
        else { return }
        UserSettings.currentAddress = address
        UserSettings.beginDate = beginDate
        UserSettings.endDate = endDate
        UserSettings.couchHidden = couchHidden
        currentAddress.text = address
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
    
    private func showAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        
        // точность определения
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:  // разрешено определение геолокации в момент использования приложения
            //            mapView.showsUserLocation = true
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
            mapView.showsUserLocation = true
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
    
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
}

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
            //            print("locality: \(placemark?.locality) subLocality: \(placemark?.subLocality)")
            
            DispatchQueue.main.async {
                if streetName != nil && buildNumber != nil {
                    self.addressOnMap.text = "\(streetName!), \(buildNumber!)"
                }
            }
        }
    }
}
