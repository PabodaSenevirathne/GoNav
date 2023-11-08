//
//  ViewController.swift
//  GoNav
//
//  Created by user234693 on 11/6/23.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController
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
        
        let sourceLocation = CLLocationCoordinate2D(latitude: 28.704060, longitude: 77.102493)
        let destinationLocation = CLLocationCoordinate2D(latitude: 28.459497, longitude: 77.026634)
        
        createPath(sourceLocation: sourceLocation, destinationLocation: destinationLocation)
        
        self.mapView.delegate = self
        
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

    
    

