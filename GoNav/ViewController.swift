//
//  ViewController.swift
//  GoNav
//
//  Created by user234693 on 11/6/23.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController,CLLocationManagerDelegate
{
    
    
    
    @IBOutlet weak var startButton: UIButton!
    
    
    @IBOutlet weak var stopButton: UIButton!
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var currentSpeed: UILabel!
    
    @IBOutlet weak var maxSpeed: UILabel!
    
    @IBOutlet weak var averageSpeed: UILabel!
    
    @IBOutlet weak var distance: UILabel!
    
    @IBOutlet weak var maxAcceleration: UILabel!
    
    @IBOutlet weak var topBar: UIView!
    
    @IBOutlet weak var bottomBar: UIView!
    
    var locationManager = CLLocationManager()
    var tripStarted = false
    var startTime: Date?
    var totalDistance: CLLocationDistance = 0.0
    var MaxSpeed: CLLocationSpeed = 0.0
    var previousLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let sourceLocation = CLLocationCoordinate2D(latitude: 28.704060, longitude: 77.102493)
        let destinationLocation = CLLocationCoordinate2D(latitude: 28.459497, longitude: 77.026634)
        
        createPath(sourceLocation: sourceLocation, destinationLocation: destinationLocation)
        
        self.mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.showsBackgroundLocationIndicator = true
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .automotiveNavigation
        locationManager.startUpdatingLocation()
        locationManager.pausesLocationUpdatesAutomatically = false    }
    
    
    
    @IBAction func startTrip(_ sender: UIButton) {
        // Start the trip
               tripStarted = true
               startButton.isEnabled = false
               stopButton.isEnabled = true
               startTime = Date()
               locationManager.startUpdatingLocation()
    }
    
    
    @IBAction func stopTrip(_ sender: UIButton) {
        // End the trip
               tripStarted = false
               locationManager.stopUpdatingLocation()
               startButton.isEnabled = true
               stopButton.isEnabled = false
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            if let location = locations.last {
                let speed = location.speed * 3.6 // Convert m/s to km/h
                currentSpeed.text = String(format: "%.1f km/h", speed)
                
                if speed > MaxSpeed {
                    MaxSpeed = speed
                    maxSpeed.text = String(format: "Max Speed: %.1f km/h", MaxSpeed)
                }
                
                if let prevLocation = previousLocation {
                    let Distance = location.distance(from: prevLocation)
                    totalDistance += Distance
                    distance.text = String(format: "Distance: %.2f km", totalDistance / 1000)
                    
                    //let timeElapsed = Date().timeIntervalSince(startTime!)
                    //let AverageSpeed = (totalDistance / 1000) / (timeElapsed / 3600)
                    //averageSpeed.text = String(format: "Avg Speed: %.1f km/h", AverageSpeed)
                    
                    if let startTime = startTime {
                           let timeElapsed = Date().timeIntervalSince(startTime)
                           
                           // Ensure timeElapsed is greater than zero to avoid division by zero
                           if timeElapsed > 0 {
                               let AverageSpeed = (totalDistance / 1000) / (timeElapsed / 3600)
                               
                               // Update the average speed label
                               averageSpeed.text = String(format: "Avg Speed: %.1f km/h", AverageSpeed)
                           }
                       }
                    let acceleration = abs(speed - prevLocation.speed) / Double(location.timestamp.timeIntervalSince(prevLocation.timestamp))
                    maxAcceleration.text = String(format: "Max Accel: %.2f m/s^2", acceleration)
                    
                    if speed > 115.0 {
                        topBar.backgroundColor = UIColor.red
                    } else {
                        topBar.backgroundColor = UIColor.green
                    }
                    
                    if tripStarted {
                        // Update the map and zoom to the current location
                        mapView.setCenter(location.coordinate, animated: true)
                        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
                        mapView.setRegion(region, animated: true)
                        
                        // Add the user's location as an annotation on the map
                                    let userAnnotation = MKPointAnnotation()
                                    userAnnotation.coordinate = location.coordinate
                                    mapView.addAnnotation(userAnnotation)

                                  
                        
                    }
                }
                
                previousLocation = location
            }
        }
    
    
    func createPath(sourceLocation : CLLocationCoordinate2D, destinationLocation : CLLocationCoordinate2D) {
        let sourcePlaceMark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        let destinationPlaceMark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
        
        
        let sourceMapItem = MKMapItem(placemark: sourcePlaceMark)
        let destinationItem = MKMapItem(placemark: destinationPlaceMark)
        
        
        let sourceAnotation = MKPointAnnotation()
        sourceAnotation.title = "Delhi"
        sourceAnotation.subtitle = "The Capital of INIDA"
        if let location = sourcePlaceMark.location {
            sourceAnotation.coordinate = location.coordinate
        }
        
        let destinationAnotation = MKPointAnnotation()
        destinationAnotation.title = "Gurugram"
        destinationAnotation.subtitle = "The HUB of IT Industries"
        if let location = destinationPlaceMark.location {
            destinationAnotation.coordinate = location.coordinate
        }
        
        self.mapView.showAnnotations([sourceAnotation, destinationAnotation], animated: true)
        
        
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationItem
        directionRequest.transportType = .automobile
        
        let direction = MKDirections(request: directionRequest)
        
        
        direction.calculate { (response, error) in
            guard let response = response else {
                if let error = error {
                    print("ERROR FOUND : \(error.localizedDescription)")
                }
                return
            }
            
            let route = response.routes[0]
            self.mapView.addOverlay(route.polyline, level: MKOverlayLevel.aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
            
        }
    }
    
    
}
    
    
    extension ViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let rendere = MKPolylineRenderer(overlay: overlay)
        rendere.lineWidth = 5
        rendere.strokeColor = .systemBlue
        
        return rendere
    }
        
        
    }

    
    

