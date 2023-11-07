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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
    }


}

