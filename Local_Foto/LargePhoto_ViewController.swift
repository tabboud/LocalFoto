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
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var caption: UILabel!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var userNameBtn: UIButton!
    @IBOutlet var timeSincePosted: UILabel!
    @IBOutlet var profilePicture: UIImageView!
    @IBOutlet var likesLabel: UILabel!

    @IBAction func tappedToLike(sender: AnyObject) {
        println("Like this photo")
self.likesLabel.text = NSString(format: "%d likes", self.post.likesCount+1)
//        self.sharedIGEngine.likeMedia(self.post.Id, withSuccess: {
//                println("Successfully liked media")
//                self.likesLabel.text = NSString(format: "%d likes", self.post.likesCount+1)
//            }, failure: {(error)->Void in
//            println("Error Liking media")
//        })
    }



    override func viewWillAppear(animated: Bool) {
        self.userNameBtn.setTitle(post.user.username, forState: UIControlState.Normal)
        self.caption.text = post.caption.text
        self.timeSincePosted.text = self.timeSinceTaken()
        self.profilePicture.setImageWithURL(self.post.user.profilePictureURL)
        self.likesLabel.text = NSString(format: "%d likes", self.post.likesCount)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Make photo circular
        self.profilePicture.layer.cornerRadius = self.profilePicture.frame.size.width / 2
        self.profilePicture.clipsToBounds = true
        // Add border
        self.profilePicture.layer.borderWidth = 2.0
        self.profilePicture.layer.borderColor = UIColor.whiteColor().CGColor
        
        // setup scroll view
        self.scrollView.pagingEnabled = false
        let screenSize = UIScreen.mainScreen().bounds.size
        let scrollHeight = self.imageView.frame.height + self.caption.frame.height
        self.scrollView.contentSize = CGSize(width: screenSize.width, height: scrollHeight+40)

        

        
        // Check media type
        if(post.isVideo == false){
            self.navigationItem.title = "PHOTO"
            self.imageView.setImageWithURL(post.thumbnailURL)
            self.imageView.setImageWithURLRequest(NSURLRequest(URL: post.standardResolutionImageURL), placeholderImage: nil, success: {(request, response, image)->Void in

                self.imageView.image = image
                }, failure: {(request, response, error)->Void in
                    self.imageView.image = UIImage(named: "AvatarPlaceholder@2x.png")
                    println("failed to get photo")
            })
        }else {
            self.navigationItem.title = "VIDEO"
            
            // set up a video in the same frame as imageView
            let vidURL = self.post.standardResolutionVideoURL
            // Use either MPMoviePlayer or AVPlayer (ios8 and up)
            self.moviePlayer = MPMoviePlayerViewController(contentURL: vidURL)
            self.moviePlayer.view.frame = self.imageView.frame
            self.moviePlayer.moviePlayer.controlStyle = MPMovieControlStyle.Embedded
            self.scrollView.addSubview(self.moviePlayer.view)
            self.moviePlayer.moviePlayer.play()
//            self.myplayer = AVPlayerViewController()
//            self.myplayer.view.frame = self.imageView.frame
//            self.myplayer.view.contentMode = UIViewContentMode.ScaleToFill
//            self.scrollView.addSubview(self.myplayer.view)
//            self.myplayer.player = AVPlayer(URL: vidURL)
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
        }else if (segue.identifier == "showCommentUserProfile"){
            let destVC: UserProfile_ViewController = segue.destinationViewController as UserProfile_ViewController
            destVC.userInfo = self.commentUser
            println("setPrepareforsegue")
        }
    }

    
    func timeSinceTaken() -> String{
        // Create two NSDate objects

        let curTime = NSDate()
        
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


extension LargePhoto_ViewController: CommentsTableViewCellDelegate{
    func didPressUserButton(instagramUser: InstagramUser!) {
        println(instagramUser.username)
        self.commentUser = instagramUser
        self.performSegueWithIdentifier("showCommentUserProfile", sender: nil)
    }
}











