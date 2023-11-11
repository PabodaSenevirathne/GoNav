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
    var maxSpeed: CLLocationSpeed = 0.0
    var maxAcceleration: Double = 0.0
    var previousLocation: CLLocation?
    var distanceExceedingSpeedLimit: CLLocationDistance = 0.0
    var speed: Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // source location
        let sourceLocation = CLLocationCoordinate2D(latitude: 43.47950197259528, longitude: -80.51852976108717)
        
        // destination location
        let destinationLocation = CLLocationCoordinate2D(latitude: 43.39456787588452, longitude: -80.40621851466166)
        
        // call the create path function
        createPath(sourceLocation: sourceLocation, destinationLocation: destinationLocation)
        
        self.mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.showsBackgroundLocationIndicator = true
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .automotiveNavigation
        locationManager.startUpdatingLocation()
        }
    
    // Start the trip
    @IBAction func startTrip(_ sender: UIButton) {
        print("Start Trip button clicked")
               tripStarted = true
               locationManager.startUpdatingLocation()
               startButton.isEnabled = false
               stopButton.isEnabled = true
               startTime = Date()
        
        
        //start location
            let sourceLocation = CLLocationCoordinate2D(latitude:43.47950197259528, longitude: -80.51852976108717)
            print("Start Location: \(sourceLocation)")
        // Update the color of the bottom bar to green
                bottomBar.backgroundColor = UIColor.green
        
    }
    
    // stop trip
    @IBAction func stopTrip(_ sender: UIButton) {
        // End the trip
               tripStarted = false
               locationManager.stopUpdatingLocation()
               startButton.isEnabled = true
               stopButton.isEnabled = false
        
        // destination location
            let destinationLocation = CLLocationCoordinate2D(latitude: 43.39456787588452, longitude: -80.40621851466166)
            print("Destination Location: \(destinationLocation)")
        
        // Update the color of the bottom bar to gray
                bottomBar.backgroundColor = UIColor.gray    }
        
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if tripStarted, let sourceLocation = locations.first {
            print("Received location update: \(sourceLocation.coordinate.latitude), \(sourceLocation.coordinate.longitude)")

           // calculate the speed
            let timeElapsed = sourceLocation.timestamp.timeIntervalSince(previousLocation?.timestamp ?? sourceLocation.timestamp)

                   // Calculate the distance between the current and previous location
                   let distance = sourceLocation.distance(from: previousLocation ?? sourceLocation)
            
                   // calculate the speed and convert to m/s to km/h
                   let speed = (distance / timeElapsed) * 3.6

                   if speed >= 0 {
                       currentSpeedLabel.text = String(format: "%.1f km/h", speed)
                       print("Current speed == \(speed)")
                   } else {
                       print("Invalid speed value")
                   }
               
               // calculate max speed
                if speed > maxSpeed {
                    maxSpeed = speed
                    maxSpeedLabel.text = String(format: "%.1f km/h", maxSpeed)
                    print("Max speed == \(maxSpeed)")                }
               
               // calculate the distance driver travel before exceeding the speed limit
               if speed > 115.0 {
                          
                   distanceExceedingSpeedLimit += sourceLocation.distance(from: previousLocation ?? sourceLocation)
                   
                   print("Distance Exceeding Speed Limit == \(distanceExceedingSpeedLimit)")
                   
               }
               
               //calculate the distance
                if let prevLocation = previousLocation {
                    let distance = sourceLocation.distance(from: prevLocation)
                    totalDistance += distance
                    distanceLabel.text = String(format: "%.2f km", totalDistance / 1000)
                    
                    if let startTime = startTime {
                           let timeElapsed = Date().timeIntervalSince(startTime)
                           
                           if timeElapsed > 0 {
                               let averageSpeed = (totalDistance / 1000) / (timeElapsed / 3600)
                               
                               // Update the average speed label
                               averageSpeedLabel.text = String(format: "%.1f km/h", averageSpeed)
                           }
                       }
                    
                // calculate max acceleration speed
                    let acceleration = abs(speed - prevLocation.speed) / Double(sourceLocation.timestamp.timeIntervalSince(prevLocation.timestamp))
                    //maxAccelerationLabel.text = String(format: "%.2f m/s^2", acceleration)
                    if acceleration > maxAcceleration {
                       maxAcceleration = acceleration
                       maxAccelerationLabel.text = String(format: "%.2f m/s^2", maxAcceleration)
                                            
                    }
                    
                    //change the clour of top bar accordingto the speed
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
    
    // create path between source location and the destination location
    func createPath(sourceLocation : CLLocationCoordinate2D, destinationLocation : CLLocationCoordinate2D) {
        let sourcePlaceMark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        let destinationPlaceMark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
        
        let sourceMapItem = MKMapItem(placemark: sourcePlaceMark)
        let destinationItem = MKMapItem(placemark: destinationPlaceMark)
        
        // add title
        let sourceAnotation = MKPointAnnotation()
        sourceAnotation.title = "Conestoga Waterloo Campus"
        if let location = sourcePlaceMark.location {
            sourceAnotation.coordinate = location.coordinate
        }
        
        // add title
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

    
    

