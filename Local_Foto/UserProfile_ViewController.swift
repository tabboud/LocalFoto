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

class UserProfile_ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    var userInfo: InstagramUser!
    var posts = [InstagramMedia]()
    let refreshControl = UIRefreshControl()
    var isFetchingData: Bool = false    //flag for fetching pagination data
    var sharedIGEngine = InstagramEngine.sharedEngine()
    var currentPaginationInfo: InstagramPaginationInfo? = nil
    var isInitialDataLoaded = false      //Stops scrollView Delegate from requesting data upon initial load
    
// Actions & Outlets
    @IBOutlet var collectionView: UICollectionView!
    
    
    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.title = self.userInfo.username
        self.collectionView.delegate = self
    }
    
    override func viewWillDisappear(animated: Bool) {
        //Fixes UIScrollView EXC_Bad_Access code, viewDidScroll was trying to access objects in this class, but this class was already deallocated
        
        //attempting to move collection view below nav bar where button is
        self.collectionView.delegate = nil
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        println("viewDidLoad")
        // Fetch user information
        self.fetchUserDetails()
        
        // Fetch user photos
        self.fetchUserPhotos()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

// UICollectionView - Data Source methods
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return self.posts.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        
        let cell: UserPhotosCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("userPhotosCell", forIndexPath: indexPath) as UserPhotosCollectionViewCell
        
        if(self.posts.count > 0){
            var thumbnailURL = self.posts[indexPath.row].thumbnailURL
            cell.setThumbnailImage(thumbnailURL)
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

            userHeader.setImage(self.userInfo.profilePictureURL)
            userHeader.setBio(self.userInfo.bio)
            userHeader.setPostCount(String(self.userInfo.mediaCount))
            userHeader.setFollowersCount(String(self.userInfo.followedByCount))
            userHeader.setFollowingCount(String(self.userInfo.followsCount))
            self.sharedIGEngine.getRelationshipStatusOfUser(self.userInfo.Id, withSuccess: {(result)->Void in
                let status = (result as NSDictionary).objectForKey(kRelationshipOutgoingStatusKey) as String
                if status == kRelationshipOutStatusFollows{
                    userHeader.setFollowButton("Following")
                }else{
                    // Dont currently follow this user
                    userHeader.setFollowButton("Follow")
                }
                }, failure: {(error)->Void in
                    println("error getting following status: \(error.description)")
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
    
// UIScrollView - Delegate Methods
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if(self.isFetchingData == false && self.isInitialDataLoaded == true){
            if (scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height)) {
                // Reached bottom
                self.isFetchingData = true
                self.fetchUserPhotos()
            }
        }
    }
    
    
// MARK: My methods
    func fetchUserPhotos(){
        println("fetch user photos!")
        self.sharedIGEngine.getMediaForUser(self.userInfo.Id, count: 15, maxId: self.currentPaginationInfo?.nextMaxId, withSuccess: {(media, paginationInfo)->Void in
            self.isFetchingData = false
            if(paginationInfo != nil){
                self.currentPaginationInfo = paginationInfo
            }
            for mediaObject in media as [InstagramMedia]{
                self.posts.append(mediaObject)
            }
            self.collectionView.reloadData()
            self.isInitialDataLoaded = true
            }, failure: {(error)->Void in
                self.isFetchingData = false
                println("Loading User media failed!")
        })
    }
    
    func fetchUserDetails(){
        self.sharedIGEngine.getUserDetails(self.userInfo, withSuccess: {(userDetails)->Void in
            self.userInfo = userDetails as InstagramUser
            }, failure: {(error)->Void in
                println("Error fetching user details")
        })
    }
    
    
}
