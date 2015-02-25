//
//  MainScreen_ViewController.swift
//  Local_Foto
//
//  Created by Tony on 2/10/15.
//  Copyright (c) 2015 Abbouds Corner. All rights reserved.
//

//TODO: check for new location upon viewWillAppear, then force the refresh
//TODO: When pushed to after changing location, it doesn't work if user is not on this main page, won't refresh
//TODO: Multiple pictures showing up after selecting pin. Then after refresh it goes back to normal. -> I think jsut set to .Local to solve refresh in viewWillAppear -> Still happens on initial launch
//TODO: Add notification to top saying 'new photos available'
//TODO: Add ability to comment, like, and follow people

//TODO: Add custom label for comments, to enable clicking on user profile and multi-line comment
//TODO: Add 'Add comment' button and view controller for all comments



import UIKit
import MapKit

let fetchPostsTimeInterval = 25

class MainScreen_ViewController: UIViewController, UICollectionViewDelegate, UIScrollViewDelegate {
// Local variables
    var posts = [InstagramMedia]()
    
    var accessToken: String? = nil
    let refreshControl = UIRefreshControl()
    var ManagerSingleton = Manager.sharedInstance
    var sharedIGEngine = InstagramEngine.sharedEngine()
    var fetchingPhotosSpinner: UIActivityIndicatorView!
    
// Actions & Outlets
    @IBOutlet var collectionView: UICollectionView!
    
    
    override func viewWillAppear(animated: Bool) {
        println("viewwillappear")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println("Viewdidload")
        
        // Add observer for currentLocation value in Singleton 'Manager.swift'
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "startRefresh", name: curLocationNotificationKey, object: nil)
        
        // Set timer for fetching new user data every 25 seconds
        var fetchTimer = NSTimer.scheduledTimerWithTimeInterval(25, target: self, selector: "fetchData", userInfo: nil, repeats: true)

        // Check authorization access token
        if let accessToken = NSUserDefaults.standardUserDefaults().objectForKey("accessToken") as? String{
            self.accessToken = accessToken
            self.sharedIGEngine.accessToken = accessToken
        }else{
            self.performSegueWithIdentifier("presentWebView", sender: self)
        }
        
        // Add refresh control to screen
        refreshControl.addTarget(self, action: "startRefresh", forControlEvents: UIControlEvents.ValueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to Refresh")
        self.collectionView.addSubview(refreshControl)
        self.collectionView.alwaysBounceVertical = true
        
        // Activity indicator for fetching photos, disabled in collectionView Delegate
        fetchingPhotosSpinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        fetchingPhotosSpinner.center = self.view.center
        fetchingPhotosSpinner.color = UIColor.blackColor()
        self.view.addSubview(fetchingPhotosSpinner)
        fetchingPhotosSpinner.startAnimating()
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
    
    func startRefresh(){
        if self.accessToken != nil{
            println("inside startRefresh")
        if(self.isPhotosAvailable == false){
            // Get instagram data
            sharedIGEngine.getMediaAtLocation(ManagerSingleton.currentLocation.coordinate, withSuccess: {(media, paginationInfo)->Void in
        
                self.posts.removeAll(keepCapacity: false)
                
                for mediaObject in media as [InstagramMedia]{
                    self.posts.append(mediaObject)
                }
                self.collectionView.reloadData()
                
                }, failure: {(error)->Void in
                    if error != nil{
                        println("error: \(error.description)")
                    }
            })
        }else{
            // set photos to ones fetched already
            self.posts = self.fetchedPosts
            self.fetchedPosts.removeAll(keepCapacity: false)
            self.isPhotosAvailable = false
            self.collectionView.reloadData()
            }
            // Scroll to top of screen
            self.collectionView.scrollRectToVisible(CGRectMake(0, 0, 1, 1), animated: true)
        }else{
            println("No access Token")
        }
        refreshControl.endRefreshing()
    }
    
    
    
    var isPhotosAvailable = false
    var fetchedPosts = [InstagramMedia]()
    func fetchData(){
        println("Fetch Data")
        sharedIGEngine.getMediaAtLocation(ManagerSingleton.currentLocation.coordinate, withSuccess: {(media, paginationInfo)->Void in
            self.fetchedPosts = media as [InstagramMedia]
            if(self.fetchedPosts.first?.link != self.posts.first?.link){
                self.isPhotosAvailable = true
                println("New photos ...")
                TSMessage.showNotificationInViewController(self, title: "New Photos Available", subtitle: nil, image: nil, type: .Success, duration: -1, callback: {()->Void in
                        self.startRefresh()
                        TSMessage.dismissActiveNotification()
                        self.navigationController?.popToRootViewControllerAnimated(true)
                    }, buttonTitle: nil, buttonCallback: nil, atPosition: TSMessageNotificationPosition.Top, canBeDismissedByUser: true)
                
            }

            }, failure: {(error)->Void in
                if error != nil{
                    println("error: \(error.description)")
                }
        })
    
    }
    
}



// MARK: UICollectionView - DataSource Methods
extension MainScreen_ViewController: UICollectionViewDataSource{
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        if(posts.count > 0){
            fetchingPhotosSpinner.stopAnimating()
        }
        return posts.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        let reuseIdentifier = "cellReuseID"
        let cell: photo_CollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as photo_CollectionViewCell
        
        if(self.posts.count > 0){
            var thumbnailURL = self.posts[indexPath.row].thumbnailURL
            cell.setThumbnailImage(thumbnailURL)
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView{
        let map = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "mapViewHeader", forIndexPath: indexPath) as MapView_CollectionReusableView
        if(ManagerSingleton.currentLocation != nil){
            let coordinates = ManagerSingleton.currentLocation.coordinate
            map.setRegion(coordinates)
            map.addAnnotation(coordinates, title: "Current Location")
        }
        return map
    }
}

// MARK: UICollectionViewFlowLayout - Delegate Methods
extension MainScreen_ViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat{
        return 4
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat{
        return 1
    }
}

// MARK: ViewControllerDelegate Methods
extension MainScreen_ViewController: ViewControllerDelegate{
    func accessTokenReceived(accessToken: String!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        self.accessToken = accessToken
        self.sharedIGEngine.accessToken = accessToken
        
        // Refresh screen or request current location, now that we have token
        if (self.ManagerSingleton.currentLocation != nil){
            self.startRefresh()
        }else{
            self.ManagerSingleton.findCurrentLocation()
        }
    }
}









