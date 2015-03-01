//
//  Posts_TableViewController.swift
//  Local_Foto
//
//  Created by Tony on 2/25/15.
//  Copyright (c) 2015 Abbouds Corner. All rights reserved.
//

import UIKit

class Posts_TableViewController: UITableViewController {
    var posts = [InstagramMedia]()
    var accessToken: String? = nil
    var sharedIGEngine = InstagramEngine.sharedEngine()
    var ManagerSingleton = Manager.sharedInstance

    var isPhotosAvailable = false
    var fetchedPosts = [InstagramMedia]()

    @IBOutlet var postsTableView: UITableView!
    
    @IBOutlet var customMap: LocalMap_UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.tableView.estimatedRowHeight = 411.0
//        self.tableView.rowHeight = UITableViewAutomaticDimension

        

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
    }
    
    
    func startRefresh(){
        if self.accessToken != nil{
            println("inside startRefresh")
            
            // Setup map
            if(ManagerSingleton.currentLocation != nil){
                let coordinates = ManagerSingleton.currentLocation.coordinate
                self.customMap.setRegion(coordinates)
                self.customMap.addAnnotation(coordinates, title: "Current Location")
            }
            
            if(self.isPhotosAvailable == false){
                // Get instagram data
                sharedIGEngine.getMediaAtLocation(ManagerSingleton.currentLocation.coordinate, withSuccess: {(media, paginationInfo)->Void in
                    
                    self.posts.removeAll(keepCapacity: false)
                    
                    for mediaObject in media as [InstagramMedia]{
                        self.posts.append(mediaObject)
                    }
                    self.tableView.reloadData()
                    
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
                self.tableView.reloadData()
            }
            // Scroll to top of screen
            self.tableView.scrollRectToVisible(CGRectMake(0, 0, 1, 1), animated: true)
        }else{
            println("No access Token")
        }
    }
    
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


    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "showUserProfile"){
            let destVC = segue.destinationViewController as UserProfile_ViewController
            let index = sender as Int
            destVC.userInfo = self.posts[index].user
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

// MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("postCellReuseID", forIndexPath: indexPath) as Posts_TableViewCell
        
        let userPost = self.posts[indexPath.row]
        
        cell.setUserName(userPost.user.username)
        cell.setPostPhoto(userPost.thumbnailURL, standardResURL: userPost.standardResolutionImageURL)
        cell.setUserProfilePhoto(userPost.user.profilePictureURL)
        cell.mdelegate = self
        cell.cellIndex = indexPath.row
        
        // Configure MGSwipe stuff, If not used set post_tableViewCell back to UItableViewCell inherited
//        cell.rightButtons = [MGSwipeButton(title: "Like", backgroundColor: UIColor.blueColor())]
//        cell.rightSwipeSettings.transition = .TransitionBorder
//        cell.rightExpansion.fillOnTrigger = false
        

        
        return cell
    }


    
}

extension Posts_TableViewController: PostsTabeViewCellDelegate{
    func didPressUserButton(cellIndex: Int) {
        self.performSegueWithIdentifier("showUserProfile", sender: cellIndex)
    }
}

