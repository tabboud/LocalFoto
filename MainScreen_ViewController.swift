//
//  MainScreen_ViewController.swift
//  Local_Foto
//
//  Created by Tony on 2/10/15.
//  Copyright (c) 2015 Abbouds Corner. All rights reserved.
//

import UIKit
import MapKit

//var searchLocationURL = "https://api.instagram.com/v1/locations/search?lat=39.2902778&lng=-76.6125&distance=1000"
//var searchURL = "https://api.instagram.com/v1/media/search?lat=39.2833&lng=-76.6167&distance=5000&access_token="
var searchURL = "https://api.instagram.com/v1/media/search?"
let searchURLEnd = "&distance=2000&access_token="
var searchLocationURL = "https://api.instagram.com/v1/locations/search?"


class MainScreen_ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, CLLocationManagerDelegate, ViewControllerDelegate {
// Local variables
    var posts = [PostModel]()
    var locationManager = CLLocationManager()
    var coordinatesSet = false
    
// Actions & Outlets
    @IBOutlet var map: MKMapView!
    @IBOutlet var collectionView: UICollectionView!
    @IBAction func refreshBtn(sender: AnyObject) {
        // !! can figure out how to move photos, if any new ones are there, without deleting ALL posts
        if(self.coordinatesSet == false){
            println("Coordinates not set")
        }else{
            println("refreshing photos")
            println("current posts: \(posts)")
            
            posts.removeAll(keepCapacity: false)
            self.getDataFromInstagram()
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        println("viewDidLoad")
        
    // Check authorization access token
        if let accessToken = NSUserDefaults.standardUserDefaults().objectForKey("accessToken") as? String{
            // We have accessToken, so update view
            println("have token")
            strAccessToken = accessToken
            println("TOKEN: \(accessToken)")
        }else{
            // No accessToken available so present webview for login
            println("presenting webview")
            self.performSegueWithIdentifier("presentWebView", sender: self)
        }
        self.getUserLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "viewLargePhoto"){
            let controller: LargePhoto_ViewController = segue.destinationViewController as LargePhoto_ViewController
            let indexPath: NSIndexPath = self.collectionView.indexPathForCell(sender as UICollectionViewCell)!
            controller.post = self.posts[indexPath.row]
        }else if(segue.identifier == "presentWebView"){
            let VC: ViewController = segue.destinationViewController as ViewController
            VC.delegate = self
        }
    }
    

// UICollectionView - DataSource Methods
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        if(posts.count > 0){
            return posts.count
        }else{
            return 0
        }
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        let reuseIdentifier = "cellReuseID"
        let cell: photo_CollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as photo_CollectionViewCell

        if(self.posts.count > 0){
            var thumbnailURL = self.posts[indexPath.row].thumbnailPhotoURL
            cell.setThumbnailImage(NSURL(string: thumbnailURL))
        }else{
            cell.backgroundColor = UIColor.redColor()
        }
        return cell
    }

// UICollectionView - Delegate Methods
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath){
        println("did select item")
    }
    
// UICollectionViewFlowLayout - Delegate Methods
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat{
        return 4
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat{
        return 1
    }
    
    
// CLLocationManager - Delegate methods
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!){
        // Stop updating location
        self.locationManager.stopUpdatingLocation()

        var locValue: CLLocationCoordinate2D = manager.location.coordinate

        // Save location data into NSUserDefaults
        let data: NSData = NSData(bytes: &locValue, length: sizeofValue(locValue))
        
        NSUserDefaults.standardUserDefaults().setObject(data, forKey: "userLocation")
        NSUserDefaults.standardUserDefaults().synchronize()
        println("Location saved")
        // Only set coordinates if not set already
        if(self.coordinatesSet == false){
            self.setCoordinates()
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!){
        println("Error updating the location: \(error)\n\n")
    }

// ViewControllerDelegate Methods
    func accessTokenReceived() {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        // we have accessToken, now check for Coordinates then display
        if (self.coordinatesSet == true){
            println("Inside delegate, requesting data")
            self.getDataFromInstagram()
        }else{
            println("have token, but not coordinates!")
        }

    }
    
    
// My methods
    func unixTimeConvert(unixTime: NSString!)->NSString{
        let timeStamp = unixTime.doubleValue
        let date: NSDate = NSDate(timeIntervalSince1970: timeStamp)
        
        var estDF = NSDateFormatter()
        estDF.setLocalizedDateFormatFromTemplate("YYYY-MM-dd HH:mm:ss Z")
        let estDateStr = estDF.stringFromDate(date)
        
        let timeZoneOffset = NSTimeZone(abbreviation: "EST")?.secondsFromGMT
        let estTimeInterval:NSTimeInterval = date.timeIntervalSinceReferenceDate + NSTimeInterval(timeZoneOffset!)
        let estDate = NSDate(timeIntervalSinceReferenceDate: estTimeInterval)
        return estDate.description
    }
    
    func getUserLocation() -> Void{
        // For use in the foreground, not background gps
        self.locationManager.requestWhenInUseAuthorization()

        // Check if location services are enabled
        if(CLLocationManager.locationServicesEnabled()){
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager.distanceFilter = 500   // 500 meters until another update
            // Start getting location
            self.locationManager.startUpdatingLocation()
            
            // Try to set the current coordinates
            self.setCoordinates()
            
        }else{
            println("Location Services Disabled!")
        }
    }
    
    func setCoordinates(){
        if let coordinate = self.locationManager.location?.coordinate{
            println("setCoordinates")
            
            self.coordinatesSet = true
            // If there is an access token, then request data
            if let accessToken = NSUserDefaults.standardUserDefaults().objectForKey("accessToken") as? String{
                self.getDataFromInstagram()
            }
            
            let locValue: CLLocationCoordinate2D = self.locationManager.location.coordinate
            // Set region for map and add pin
            let center = CLLocationCoordinate2D(latitude: locValue.latitude, longitude: locValue.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            self.map.setRegion(region, animated: true)
            
            // Create the location point
            var point = MKPointAnnotation()
            point.coordinate = locValue
            self.map.addAnnotation(point)
        }else{
            println("Dont have coordinate yet!")
        }
    }
    
    func getDataFromInstagram(){
        let coordinate: CLLocationCoordinate2D = self.locationManager.location.coordinate
        let lat  = NSString(format: "%f", coordinate.latitude)
        let long = NSString(format: "%f", coordinate.longitude)
        
        // Create searchURL
        searchURL = searchURL + "lat=" + lat + "&lng=" + long + searchURLEnd + strAccessToken
        
        DataManager.getDataFromInstagramWithSuccess({(instagramData: NSData!)-> Void in
            let json = JSON(data: instagramData, options: nil, error: nil)
            
            if let postsArray = json["data"].array{
                
                for val in postsArray {
                    var userName = val["user"]["username"].string
                    var fullName = val["user"]["full_name"].string
                    var thumbnailURL = val["images"]["thumbnail"]["url"].string
                    var highResURL = val["images"]["standard_resolution"]["url"].string
                    var caption = val["caption"]["text"].string
                    var timeTaken = self.unixTimeConvert(val["created_time"].string)
                    
                    self.posts.append(PostModel(userName: userName, fullName: fullName, thumbPhotoURL: thumbnailURL, highPhotoURL: highResURL, caption: caption, timeTaken: timeTaken))
                }
                println("Reloading collection view")
                dispatch_async(dispatch_get_main_queue(), {
                    self.collectionView.reloadData()
                })
            }
            }, URL: searchURL)
    }
    
}
