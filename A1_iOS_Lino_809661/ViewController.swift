//
//  ViewController.swift
//  A1_iOS_Lino_809661
//
//  Created by user195794 on 5/16/21.
//

import UIKit
import MapKit


class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var CalculateBtn: UIButton!
    
    // location manager
    var locationManager = CLLocationManager()
    var locationArray = ["A","B","C"]
    var coordenateArray = [CLLocationCoordinate2D]()
    var markCounter = 1
    // destination variable
    var destination: CLLocationCoordinate2D!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        map.isZoomEnabled = false
        map.showsUserLocation = true
        
        // delegation of properties
        locationManager.delegate = self
        
        // map accuracy defined
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // location permission request
        locationManager.requestWhenInUseAuthorization()
        
        // location update
        locationManager.startUpdatingLocation()
        
        CalculateBtn.isHidden = true
        
        addDoubleTap()
        
        
        
        map.delegate = self
        
        
    }
    
    @IBAction func drawRoute(_ sender: UIButton){
        map.removeOverlays(map.overlays)
        
        let sourcePlaceMark = MKPlacemark(coordinate: locationManager.location!.coordinate)
        let destinationPlaceMark = MKPlacemark(coordinate: destination)
        
        // request a direction
        let directionRequest = MKDirections.Request()
        
        // assign the source and destination properties of the request
        directionRequest.source = MKMapItem(placemark: sourcePlaceMark)
        directionRequest.destination = MKMapItem(placemark: destinationPlaceMark)
        
        // transportation type
        directionRequest.transportType = .automobile
        
        // calculate the direction
        let directions = MKDirections(request: directionRequest)
        map.removeOverlays(map.overlays)
        directions.calculate { (response, error) in
            guard let directionResponse = response else {return}
            
            // create the route
            let route = directionResponse.routes[0]
            // drawing a polyline
            self.map.addOverlay(route.polyline, level: .aboveRoads)
            self.addPolyline()
            // define the bounding map rect
            let rect = route.polyline.boundingMapRect
            self.map.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100), animated: true)
            
        }
        
    }
    
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin))
        doubleTap.numberOfTapsRequired = 2
        map.addGestureRecognizer(doubleTap)
        
    }
    
    @objc func dropPin(sender: UITapGestureRecognizer) {
        
        
        
        // add annotation
        let touchPoint = sender.location(in: map)
        let coordinate = map.convert(touchPoint, toCoordinateFrom: map)
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = coordinate
        map.addAnnotation(annotation)
        coordenateArray.append(annotation.coordinate)
        //print("La dirrecion es  \(coordenateArray)")
        
        destination = coordinate
        
        //mark counter to set pin title
        print(markCounter)
        if markCounter > 0 && markCounter < 2{
            annotation.title = "A"
            annotation.subtitle = "\(coordinate.latitude) + \(coordinate.longitude)"
        }
        if markCounter > 1 && markCounter < 3{
            annotation.title = "B"
            annotation.subtitle = "\(coordinate.latitude) + \(coordinate.longitude)"
        }
        if markCounter > 2 && markCounter < 4{
            annotation.title = "C"
            annotation.subtitle = "\(coordinate.latitude)  + \(coordinate.longitude)"
        }
        if markCounter > 3 && markCounter < 5{
            annotation.title = "A"
            markCounter = 0
        }
        
        if coordenateArray.count > 2{
            addPolyline()
            addPolygon()
            CalculateBtn.isHidden = false
        }
        if coordenateArray.count > 3{
            removePin()
            coordenateArray.removeAll()
            map.removeOverlays(map.overlays)
        }
        markCounter += 1
    }
    
    // update location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = locations[0]
        
        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        
        displayLocation(latitude: latitude, longitude: longitude, title: "HEY!", subtitle: "YOU ARE HERE!")
    }
    //adds the polylines to the calculation
    func addPolyline() {
        let coordinates = coordenateArray.map {$0.self}
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        map.addOverlay(polyline)
    }
    //adds the polygon to the 3 selected areas
    func addPolygon() {
        let coordinates = coordenateArray.map {$0.self}
        let polygon = MKPolygon(coordinates: coordinates, count: coordinates.count)
        map.addOverlay(polygon)
    }
    
    // user location method
    func displayLocation(latitude: CLLocationDegrees,
                         longitude: CLLocationDegrees,
                         title: String,
                         subtitle: String){
        
        
        let latDelta: CLLocationDegrees = 0.05
        let lngDelta: CLLocationDegrees = 0.05
        
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lngDelta)
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = MKCoordinateRegion(center: location, span: span)
        
        map.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.title = title
        annotation.subtitle = subtitle
        annotation.coordinate = location
        map.addAnnotation(annotation)
        
    }
    
    func removePin() {
        for annotation in map.annotations {
            map.removeAnnotation(annotation)
        }
        map.removeAnnotations(map.annotations)
    }
    
    func calculateDist()
    {
    
    }
    
    
    
    

}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        if annotation is MKUserLocation {
            return nil
        }
        return nil
    }
    
//render for overlay
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let renderer = MKCircleRenderer(overlay: overlay)
            renderer.fillColor = UIColor.black.withAlphaComponent(0.5)
            renderer.strokeColor = UIColor.green
            renderer.lineWidth = 2
            return renderer
        } else if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor.green
            renderer.lineWidth = 4
            return renderer
        } else if overlay is MKPolygon {
            let renderer = MKPolygonRenderer(overlay: overlay)
            renderer.fillColor = UIColor.red.withAlphaComponent(0.5)
            renderer.strokeColor = UIColor.red.withAlphaComponent(0.5)
            renderer.lineWidth = 2
            return renderer
        }
        return MKOverlayRenderer()
    }
}
