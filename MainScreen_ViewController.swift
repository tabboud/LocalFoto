//
//  MainScreen_ViewController.swift
//  Local_Foto
//
//  Created by Tony on 2/10/15.
//  Copyright (c) 2015 Abbouds Corner. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


//var searchURL = "https://api.instagram.com/v1/media/search?lat=39.2833&lng=-76.6167&distance=5000&access_token="
var searchURL = "https://api.instagram.com/v1/media/search?"
let searchURLEnd = "&distance=2000&access_token="

class MainScreen_ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, CLLocationManagerDelegate {
// Local variables
    let locationManager = CLLocationManager()
    var currentCoordinates: CLLocationCoordinate2D!
    
//    var accessToken: String!      //Store globally in strAccTok
    var latitudeCoord: String!
    var longitudeCoord: String!
    var posts = [PostModel]()
    
    
// Actions & Outlets
    @IBOutlet var map: MKMapView!
    @IBOutlet var collectionView: UICollectionView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        searchURL = searchURL + "lat=" + self.latitudeCoord + "&lng=" + self.longitudeCoord + searchURLEnd + strAccTok
        DataManager.getDataFromInstagramWithSuccess({(instagramData: NSData!)-> Void in
            let json = JSON(data: instagramData, options: nil, error: nil)
            
            if let postsArray = json["data"].array{
                
                for val in postsArray {
                    var userName = val["user"]["username"].string
                    var fullName = val["user"]["full_name"].string
                    var thumbnailURL = val["images"]["thumbnail"]["url"].string
                    var highResURL = val["images"]["standard_resolution"]["url"].string
                    var caption = val["caption"]["text"].string
                    
                    self.posts.append(PostModel(userName: userName, fullName: fullName, thumbPhotoURL: thumbnailURL, highPhotoURL: highResURL, caption: caption))
                    
                }
                dispatch_async(dispatch_get_main_queue(), {
                    self.collectionView.reloadData()
                })
                
            }
            
            }, URL: searchURL)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "viewLargePhoto"){
            let controller: LargePhoto_ViewController = segue.destinationViewController as LargePhoto_ViewController
            let indexPath: NSIndexPath = self.collectionView.indexPathForCell(sender as UICollectionViewCell)!
//            controller.photoURL = self.posts[indexPath.row].highResPhotoURL
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
//        let cell: UICollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as UICollectionViewCell
        if(self.posts.count > 0){
            var thumbnailURL = self.posts[indexPath.row].thumbnailPhotoURL

            dispatch_async(dispatch_get_main_queue(), {
                cell.setThumbnailImage(self.posts[indexPath.row].getThumbnailPhoto())
            })
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
    
}
