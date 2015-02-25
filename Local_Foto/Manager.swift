//
//  Manager.swift
//  Local_Foto
//
//  Created by Tony on 2/20/15.
//  Copyright (c) 2015 Abbouds Corner. All rights reserved.
//
import Foundation
import CoreLocation


// NSNotification Key for currentLocation
let curLocationNotificationKey = "curLocationNotification"


class Manager: NSObject {
    
    // Local Properties
    private var locationManager: CLLocationManager!
    private var isFirstUpdate: Bool                 // Used so we dont record the first update of location, which is always garbage.
    var currentLocation: CLLocation!                // Explicitly unwrapped optional, since we don't update until after super.init()
    
    
    class var sharedInstance: Manager {
        struct Static {
            static var instance: Manager?
            static var token: dispatch_once_t = 0
        }
        dispatch_once(&Static.token) {
            Static.instance = Manager()
        }
        return Static.instance!
    }
    
    override init(){
        self.isFirstUpdate = true
        
        // call super after initializing local properties
        super.init()
    }
    
    
    func findCurrentLocation(){
        self.isFirstUpdate = true
        println("find Location..")
        
        if(self.locationManager == nil){
            self.locationManager = CLLocationManager()
            self.locationManager.delegate = self
        }
        
        // For use in the foreground, not background gps
        self.locationManager.requestWhenInUseAuthorization()
        
        // Check if location services are enabled
        if(CLLocationManager.locationServicesEnabled()){
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.startUpdatingLocation()
        }else{
            println("Location Services Disabled!")
            }
    }

}
// MARK: CLLocationManager - Delegate Methods
extension Manager: CLLocationManagerDelegate{
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!){
        if(self.isFirstUpdate == true){
            self.isFirstUpdate = false
            return
        }
        
        let location = locations.last as CLLocation
        
        if(location.horizontalAccuracy > 0 && self.locationManager != nil){
            println("locationDelegate")
            self.locationManager.stopUpdatingLocation()
            // release location manager to force stoppage of coordinate data
            self.locationManager = nil
            self.currentLocation = location
            
            // Post a notification that current location has been updated
            NSNotificationCenter.defaultCenter().postNotificationName(curLocationNotificationKey, object: nil)
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!){
        println("Error updating the location: \(error)\n\n")
    }
    
}



