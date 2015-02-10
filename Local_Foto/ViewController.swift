//
//  ViewController.swift
//  Local_Foto
//
//  Created by Tony on 2/7/15.
//  Copyright (c) 2015 Abbouds Corner. All rights reserved.
//

import UIKit
import CoreLocation

var strAccTok = ""
let AUTHURL        = "https://api.instagram.com/oauth/authorize/"       // Used for Oauth
let APIURL         = "https://api.instagram.com/v1/"                    // API Url
let CLIENTID       = "db65495f5ece4a4aac490ccc13963c05"
let REDIRECTURL    = "http://AbboudsCorner.wordpress.com"

class ViewController: UIViewController, UIWebViewDelegate, CLLocationManagerDelegate {
    let fullURL = NSString(format: "%@?client_id=%@&redirect_uri=%@&response_type=token", AUTHURL, CLIENTID, REDIRECTURL)
    let locationManager = CLLocationManager()
    
    // Outlets
    @IBOutlet var myWebView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadURL()
        self.getUserLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadURL(){
        let url: NSURL = NSURL(string: fullURL)!
        let requestObj: NSURLRequest = NSURLRequest(URL: url)
        self.myWebView.loadRequest(requestObj)
        self.myWebView.delegate = self
        self.view.addSubview(myWebView)
    }


// My Methods
    func getUserLocation() -> Void{
        // For use in the foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        // Check if location services are enabled
        if(CLLocationManager.locationServicesEnabled()){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.requestAlwaysAuthorization()
            // Start getting location
            locationManager.startUpdatingLocation()
        }else{
            println("Location Services Disabled!")
        }
    }

// CLLocationManager - Delegate methods
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!){
        var locValue: CLLocationCoordinate2D = manager.location.coordinate
        
        // Stop updating location
        locationManager.stopUpdatingLocation()
        
        // Save location data into NSUserDefaults
        let data: NSData = NSData(bytes: &locValue, length: sizeofValue(locValue))
        
        NSUserDefaults.standardUserDefaults().setObject(data, forKey: "userLocation")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!){
        println("Error updating the location: \(error)\n\n")
    }
    
// UIWebView - Delegate method
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool{
        var urlString:NSString = request.URL.absoluteString!
        println("URL String : \(urlString)")
        
        if(urlString.containsString("#access_token=")){
            let accessTok: NSRange = urlString.rangeOfString("#access_token=")
            let strAccessTok: String = urlString.substringFromIndex(NSMaxRange(accessTok))
            
            // Access token is stored in strAccessTok
            strAccTok = strAccessTok
            println("Acc Tok: \(strAccTok)")
            return false
        }
        
        return true
    }

}









