//
//  ViewController.swift
//  GoNav
//
//  Created by user234693 on 11/6/23.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController,CLLocationManagerDelegate, MKMapViewDelegate
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
    var totalDistance: CLLocationDistance = 0
    var MaxSpeed: CLLocationSpeed = 0
    var MaxAcceleration: Double = 0
    var previousSpeed: CLLocationSpeed = 0
    var previousLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
    }

    
    @IBAction func stopTrip(_ sender: UIButton) {
        tripStarted = false
        startTime = nil
    }
    
    @IBAction func startTrip(_ sender: UIButton) {
        if !tripStarted{
            tripStarted = true
            startTime = Date()
            totalDistance = 0
            MaxSpeed = 0
            MaxAcceleration = 0
            previousSpeed = 0
            previousLocation = nil
        }
        
        
        func manageLocation(_ manager:CLLocationManager, didUpdateLocations locations: [CLLocation]){
            
            guard let location = locations.last else {return}
            
            if tripStarted{
                
                
                if let previousLocation = previousLocation, let startTime = startTime {
                    
                    let timeElapsed = location.timestamp.timeIntervalSince(startTime)
                        let distance = location.distance(from: previousLocation)
                        
                        let speed = location.speed
                        totalDistance += distance

                        if speed > MaxSpeed{
                            MaxSpeed = speed
                        }
                    }
                }
            
                
        }
        
        
        
        
    }
    
    }

