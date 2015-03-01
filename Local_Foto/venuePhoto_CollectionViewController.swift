//
//  venuePhoto_CollectionViewController.swift
//  Local_Foto
//
//  Created by Tony on 2/26/15.
//  Copyright (c) 2015 Abbouds Corner. All rights reserved.
//

import UIKit

let reuseIdentifier = "Cell"

class venuePhoto_CollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    @IBOutlet var venueCollectionView: UICollectionView!
    var media: [InstagramMedia] = [InstagramMedia]()
    var venueDetails: JSON! // This is set from other VC that performSegue to this VC
    let sharedIGEngine = InstagramEngine.sharedEngine()
    var IGLocationID : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fetch Media based off of locationID from venueDetails
        self.getVenuePhotos()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showLargePhoto"{
            let destVC = segue.destinationViewController as LargePhoto_ViewController
            let cell = sender as venuePhoto_CollectionViewCell
            if let indexPath = self.collectionView?.indexPathForCell(cell){
                destVC.post = self.media[indexPath.row]
            }
        }
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
                self.IGLocationID = locationId
                self.fetchRecentMedia(locationId)
            }
            }, failure: {(error)->Void in})

    }
    
    // Get recent media from IG at this locationID
    func fetchRecentMedia(locationID: String!){
        
        if((self.isInitialDataLoaded == false) || (self.isInitialDataLoaded == true && self.currentPaginationInfo != nil)){
            self.sharedIGEngine.fetchRecentMediaAtLocation(locationID, count: -1, maxId: self.currentPaginationInfo?.nextMaxId, withSuccess: {(media, paginationInfo)->Void in
                self.isFetchingData = false
                self.isInitialDataLoaded = true
                
                if(paginationInfo != nil){
                    self.currentPaginationInfo = paginationInfo as InstagramPaginationInfo
                }else{
                    self.currentPaginationInfo = nil
                }
                
                
                for mediaObj in media as [InstagramMedia]{
                    self.media.append(mediaObj)
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.venueCollectionView.reloadData()
                })
                
                }, failure: {(error)->Void in
                    //self.isInitialDataLoaded = true
                    println("error fetching recent media at location")
            })
        }
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
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // perform segue to largePhoto to display picture
        self.performSegueWithIdentifier("showLargePhoto", sender: collectionView.cellForItemAtIndexPath(indexPath))
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat{
        return 4
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat{
        return 1
    }
 
    var isFetchingData = false
    var isInitialDataLoaded = false
    var currentPaginationInfo: InstagramPaginationInfo? = nil

    
}

extension venuePhoto_CollectionViewController: UIScrollViewDelegate{
    // UIScrollView - Delegate Methods
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if(self.isFetchingData == false && self.isInitialDataLoaded == true){
            if (scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height)) {
                // Reached bottom
                self.isFetchingData = true
                self.fetchRecentMedia(self.IGLocationID)
            }
        }
    }
}
