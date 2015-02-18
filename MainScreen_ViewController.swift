//
//  MainScreen_ViewController.swift
//  Local_Foto
//
//  Created by Tony on 2/10/15.
//  Copyright (c) 2015 Abbouds Corner. All rights reserved.
//

//TODO: Add pagination code for user_profile


import UIKit
import MapKit

//var searchLocationURL = "https://api.instagram.com/v1/locations/search?lat=39.2902778&lng=-76.6125&distance=1000"
//var searchURL         = "https://api.instagram.com/v1/media/search?lat=39.2833&lng=-76.6167&distance=5000&access_token="

enum displayState{
    case Local
    case Pin
}
class MainScreen_ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, CLLocationManagerDelegate, ViewControllerDelegate, UIScrollViewDelegate {
// Local variables
    var posts = [PostModel]()
    var requestedPin: LocalPinsModel!
    var locationManager = CLLocationManager()
    var coordinatesSet = false
    var accessToken: String? = nil
    
    let refreshControl = UIRefreshControl()
    var controllerState = displayState.Local
    
// Actions & Outlets
    @IBOutlet var collectionView: UICollectionView!

    override func viewWillAppear(animated: Bool) {
        // Add refresh control to screen
        
        refreshControl.addTarget(self, action: "startRefresh", forControlEvents: .ValueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Keep Pulling")
        self.collectionView.addSubview(refreshControl)
    }
    
    func startRefresh(){
        if(self.coordinatesSet == false){
            println("Coordinates not set")
        }else{
            println("refreshing photos")
            
            posts.removeAll(keepCapacity: false)
            // Fetch Coordinates
            let curLoc = NSUserDefaults.standardUserDefaults().objectForKey("userLocation") as NSData
            var coordinate: CLLocationCoordinate2D!
            curLoc.getBytes(&coordinate, length: sizeofValue(coordinate))
            
            // Reset map coordinates from disk and get new data
            self.coordinates = coordinate
            self.getDataFromInstagram(accessToken, latitude: coordinate.latitude, longitude: coordinate.longitude)
        }
        refreshControl.endRefreshing()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println("viewDidLoad")

    // Check authorization access token
        if let accessToken = NSUserDefaults.standardUserDefaults().objectForKey("accessToken") as? String{
            // We have accessToken, so update view
            println("have token")
            self.accessToken = accessToken
        }else{
            // No accessToken available so present webview for login
            println("presenting webview")
            self.performSegueWithIdentifier("presentWebView", sender: self)
        }
        // Only request location when checking for local
        if(controllerState == .Local){
            self.getUserLocation()
        }else{
            self.navigationItem.title = requestedPin.name
            // Send API request for photos near pin
            // Set coordinates on map
            self.setCoordinates(CLLocationCoordinate2D(latitude: (requestedPin.latitude as NSString).doubleValue, longitude: (requestedPin.longitude as NSString).doubleValue))
            self.navigationItem.rightBarButtonItem = nil
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
        }else if(segue.identifier == "presentWebView"){
            let VC: ViewController = segue.destinationViewController as ViewController
            VC.delegate = self
        }
    }
    


    
// UICollectionView - DataSource Methods
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return (posts.count > 0) ? posts.count : 0
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

// UICollectionViewFlowLayout - Delegate Methods
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat{
        return 4
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat{
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        var map: MapView_CollectionReusableView!
        println("view for supplementary called")
        if(kind == UICollectionElementKindSectionHeader){
            map = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "mapHeaderID", forIndexPath: indexPath) as MapView_CollectionReusableView
            if self.coordinatesSet == true{
                let coordinate = self.coordinates
                // Set region for map and add pin
                let center = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
                let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                
                map.setRegion(region)
                
                // Create the location point
                var point = MKPointAnnotation()
                point.coordinate = coordinate
                point.title = (controllerState == .Local) ? "Your Location" : requestedPin.name
                map.addAnnotation(point)
            }

        }

        return map
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
            self.setCoordinates(locValue)
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!){
        println("Error updating the location: \(error)\n\n")
    }

// ViewControllerDelegate Methods
    func accessTokenReceived(accessToken: String!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        // we have accessToken, now check for Coordinates then display
        if (self.coordinatesSet == true){
            // Fetch Coordinates
            let curLoc = NSUserDefaults.standardUserDefaults().objectForKey("userLocation") as NSData
            var coordinate: CLLocationCoordinate2D!
            curLoc.getBytes(&coordinate, length: sizeofValue(coordinate))

            self.getDataFromInstagram(accessToken, latitude: coordinate.latitude, longitude: coordinate.longitude)
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
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest //kCLLocationAccuracyNearestTenMeters
            self.locationManager.distanceFilter = 500   // 500 meters until another update
            // Start getting location
            self.locationManager.startUpdatingLocation()
            
            // Try to set the current coordinates if location is received
            if let coordinate = self.locationManager.location?.coordinate{
                self.setCoordinates(coordinate)
            }else{
                println("No coordinates yet")
            }
            
        }else{
            println("Location Services Disabled!")
        }
    }

    var coordinates: CLLocationCoordinate2D!
    func setCoordinates(coordinate: CLLocationCoordinate2D!){
            println("setCoordinates")
            self.coordinatesSet = true
        self.coordinates = coordinate
            // If there is an access token, then request data
            if let accessToken = NSUserDefaults.standardUserDefaults().objectForKey("accessToken") as? String{
                println("getting data")
                if(controllerState == .Local){
                    self.getDataFromInstagram(accessToken, latitude: coordinate.latitude, longitude: coordinate.longitude)
                }else{
                    self.getDataFromInstagram(accessToken, latitude: nil, longitude: nil)
                }
            }
        //!!Had coordinates being set here
    }

    func getDataFromInstagram(accessToken: String!, latitude: CLLocationDegrees!, longitude: CLLocationDegrees!){
        var endpointURL: NSString!
        
        if(controllerState == .Local){
            let lat  = NSString(format: "%f", latitude)
            let long = NSString(format: "%f", longitude)
            // Create searchURL
//            let endpointURL = searchURL + "lat=" + lat + "&lng=" + long + searchURLEnd + accessToken
            endpointURL = NSString(format: "https://api.instagram.com/v1/media/search?lat=%@&lng=%@&distance=4000&access_token=%@",lat, long, accessToken )
        }else{
            endpointURL = NSString(format: "https://api.instagram.com/v1/locations/%@/media/recent?access_token=%@", requestedPin.id, accessToken)
        }
        DataManager.getDataFromInstagramWithSuccess(endpointURL, success: {(instagramData, error)->Void in
            if (error != nil){
                println("Error occured getting data!")
            }else{
                if let postsArray = instagramData["data"].array{
                    
                    for val in postsArray {
                        let userName        = val["user"]["username"].string
                        let fullName        = val["user"]["full_name"].string
                        let thumbnailURL    = val["images"]["thumbnail"]["url"].string
                        let highResURL      = val["images"]["standard_resolution"]["url"].string
                        let caption         = val["caption"]["text"].string
                        let timeTaken       = self.unixTimeConvert(val["created_time"].string)
                        let userID          = val["user"]["id"].string
                        let profilePicURL   = val["user"]["profile_picture"].string
                        let mediaType       = val["type"].string
                        
                        var videoURL: String? = nil
                        if(mediaType == "video"){
                            videoURL = val["videos"]["low_bandwidth"]["url"].string
                        }
                        
                        self.posts.append(PostModel(userName: userName, fullName: fullName, thumbPhotoURL: thumbnailURL, highPhotoURL: highResURL, caption: caption, timeTaken: timeTaken, ID: userID, profilePic: profilePicURL, type: mediaType, vidURL: videoURL))
                    }
                    if(self.posts.count == 0 && self.controllerState == .Pin){
                        let alert = UIAlertController(title: "No Photos", message: "No photos were taken at this location", preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: "Okay", style: .Default, handler: {(action)->Void in
                            alert.dismissViewControllerAnimated(true, completion: nil)
                        }))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                    dispatch_async(dispatch_get_main_queue(), {
                        self.collectionView.reloadData()
                    })
                }
            }
        })

    }
}









