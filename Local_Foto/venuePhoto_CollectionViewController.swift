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
        
        self.sharedIGEngine.searchForLocationWithFoursquareID(locationID, withSuccess: {(locations, paginationInfo)->Void in
                let foundLocation = locations as [InstagramLocation]
            
            if let locationId = foundLocation.first?.locationID{
                self.fetchRecentMedia(locationId)
            }
            }, failure: {(error)->Void in})

    }
    
    // Get recent media from IG at this locationID
    func fetchRecentMedia(locationID: String!){
        
        
        self.sharedIGEngine.fetchRecentMediaAtLocation(locationID, withSuccess: {(media, paginationInfo)->Void in
                self.media = media as [InstagramMedia]
            dispatch_async(dispatch_get_main_queue(), {
                if let cView = self.collectionView{
                    cView.reloadData()
                }
            })
            }, failure: {(error)->Void in
                println("error fetching recent media at location")
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
