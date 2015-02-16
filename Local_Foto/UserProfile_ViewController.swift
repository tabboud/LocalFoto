//
//  UserProfile_ViewController.swift
//  Local_Foto
//
//  Created by Tony on 2/15/15.
//  Copyright (c) 2015 Abbouds Corner. All rights reserved.
//

//TODO: possibly make getDataWithInstagram with a callback, to then be able to set UILabels and such in the completion handler
//TODO: Combine all getDatawithInstagram and unix converter code into one file, just pass url to set?
//Must search for user by id to get their bio / profile picture (can get this from either)
//then send request to get recent media (has pagination, and profile pic)
import UIKit

class UserProfile_ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    var userInfo: PostModel!
    var posts = [PostModel]()

// Actions & Outlets
    @IBOutlet var profilePicture: UIImageView!
    
    @IBOutlet var txtFullName: UILabel!
    @IBOutlet var txtBio: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    
    
    override func viewWillAppear(animated: Bool) {
        // Set name and username
        self.txtFullName.text = userInfo.fullName
        self.navigationItem.title = userInfo.userName
        self.profilePicture.setImageWithURL(NSURL(string: userInfo.profilePictureURL), placeholderImage: UIImage(named: "AvatarPlaceholder@2x.png"))

        // Request user info for bio
        self.getUserBio()
        //Request posts (i.e. photos) from API
        self.getDataFromInstagram()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

// UICollectionView - Data Source methods
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return (posts.count > 0) ? posts.count : 0
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        
        let cell: UserPhotosCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("userPhotosCell", forIndexPath: indexPath) as UserPhotosCollectionViewCell
        
        if(self.posts.count > 0){
            var thumbnailURL = self.posts[indexPath.row].thumbnailPhotoURL
            cell.setThumbnailImage(NSURL(string: thumbnailURL))
        }else{
            cell.backgroundColor = UIColor.redColor()
        }
        
        return cell
    }
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int{
        return 1
    }
    
    // UICollectionViewFlowLayout - Delegate Methods
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat{
        return 4
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat{
        return 1
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
// My methods
    func getDataFromInstagram(){
        // Fetch AccessToken
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey("accessToken") as String

        // Create URL
        let apiURL = NSString(format: "https://api.instagram.com/v1/users/%@/media/recent/?access_token=%@", self.userInfo.userId, accessToken)
        
        let url = NSURL(string: apiURL)
        let request = NSURLRequest(URL: url!)
        
        let operation: AFHTTPRequestOperation = AFHTTPRequestOperation(request: request)
        operation.responseSerializer = AFJSONResponseSerializer()
        operation.setCompletionBlockWithSuccess({(operation, responseObject: AnyObject!)-> Void in
            let json = JSON(responseObject)
            if let postsArray = json["data"].array{
                
                for val in postsArray {
                    var userName = val["user"]["username"].string
                    var fullName = val["user"]["full_name"].string
                    var thumbnailURL = val["images"]["thumbnail"]["url"].string
                    var highResURL = val["images"]["standard_resolution"]["url"].string
                    var caption = val["caption"]["text"].string
                    var timeTaken = self.unixTimeConvert(val["created_time"].string)
                    var userID = val["user"]["id"].string
                    var profilePicURL = val["user"]["profile_picture"].string
                    
                    self.posts.append(PostModel(userName: userName, fullName: fullName, thumbPhotoURL: thumbnailURL, highPhotoURL: highResURL, caption: caption, timeTaken: timeTaken, ID: userID, profilePic: profilePicURL))

                }
                
                //TODO: Handle Pagination here
                
                
                println("Reloading collection view")
                dispatch_async(dispatch_get_main_queue(), {
                    self.collectionView.reloadData()
                    self.txtFullName.text = self.posts[0].fullName
                })
            }
            }, failure: {(operation, error)->Void in
                println("Some error occured in AFNEtworking: \(error)")
        })
        operation.start()
    }
    
    func getUserBio(){
        // Fetch AccessToken
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey("accessToken") as String
        
        // Create URL
        let apiURL = NSString(format: "https://api.instagram.com/v1/users/%@/?access_token=%@", self.userInfo.userId, accessToken)
        
        let url = NSURL(string: apiURL)
        let request = NSURLRequest(URL: url!)
        
        let operation: AFHTTPRequestOperation = AFHTTPRequestOperation(request: request)
        operation.responseSerializer = AFJSONResponseSerializer()
        operation.setCompletionBlockWithSuccess({(operation, responseObject: AnyObject!)-> Void in
            let json = JSON(responseObject)

            dispatch_async(dispatch_get_main_queue(), {
                self.txtBio.text = json["data"]["bio"].string
            })
            }, failure: {(operation, error)->Void in
                println("Some error occured in AFNEtworking: \(error)")
        })
        operation.start()
        
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
