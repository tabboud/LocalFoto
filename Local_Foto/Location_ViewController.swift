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

//TODO: Press 'use this location', then show alert saying, currently using 'philadelphia, PA' etc



class Location_ViewController: UIViewController, UISearchBarDelegate, CLLocationManagerDelegate {
    var coordinates: CLLocationCoordinate2D? = nil
    var geocoder: CLGeocoder? = nil
    
// Actions & Outlets
    @IBOutlet var txtAddress: UILabel!
    @IBAction func btnUseLocation(sender: AnyObject) {
    }
    @IBOutlet var map: MKMapView!
    @IBOutlet var searchBar: UISearchBar!
    
    
    
    override func viewWillAppear(animated: Bool) {
        // Fetch and save locally current location
        if let curLoc = NSUserDefaults.standardUserDefaults().objectForKey("userLocation") as? NSData{
            curLoc.getBytes(&self.coordinates, length: sizeofValue(self.coordinates))
            setUpMap(self.coordinates)
            
            // Must geocode this location, then set address
            self.geocodeCoordinates(self.coordinates)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpMap(coordinate: CLLocationCoordinate2D!){
        let center = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.map.setRegion(region, animated: true)
        
        // Create the location point
        var point = MKPointAnnotation()
        point.coordinate = coordinate
        self.map.addAnnotation(point)
    }
    
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
                let v = ABCreateStringWithAddressDictionary(placemark.addressDictionary, false)
                println(v)
                self.txtAddress.text = v
            }
        })
        
    }
    
// UISearchBar - Delegate methods
    func searchBarSearchButtonClicked(searchBar: UISearchBar){
        self.searchBar.resignFirstResponder()
        if (self.geocoder == nil){
            self.geocoder = CLGeocoder()
        }
        self.geocoder?.geocodeAddressString(searchBar.text, completionHandler: {(placemarks, error)->Void in
            if (error != nil){
                if let clErr = CLError(rawValue: error.code){
                    switch clErr{
                        case .Denied:
                            println("location services denied")
                        case .Network:
                            println("No network available")
                        case .LocationUnknown:
                            println("Location unknown")
                        default:
                            println("Unkown CoreLocation error")
                    }
                }else{
                    println("other error")
                }
            }else if(placemarks.count > 0){
                let placemark = (placemarks as NSArray).objectAtIndex(0) as CLPlacemark
                let coordinates: CLLocationCoordinate2D = placemark.location.coordinate
                self.setUpMap(coordinates)
                
                let address = ABCreateStringWithAddressDictionary(placemark.addressDictionary, false)
                self.txtAddress.text = address
            }
        })
    }
}
