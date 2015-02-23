//
//  Location_ViewController.swift
//  Local_Foto
//
//  Created by Tony on 2/17/15.
//  Copyright (c) 2015 Abbouds Corner. All rights reserved.
//


import UIKit
import CoreLocation
import MapKit
import AddressBookUI


class Location_ViewController: UIViewController, UISearchBarDelegate, UISearchDisplayDelegate, CLLocationManagerDelegate {
    var coordinates: CLLocationCoordinate2D? = nil
    var geocoder:CLGeocoder? = nil
    var tempPlacemark: CLPlacemark? = nil
    var locationManager = CLLocationManager()
    var currentLocationSet: Bool = false
    let ManagerSingleton = Manager.sharedInstance
    
    
// Actions & Outlets
    @IBOutlet var txtAddress: UILabel!
    @IBAction func btnUseLocation(sender: AnyObject) {
        println("Use this location")
        
        // Check tempPlacemark for coordinates, then save
        if let location = self.tempPlacemark?.location{
                // Save location data into Singleton
                ManagerSingleton.currentLocation = location
            
                let v = ABCreateStringWithAddressDictionary(self.tempPlacemark?.addressDictionary, false)
                self.tempPlacemark = nil
                println("saved new location -> \(v)")
            
            // Set alert to show new location being used
                let alert = UIAlertController(title: "New Location Set", message: "\(v)", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: {(action)->Void in
                self.dismissViewControllerAnimated(true, completion: nil)
                self.tabBarController?.selectedIndex = 0
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }else{
            println("cannot use this location->tempPlacemark = nil")
            let alert = UIAlertController(title: "Error", message: "Cannot use this location", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: {(action)->Void in
                self.dismissViewControllerAnimated(true, completion: nil)
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    
    @IBOutlet var btnUseAddress: UIButton!
    @IBOutlet var map: MKMapView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var btnMyLocation: UIButton!
    @IBAction func btnMyLocation(sender: AnyObject) {
        println("Fetching my current location")
        self.ManagerSingleton.findCurrentLocation()
    }
    
    
    
    override func viewWillAppear(animated: Bool) {
        println("View will appear")

        // hide 'use this location' button -> will unhide if searched location is beyond tolerance
        self.btnUseAddress.hidden = true
        self.currentLocationSet = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.coordinates = ManagerSingleton.currentLocation.coordinate
        
        // Add observer for currentLocation value in Singleton 'Manager.swift'
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "startRefresh", name: curLocationNotificationKey, object: nil)
        
        self.startRefresh()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startRefresh(){
        println("StartRefresh")
        // Update local coordinates
        self.coordinates = ManagerSingleton.currentLocation.coordinate
        
        
        self.currentLocationSet = true
        self.setUpMap(self.coordinates)
        self.geocodeCoordinates(self.coordinates)
    }
    
    
    func setUpMap(coordinate: CLLocationCoordinate2D!){
        let center = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.map.setRegion(region, animated: true)

        self.map.removeAnnotations(self.map.annotations)
        // Create the location point
        var point = MKPointAnnotation()
        point.coordinate = coordinate
        self.map.addAnnotation(point)
    }
    
     // Reverse Geocoding -> Find Location from coordinates
    func geocodeCoordinates(coordinates: CLLocationCoordinate2D!){
        // instantiate geocoder if not done already
        if(self.geocoder == nil){
            self.geocoder = CLGeocoder()
        }
        
        //Only one geocoding instance per action
        //so stop any previous geocoding actions before starting this one
        if(self.geocoder?.geocoding == true){
            self.geocoder?.cancelGeocode()
        }
        let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
        self.geocoder?.reverseGeocodeLocation(location, completionHandler: {(placemarks, error)->Void in
            if (error != nil){
                if let clErr = CLError(rawValue: error.code){
                    switch clErr{
                    case .GeocodeCanceled:
                        println("Geocoding canceled")
                    case .GeocodeFoundPartialResult:
                        println("Partial Geocode results found")
                    case .GeocodeFoundNoResult:
                        println("No Geocode result found")
                    default:
                        println("Unkown CoreLocation error")
                    }
                }else{
                    println("other error")
                }
            }else if(placemarks.count > 0){
                let placemark = (placemarks as NSArray).objectAtIndex(0) as CLPlacemark
                let address = ABCreateStringWithAddressDictionary(placemark.addressDictionary, false)
                dispatch_async(dispatch_get_main_queue(), {
                    self.txtAddress.text = address
                })
            }
        })
        
    }
    
    // Forward Geocoding -> Find coordinates from string
    func searchBarSearchButtonClicked(searchBar: UISearchBar){
        self.searchBar.resignFirstResponder()
        self.currentLocationSet = false
        if (self.geocoder == nil){
            self.geocoder = CLGeocoder()
        }
        self.geocoder?.geocodeAddressString(searchBar.text, completionHandler: {(placemarks, error)->Void in
            if (error != nil){
                var errorStr = "Error occured"
                if let clErr = CLError(rawValue: error.code){
                    switch clErr{
                        case .Denied:
                            errorStr = "Location serviced denied"
                            println("location services denied")
                        case .Network:
                            errorStr = "No network available"
                            println("No network available")
                        case .LocationUnknown:
                            errorStr = "Location unknown"
                            println("Location unknown")
                        default:
                            println("Unkown CoreLocation error")
                    }
                }else{
                    println("other error")
                }
                
                // Present alert for error
                let alert = UIAlertController(title: "Error", message: errorStr, preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: {(action)->Void in
                    alert.dismissViewControllerAnimated(true, completion: nil)
                }))
                self.presentViewController(alert, animated: true, completion: nil)
                
            }else if(placemarks.count > 0){
                let placemark = (placemarks as NSArray).objectAtIndex(0) as CLPlacemark
                let coordinates: CLLocationCoordinate2D = placemark.location.coordinate
                self.setUpMap(coordinates)
                // Save coordinates to temporary placemark incase we want to use this location
                self.tempPlacemark = placemark
                
                let address = ABCreateStringWithAddressDictionary(placemark.addressDictionary, false)
            
                
                // Determine if search location is same as current location
                let tolerance = 0.005
                if let coord = self.coordinates{
                    if((fabs(coord.latitude - coordinates.latitude) <= tolerance) && (fabs(coord.longitude - coordinates.longitude) <= tolerance)){
                        println("Coordinates relatively close by, so no button")
                        self.btnUseAddress.hidden = true
                    }else{
                        // put use this location button on screen
                        self.btnUseAddress.hidden = false
                    }
                }
                dispatch_async(dispatch_get_main_queue(), {
                    self.txtAddress.text = address
                })
            }
        })
    }
}
