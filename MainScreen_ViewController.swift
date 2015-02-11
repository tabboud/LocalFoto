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


class MainScreen_ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, CLLocationManagerDelegate {
// Local variables
    var latitudeCoord: String!
    var longitudeCoord: String!
    var posts = [PostModel]()
    let locationManager = CLLocationManager()
    
    
// Actions & Outlets
    @IBOutlet var map: MKMapView!
    @IBOutlet var collectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
/*  1. Check authorization, and load webView if needed
    2. Load coordinates, check changes in viewWillAppear
    3. update the map 
    4. request data from API
    5. reload cells
  */
    // Loading view for the first time, so get coordinates
    self.getUserLocation()
    
    // Check authorization access token
        if let accessToken = NSUserDefaults.standardUserDefaults().objectForKey("accessToken") as? String{
            // We have accessToken, so update view
        }else{
            // No accessToken available so present webview for login
        }
        
    //CHECK TO SEE IF WE HAVE ACCESS TOKEN
    if(!strAccessToken.isEmpty){
        // Set users location on map
    
        // Get coordinates from NSUserDefaults
        let coordinateData: NSData = NSUserDefaults.standardUserDefaults().objectForKey("userLocation") as NSData
        var userLocation: CLLocationCoordinate2D!
        coordinateData.getBytes(&userLocation, length: sizeofValue(userLocation))
        
        let center = CLLocationCoordinate2D(latitude: userLocation.latitude, longitude: userLocation.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.map.setRegion(region, animated: true)
        
        // Create the location point
        var point = MKPointAnnotation()
        point.coordinate = userLocation
        self.map.addAnnotation(point)
        
        
        // Create searchURL
        self.latitudeCoord  = NSString(format: "%f", userLocation.latitude)
        self.longitudeCoord = NSString(format: "%f", userLocation.longitude)
        searchURL = searchURL + "lat=" + self.latitudeCoord + "&lng=" + self.longitudeCoord + searchURLEnd + strAccessToken
        searchLocationURL = searchLocationURL + "lat=" + self.latitudeCoord + "&lng=" + self.longitudeCoord + searchURLEnd + strAccessToken
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
                self.collectionView.reloadData()
            }
            
            }, URL: searchURL)
        
        }else{
            // Havent loaded the access token yet! present view controller
            // Display webView and request authorization
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            var webViewController: ViewController = storyboard.instantiateViewControllerWithIdentifier("myWebView") as ViewController
            self.presentViewController(webViewController, animated: true, completion: nil)
        }
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
        var locValue: CLLocationCoordinate2D = manager.location.coordinate
        
        // Stop updating location
        locationManager.stopUpdatingLocation()
        
        // Save location data into NSUserDefaults
        let data: NSData = NSData(bytes: &locValue, length: sizeofValue(locValue))
        
        NSUserDefaults.standardUserDefaults().setObject(data, forKey: "userLocation")
        NSUserDefaults.standardUserDefaults().synchronize()
        println("Got users location...Saved it")
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!){
        println("Error updating the location: \(error)\n\n")
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
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.requestAlwaysAuthorization()
            // Start getting location
            locationManager.startUpdatingLocation()
        }else{
            println("Location Services Disabled!")
        }
    }
    
}
