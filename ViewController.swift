//
//  ViewController.swift
//  MapKitTask
//
//  Created by apple on 13/04/23.
//

import UIKit
import MapKit

protocol HandleMapSearch: AnyObject {
    func dropPinZoomIn(placemark:MKPlacemark)
}

class ViewController: UIViewController {
    
    var selectedPin: MKPlacemark?
    var resultSearchController: UISearchController!
    
    private var locationManager: CLLocationManager!
    private var currentLocation: CLLocation?

    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCurrentLocation()
        self.setUpSearchBar()
    }

    func setUpSearchBar() {
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController.searchResultsUpdater = locationSearchTable
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = resultSearchController?.searchBar
        resultSearchController.hidesNavigationBarDuringPresentation = false
        resultSearchController.obscuresBackgroundDuringPresentation = true
        definesPresentationContext = true
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self
    }
    
    func setupCurrentLocation() {
        mapView.delegate = self
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

}

extension ViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: location.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: (error)")
    }

}

extension ViewController: HandleMapSearch {
    
    func dropPinZoomIn(placemark: MKPlacemark){
        // cache the pin
        selectedPin = placemark

        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)

        guard let city = placemark.locality, let urlString = API.locationForecast(city) else { return }

        weatherData(from: urlString) {
            DispatchQueue.main.async {
                self.addCustomAnnonation(placemark)
            }
        }
    }

    func addCustomAnnonation(_ placemark: MKPlacemark) {
        if API.key.value == "" {
            self.defaultAnnonation(placemark)
        } else {
            guard let lastWeather = currentWeather.last else {
                self.defaultAnnonation(placemark)
                return
            }

            let pointAnnotation = CustomPointAnnotation()
            pointAnnotation.coordinate = placemark.coordinate
            let temperature = String(format: "%.2f", lastWeather.main?.tempCelcius ?? 0)
            pointAnnotation.temperature = "Temperature Celcius: \(temperature)"
            if let currentWeather = lastWeather.weather?.last {
                pointAnnotation.weather = "Sky: \(currentWeather.main ?? "no info")"
            }
            pointAnnotation.windSpeed = "Wind Speed: \(lastWeather.wind?.speed ?? 0.0)"
            pointAnnotation.humidity = "Humidity: \(lastWeather.main?.humidity ?? 0)%"
            
            mapView.addAnnotation(pointAnnotation)

            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }

    func defaultAnnonation(_ placemark: MKPlacemark) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
                annotation.subtitle = "\(city) \(state)"
        }
        annotation.coordinate = placemark.coordinate
        mapView.addAnnotation(annotation)
        
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
}

extension ViewController : MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !(annotation is MKUserLocation) else { return nil }
        
        if annotation is CustomPointAnnotation {
            // handle other annotations
            let customAnnotationView =  CustomAnnotationView(annotation: annotation, reuseIdentifier: "CustomAnnotationView")
            let userImage: UIImage? = UIImage(named: "location")
            customAnnotationView.image = userImage
            return customAnnotationView
        }
        let pin = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: nil)
        pin.canShowCallout = true
        
        let button = UIButton(type: .custom)
        pin.rightCalloutAccessoryView = button
        
        if annotation.isEqual(mapView.userLocation) {
            return nil
        }
        return pin
    }
}
