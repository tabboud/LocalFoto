//
//  UserProfile_ViewController.swift
//  Local_Foto
//
//  Created by Tony on 2/15/15.
//  Copyright (c) 2015 Abbouds Corner. All rights reserved.
//

//Must search for user by id to get their bio / profile picture (can get this from either)
//then send request to get recent media (has pagination, and profile pic)
import UIKit

class UserProfile_ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    var userInfo: PostModel!
    var posts = [PostModel]()
    let refreshControl = UIRefreshControl()
// Actions & Outlets
    @IBOutlet var collectionView: UICollectionView!
    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.title = userInfo.userName
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Request posts (i.e. photos) from API
        self.getDataFromInstagram()
        
        // Add refresh control to screen
        refreshControl.addTarget(self, action: "startRefresh", forControlEvents: .ValueChanged)
        self.collectionView.addSubview(refreshControl)
    }
    func startRefresh(){
        println("REFRESHING")
        refreshControl.endRefreshing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

// UICollectionView - Data Source methods
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return (posts.count > 0) ? posts.count : 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        
        let cell: UserPhotosCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("userPhotosCell", forIndexPath: indexPath) as UserPhotosCollectionViewCell
        
        if(self.posts.count > 0){
            var thumbnailURL = self.posts[indexPath.row].thumbnailPhotoURL
            cell.setThumbnailImage(NSURL(string: thumbnailURL))
        }
        return cell
    }
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int{
        return 1
    }
    
// UICollectionView - Delegate Methods
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        var userHeader: UserProfile_CollectionReusableView!
        if(kind == UICollectionElementKindSectionHeader){
            userHeader = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "userProfileHeaderID", forIndexPath: indexPath) as UserProfile_CollectionReusableView
            userHeader.setFullName(userInfo.fullName)
            userHeader.setImage(userInfo.profilePictureURL)
            
            // Fetch AccessToken
            let accessToken = NSUserDefaults.standardUserDefaults().objectForKey("accessToken") as String
            
            // Create URL
            let requestURL = NSString(format: "https://api.instagram.com/v1/users/%@/?access_token=%@", self.userInfo.userId, accessToken)
            
            DataManager.getDataFromInstagramWithSuccess(requestURL, success: {(instagramData, error)->Void in
                if(error != nil){
                    println("Some error occured")
                }else{
                    dispatch_async(dispatch_get_main_queue(), {
                        userHeader.setBio(instagramData["data"]["bio"].string)
                    })
                }
            })
        }
        return userHeader
    }
    
    // UICollectionViewFlowLayout - Delegate Methods
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat{
        return 4
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat{
        return 1
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "showUserPhotoLarge"){
            let destVC: LargePhoto_ViewController = segue.destinationViewController as LargePhoto_ViewController
            let indexPath: NSIndexPath = self.collectionView.indexPathForCell(sender as UICollectionViewCell)!
            destVC.post = self.posts[indexPath.row]
        }
    }

    
// My methods
    func getDataFromInstagram(){
        // Fetch AccessToken
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey("accessToken") as String

        // Create URL
        let requestURL = NSString(format: "https://api.instagram.com/v1/users/%@/media/recent/?access_token=%@", self.userInfo.userId, accessToken)
        
        DataManager.getDataFromInstagramWithSuccess(requestURL, success: {(instagramData, error)->Void in
            if(error != nil){
                println("Error getting data!")
            }else{
                if let postsArray = instagramData["data"].array{
                    for val in postsArray {
                        var userName        = val["user"]["username"].string
                        var fullName        = val["user"]["full_name"].string
                        var thumbnailURL    = val["images"]["thumbnail"]["url"].string
                        var highResURL      = val["images"]["standard_resolution"]["url"].string
                        var caption         = val["caption"]["text"].string
                        var timeTaken       = self.unixTimeConvert(val["created_time"].string)
                        var userID          = val["user"]["id"].string
                        var profilePicURL   = val["user"]["profile_picture"].string
                        
                        self.posts.append(PostModel(userName: userName, fullName: fullName, thumbPhotoURL: thumbnailURL, highPhotoURL: highResURL, caption: caption, timeTaken: timeTaken, ID: userID, profilePic: profilePicURL))
                    }
                    
                    //TODO: Handle Pagination here
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.collectionView.reloadData()
                    })
                }
            }
        })
    }

    
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
    

}
