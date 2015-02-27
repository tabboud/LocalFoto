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

    var media: [InstagramMedia] = [InstagramMedia](){
        didSet{
            self.collectionView?.reloadData()
        }
    }
    
    var venueDetails: JSON!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
//        self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "venuePhotoCell")

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
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
    
    
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}
