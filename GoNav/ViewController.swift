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
    
    
    
    @IBOutlet weak var currentSpeedLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    
    
    @IBOutlet weak var maxSpeedLabel: UILabel!
    
    
    @IBOutlet weak var averageSpeedLabel: UILabel!
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    
    @IBOutlet weak var maxAccelerationLabel: UILabel!
    
    @IBOutlet weak var mapView: MKMapView!
    
   
    
    
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
        
        let sourceLocation = CLLocationCoordinate2D(latitude: 43.47950197259528, longitude: -80.51852976108717)
        let destinationLocation = CLLocationCoordinate2D(latitude: 43.39456787588452, longitude: -80.40621851466166)
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
        print("Start Trip button clicked")        // Start the trip
               tripStarted = true
               startButton.isEnabled = false
               stopButton.isEnabled = true
               startTime = Date()
        
        locationManager.startUpdatingLocation()
        // Log start location
            let sourceLocation = CLLocationCoordinate2D(latitude:43.47950197259528, longitude: -80.51852976108717)
            print("Start Location: \(sourceLocation)")
        
    }
    
    
    @IBAction func stopTrip(_ sender: UIButton) {
        // End the trip
               tripStarted = false
               locationManager.stopUpdatingLocation()
               startButton.isEnabled = true
               stopButton.isEnabled = false
        
        // Log destination location
            let destinationLocation = CLLocationCoordinate2D(latitude: 43.39456787588452, longitude: -80.40621851466166)
            print("Destination Location: \(destinationLocation)")
    }
        
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
           if tripStarted, let sourceLocation = locations.first {
                print("Received location update: \(sourceLocation.coordinate.latitude), \(sourceLocation.coordinate.longitude)")
            
               
                let speed = sourceLocation.speed * 3.6 // Convert m/s to km/h
                currentSpeedLabel.text = String(format: "%.1f km/h", speed)
                
                if speed > MaxSpeed {
                    MaxSpeed = speed
                    maxSpeedLabel.text = String(format: "%.1f km/h", MaxSpeed)
                }
                
                if let prevLocation = previousLocation {
                    let distance = sourceLocation.distance(from: prevLocation)
                    totalDistance += distance
                    distanceLabel.text = String(format: "%.2f km", totalDistance / 1000)
                    
                    //let timeElapsed = Date().timeIntervalSince(startTime!)
                    //let AverageSpeed = (totalDistance / 1000) / (timeElapsed / 3600)
                    //averageSpeed.text = String(format: "Avg Speed: %.1f km/h", AverageSpeed)
                    
                    if let startTime = startTime {
                           let timeElapsed = Date().timeIntervalSince(startTime)
                           
                           // Ensure timeElapsed is greater than zero to avoid division by zero
                           if timeElapsed > 0 {
                               let averageSpeed = (totalDistance / 1000) / (timeElapsed / 3600)
                               
                               // Update the average speed label
                               averageSpeedLabel.text = String(format: "%.1f km/h", averageSpeed)
                           }
                       }
                    let acceleration = abs(speed - prevLocation.speed) / Double(sourceLocation.timestamp.timeIntervalSince(prevLocation.timestamp))
                    maxAccelerationLabel.text = String(format: "%.2f m/s^2", acceleration)
                    
                    if speed > 115.0 {
                        topBar.backgroundColor = UIColor.red
                    } else {
                        topBar.backgroundColor = UIColor.green
                    }
                    
                    if tripStarted {
                        // Update the map and zoom to the current location
                        mapView.setCenter(sourceLocation.coordinate, animated: true)
                        let region = MKCoordinateRegion(center: sourceLocation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
                        mapView.setRegion(region, animated: true)
                        
                        // Add the user's location as an annotation on the map
                                    let userAnnotation = MKPointAnnotation()
                                    userAnnotation.coordinate = sourceLocation.coordinate
                                    mapView.addAnnotation(userAnnotation)

                                  
                        
                    }
                }
                
                previousLocation = sourceLocation
            }
        }
    
    
    func createPath(sourceLocation : CLLocationCoordinate2D, destinationLocation : CLLocationCoordinate2D) {
        let sourcePlaceMark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        let destinationPlaceMark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
        
        
        let sourceMapItem = MKMapItem(placemark: sourcePlaceMark)
        let destinationItem = MKMapItem(placemark: destinationPlaceMark)
        
        
        let sourceAnotation = MKPointAnnotation()
        sourceAnotation.title = "Conestoga Waterloo Campus"
        if let location = sourcePlaceMark.location {
            sourceAnotation.coordinate = location.coordinate
        }
        
        let destinationAnotation = MKPointAnnotation()
        destinationAnotation.title = "Conestoga Doon Campus"
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

    
    

