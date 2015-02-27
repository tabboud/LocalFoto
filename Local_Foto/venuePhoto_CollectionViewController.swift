//
//  venuePhoto_CollectionViewController.swift
//  Local_Foto
//
//  Created by Tony on 2/26/15.
//  Copyright (c) 2015 Abbouds Corner. All rights reserved.
//

import UIKit

let reuseIdentifier = "Cell"

class venuePhoto_CollectionViewController: UICollectionViewController {

    var media: [InstagramMedia] = [InstagramMedia]()
    var venueDetails: JSON! // This is set from other VC that performSegue to this VC
    let sharedIGEngine = InstagramEngine.sharedEngine()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fetch Media based off of locationID from venueDetails
        self.getVenuePhotos()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
/*
My Methods
*/
    func getVenuePhotos(){
        if(self.venueDetails != nil){
            if let locationID = self.venueDetails["id"].string{
                self.getLocationID(locationID)
            }
        }
    }
    
    // Get Instagram locationID from Foursquare LocationID
    func getLocationID(locationID: String!){
        
        // Attempt to get from my InstagramKit addition
        self.sharedIGEngine.searchForLocationWithFoursquareID(locationID, withSuccess: {(locations, paginationInfo)->Void in
                let foundLocation = locations as [InstagramLocation]
            
            if let locationId = foundLocation.first?.locationID{
                self.fetchRecentMedia(locationId)
            }
//                println("THIS IS THE RETURNED RESPONSE: \(foundLocation.first?.locationID) + \(foundLocation.first?.name) + \(foundLocation.first)")
            }, failure: {(error)->Void in})
        
        
        
//        let url = NSString(format: "https://api.instagram.com/v1/locations/search?foursquare_v2_id=%@&access_token=%@", locationID, sharedIGEngine.accessToken)
//        DataManager.getDataFromInstagramWithSuccess(url, success: {(data, error)->Void in
//            if error != nil{
//                println("Error getting location details")
//            }else{
//                // fetch pins about this location
//                if let dataArray = data["data"].array{
//                    let LocationID = dataArray[0]["id"].string
//                    
//                    // fetch recent media at this location
//                    self.fetchRecentMedia(LocationID)
//                }
//            }
//        })
    }
    
    // Get recent media from IG at this locationID
    func fetchRecentMedia(locationID: String!){
        
        let url = NSString(format: "https://api.instagram.com/v1/locations/%@/media/recent?access_token=%@", locationID, sharedIGEngine.accessToken)
        DataManager.getDataFromInstagramWithSuccess(url, success: {(data, error)->Void in
            if error != nil{
                println("Error getting location details")
            }else{
                // fetch pins about this location
                if let dataArray = data["data"].array{
                    self.media.removeAll(keepCapacity: false)
                    for post in dataArray{
                        let mediaPost: InstagramMedia = InstagramMedia(info: post.dictionaryObject)
                        println(mediaPost.user.username)
                        self.media.append(mediaPost)
                    }
                    dispatch_async(dispatch_get_main_queue(), {
                        if let cView = self.collectionView{
                            cView.reloadData()
                        }
                    })
                    
                }
            }
        })
    }
    
    
    
    

// MARK: UICollectionViewDataSource
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.media.count > 0) ? self.media.count : 0
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: venuePhoto_CollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("venuePhotoCell", forIndexPath: indexPath) as venuePhoto_CollectionViewCell

        cell.setPhoto(self.media[indexPath.row].thumbnailURL)
    
        return cell
    }

    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView{
        let venueInfo: VenueInfo_CollectionReusableView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "venueInfoID", forIndexPath: indexPath) as VenueInfo_CollectionReusableView
        println("viewForSupplementary")
        if(self.venueDetails != nil){
            venueInfo.setVenueName(self.venueDetails["name"].string)
            
            if let address = self.venueDetails["location"]["address"].string{
                venueInfo.setAddress(address)
            }else{
                venueInfo.setAddress("No address")
            }
            
            if let phoneNumber = self.venueDetails["contact"]["formattedPhone"].string{
                venueInfo.setPhoneNumber(phoneNumber)
            }else{
                venueInfo.setPhoneNumber("No number")
            }
            
            if let hours = self.venueDetails["hours"]["status"].string{
                venueInfo.setHoursOfOperation(hours)
            }else{
                venueInfo.setHoursOfOperation("No hours")
            }
        }
        return venueInfo
    }
    
}
