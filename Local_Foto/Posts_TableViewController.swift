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
        
//        self.tableView.estimatedRowHeight = 418.0
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
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tableView.reloadData()
                    })
                    
                    }, failure: {(error)->Void in
                        if error != nil{
                            println("error: \(error.description)")
                        }
                })
            }else{
                //traverse fetchedPosts and compare links until one is the same as in current posts
                var index = 0
                for post in fetchedPosts{
                    if post.link == posts.first?.link{
                        println("Index of match: \(index)")
                        break
                    }
                    index += 1
                }
                for(var i=index-1; i>=0; i--){
                    self.posts.insert(self.fetchedPosts[i], atIndex: 0)
                }
                index = 0
                
                self.fetchedPosts.removeAll(keepCapacity: false)
                self.isPhotosAvailable = false
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
            }
            // Scroll to top of screen
            self.tableView.scrollRectToVisible(CGRectMake(0, 0, 1, 1), animated: true)
        }else{
            println("No access Token")
        }
    }
    
    func fetchData(){
        if self.accessToken != nil{
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


    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "showUserProfile"){
            let destVC = segue.destinationViewController as UserProfile_ViewController
            let index = sender as Int
            destVC.userInfo = self.posts[index].user
        }else if(segue.identifier == "showComments"){
            let destVC = segue.destinationViewController as Comments_TableViewController
            let index = sender as Int
            destVC.media = self.posts[index]
        }else if(segue.identifier == "presentWebView"){
            let VC: ViewController = segue.destinationViewController as ViewController
            VC.delegate = self
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
        cell.setCaption(userPost.caption.text)
        cell.setPostPhoto(userPost.thumbnailURL, standardResURL: userPost.standardResolutionImageURL)
        cell.setUserProfilePhoto(userPost.user.profilePictureURL)
        cell.setLikeCount(String(userPost.likesCount))
        cell.delegate = self
        cell.cellIndex = indexPath.row
        cell.setTimeTakenLabel(self.timeSinceTaken(userPost.createdDate))
        cell.setNumOfComments(String(userPost.commentCount))
        

          
        return cell
    }

    
    func timeSinceTaken(createdDate: NSDate!) -> String{
        // Create two NSDate objects
        
        let curTime = NSDate()
        
        if let estDate = createdDate{
            // subtract two dates
            let c = NSCalendar.currentCalendar()
            let calendarFlags: NSCalendarUnit = .HourCalendarUnit | .MinuteCalendarUnit | .SecondCalendarUnit | .DayCalendarUnit | .MonthCalendarUnit | .YearCalendarUnit | .WeekOfYearCalendarUnit | .MonthCalendarUnit
            let components:NSDateComponents = c.components(calendarFlags, fromDate: curTime, toDate: estDate, options: nil)
            
            var year = components.year
            var month = components.month
            var weeks = components.weekOfYear
            var day = components.day
            var hours = components.hour
            var minutes = components.minute
            var seconds = components.second
            
            if(year != 0){
                return String(abs(year)) + "Y"
            }else if(month != 0){
                return String(abs(month)) + "M"
            }else if(weeks != 0){
                return String(abs(weeks)) + "w"
            }else if(day != 0){
                return String(abs(day)) + "d"
            }else if(hours != 0){
                return String(abs(hours)) + "h"
            }else if(minutes != 0){
                return String(abs(minutes)) + "m"
            }else if(seconds != 0){
                return String(abs(seconds)) + "s"
            }else{
                return "just now"
            }
        }else{
            return "No time avail."
        }
    }
    

    
}

extension Posts_TableViewController: PostsTabeViewCellDelegate{
    func didPressUserButton(cellIndex: Int) {
        self.performSegueWithIdentifier("showUserProfile", sender: cellIndex)
    }
    func didPressCommentsButton(cellIndex: Int) {
        self.performSegueWithIdentifier("showComments", sender: cellIndex)
    }
    
}

// MARK: ViewControllerDelegate Methods
extension Posts_TableViewController: ViewControllerDelegate{
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

