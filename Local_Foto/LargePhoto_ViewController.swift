//
//  LargePhoto_ViewController.swift
//  Local_Foto
//
//  Created by Tony on 2/10/15.
//  Copyright (c) 2015 Abbouds Corner. All rights reserved.
//

//TODO: add date taken by time (i.e. 3h ago, 2w ago, etc)

import UIKit

class LargePhoto_ViewController: UIViewController {
    var post: PostModel!
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var caption: UILabel!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var userNameBtn: UIButton!
    @IBOutlet var timeSincePosted: UILabel!
    @IBOutlet var profilePicture: UIImageView!

    
    override func viewWillAppear(animated: Bool) {
        // setup scroll view
        self.scrollView.pagingEnabled = false
//        let screenSize = UIScreen.mainScreen().bounds.size
//        let scrollHeight = self.imageView.frame.height + self.caption.frame.height
//        
//        self.scrollView.contentSize = CGSize(width: screenSize.width, height: scrollHeight)
        
        
        self.imageView.setImageWithURL(NSURL(string: post.highResPhotoURL), placeholderImage: UIImage(named: "AvatarPlaceholder@2x.png"))
        self.userNameBtn.titleLabel?.text = post.userName
        self.caption.text = post.caption
        self.timeSincePosted.text = self.timeSinceTaken()
        self.profilePicture.setImageWithURL(NSURL(string: self.post.profilePictureURL))
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Photo"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "showUserProfile"){
            let destVC: UserProfile_ViewController = segue.destinationViewController as UserProfile_ViewController
            destVC.userInfo = post
        }
    }
    
    func timeSinceTaken() -> String{
        // Create two NSData object

        let curTime = NSDate()
        
        //Make new string for date
        let startIndex = self.post.timeTaken.startIndex
        let photoTimeTaken = self.post.timeTaken.substringToIndex(advance(startIndex, 20))
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        dateFormatter.timeZone = NSTimeZone(abbreviation: "EST")
        if let estDate = dateFormatter.dateFromString(photoTimeTaken){
            // subtract two dates
            let c = NSCalendar.currentCalendar()
            let calendarFlags: NSCalendarUnit = .HourCalendarUnit | .MinuteCalendarUnit | .SecondCalendarUnit | .DayCalendarUnit | .MonthCalendarUnit | .YearCalendarUnit | .WeekOfYearCalendarUnit
            let components:NSDateComponents = c.components(calendarFlags, fromDate: curTime, toDate: estDate, options: nil)
            
            let year = components.year
            let weeks = components.weekOfYear
            let day = components.day
            let hours = components.hour
            let minutes = components.minute
            let seconds = components.second
            
            if(year != 0){
                return String(abs(year)) + "Y ago"
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
    

}
