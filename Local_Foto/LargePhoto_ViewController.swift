//
//  LargePhoto_ViewController.swift
//  Local_Foto
//
//  Created by Tony on 2/10/15.
//  Copyright (c) 2015 Abbouds Corner. All rights reserved.
//


//TODO: User may be private so unable to load user details in UserProfile_VC. must check and display values

import UIKit
import MediaPlayer
import AVKit
import AVFoundation

class LargePhoto_ViewController: UIViewController, UIScrollViewDelegate {
    var post: InstagramMedia!
    var comments = [InstagramComment]()
    var sharedIGEngine = InstagramEngine.sharedEngine()
    var moviePlayer: MPMoviePlayerViewController!
    var myplayer: AVPlayerViewController!
    var commentUser: InstagramUser!
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var caption: UILabel!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var userNameBtn: UIButton!
    @IBOutlet var timeSincePosted: UILabel!
    @IBOutlet var profilePicture: UIImageView!
    @IBOutlet var likesLabel: UILabel!
    @IBOutlet var commentTableView: UITableView!


    override func viewWillAppear(animated: Bool) {
        self.userNameBtn.setTitle(post.user.username, forState: UIControlState.Normal)
        self.caption.text = post.caption.text
        self.timeSincePosted.text = self.timeSinceTaken()
        self.profilePicture.setImageWithURL(self.post.user.profilePictureURL)
        self.likesLabel.text = NSString(format: "%d likes", self.post.likesCount)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.commentTableView.separatorColor = UIColor.clearColor()
        
        // Fetch comments for post
        self.fetchComments()

        // setup scroll view
        self.scrollView.pagingEnabled = false
        let screenSize = UIScreen.mainScreen().bounds.size
        let scrollHeight = self.imageView.frame.height + self.caption.frame.height
        self.scrollView.contentSize = CGSize(width: screenSize.width, height: scrollHeight+40)

        
        self.activityIndicator.hidden = false
        self.activityIndicator.startAnimating()
        
        // Check media type
        if(post.isVideo == false){
            self.navigationItem.title = "Photo"
            self.imageView.setImageWithURL(post.thumbnailURL)
            self.imageView.setImageWithURLRequest(NSURLRequest(URL: post.standardResolutionImageURL), placeholderImage: nil, success: {(request, response, image)->Void in
                self.activityIndicator.stopAnimating()
                self.activityIndicator.hidden = true
                self.imageView.image = image
                }, failure: {(request, response, error)->Void in
                    self.imageView.image = UIImage(named: "AvatarPlaceholder@2x.png")
                    println("failed to get photo")
            })
        }else {
            self.navigationItem.title = "Video"
            
            // set up a video in the same frame as imageView
//            let videoURL = self.post.lowResolutionVideoURL
            let vidURL = self.post.standardResolutionVideoURL
            // Use either MPMoviePlayer or AVPlayer (ios8 and up)
//            self.moviePlayer = MPMoviePlayerViewController(contentURL: videoURL)
//            self.moviePlayer.view.frame = self.imageView.frame
//            self.scrollView.addSubview(self.moviePlayer.view)
//            self.moviePlayer.moviePlayer.controlStyle = MPMovieControlStyle.Embedded
//            self.moviePlayer.moviePlayer.play()
            self.myplayer = AVPlayerViewController()
            self.myplayer.view.frame = self.imageView.frame
            self.myplayer.view.contentMode = UIViewContentMode.ScaleToFill
            self.scrollView.addSubview(self.myplayer.view)
            self.myplayer.player = AVPlayer(URL: vidURL)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "showUserProfile"){
            let destVC: UserProfile_ViewController = segue.destinationViewController as UserProfile_ViewController
            destVC.userInfo = self.post.user
        }else{
            let destVC: UserProfile_ViewController = segue.destinationViewController as UserProfile_ViewController
            destVC.userInfo = self.commentUser
            println("setPrepareforsegue")
        }
    }
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if identifier == "showCommentUserProfile"{
            return false
        }else{
            return true
        }
    }
    
    func timeSinceTaken() -> String{
        // Create two NSData object

        let curTime = NSDate()
        
//        println("Current time:     \(curTime)")
//        println("Time Since Taken: \(self.post.createdDate)")
        if let estDate = self.post.createdDate{
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

//            println("Y: \(year)\nM: \(month)\nW: \(weeks)\nd: \(day)\nh: \(hours)\nm: \(minutes)\nY: \(seconds)\n\n\n")
            
            if(year != 0){
                return String(abs(year)) + "Y ago"
            }else if(month != 0){
                return String(abs(month)) + "M ago"
            }else if(weeks != 0){
                return String(abs(weeks)) + "w ago"
            }else if(day != 0){
                return String(abs(day)) + "d ago"
            }else if(hours != 0){
                return String(abs(hours)) + "h ago"
            }else if(minutes != 0){
                return String(abs(minutes)) + "m ago"
            }else if(seconds != 0){
                return String(abs(seconds)) + "s ago"
            }else{
                return "just now"
            }
        }else{
            return "No time avail."
        }
    }
    
    func fetchComments(){
        self.sharedIGEngine.getCommentsOnMedia(self.post.Id, withSuccess: {(commentsArray)->Void in
            for comment in commentsArray as [InstagramComment]{
                self.comments.append(comment)
            }
            self.commentTableView.reloadData()
            }, failure: {(error)->Void in
                println("Error fetching comments")
        })
    }
}

extension LargePhoto_ViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.comments.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("commentReuseID", forIndexPath: indexPath) as Comments_TableViewCell
        
        let comment = self.comments[indexPath.row]
        cell.setComment(comment.text)
        cell.setUser(comment.user.username)
        cell.setCommentUser(comment.user)
        
        cell.selectionStyle = .None
        cell.delegate = self
        
        return cell
    }
}

extension LargePhoto_ViewController: CommentsTableViewCellDelegate{
    func didPressUserButton(instagramUser: InstagramUser!) {
        println(instagramUser.username)
        self.commentUser = instagramUser
        self.performSegueWithIdentifier("showCommentUserProfile", sender: nil)
    }
}











