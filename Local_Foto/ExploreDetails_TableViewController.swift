//
//  ExploreDetails_TableViewController.swift
//  Local_Foto
//
//  Created by Tony on 2/26/15.
//  Copyright (c) 2015 Abbouds Corner. All rights reserved.
//

import UIKit
import MapKit

class ExploreDetails_TableViewController: UITableViewController {
    var venues: [JSON]!{
        didSet{
            self.tableView.reloadData()
        }
    }
    var location: CLLocation!
    var category: String!
    let distanceFormatter = MKDistanceFormatter()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.location = self.getCurrentLocation()
        // Fetch Foursquare Data
        self.fetchVenueInfo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getCurrentLocation()->CLLocation{
        let manager = Manager.sharedInstance
        return manager.currentLocation
    }
    
    func fetchVenueInfo(){
        var section = ""
        if self.category != nil{
            section = self.category
            // Strip white space
            let whitespaceCharacterSet = NSCharacterSet.whitespaceAndNewlineCharacterSet()
            let words: NSArray = self.category.componentsSeparatedByCharactersInSet(whitespaceCharacterSet)
            section = words.componentsJoinedByString("")
        }
        println("Section: \(section)")
        
        let ll = NSString(format: "%f,%f", self.location.coordinate.latitude, self.location.coordinate.longitude)
        let limit = "20"
        
        let client_id = "5P1OVCFK0CCVCQ5GBBCWRFGUVNX5R4WGKHL2DGJGZ32FDFKT"
        let client_secret = "UPZJO0A0XL44IHCD1KQBMAYGCZ45Z03BORJZZJXELPWHPSAR"
        
        let url = NSString(format: "https://api.foursquare.com/v2/venues/explore?limit=%@&section=%@&client_id=%@&client_secret=%@&v=20140806&m=swarm&ll=%@&sortByDistance=0", limit, section, client_id, client_secret, ll)
        
        DataManager.getDataFromInstagramWithSuccess(url, success: {(response, error)->Void in
            if (error != nil){
                println("Error occured getting data!")
                println(error)
            }else{
                if let postsArray = response["response"]["groups"][0]["items"].array{
                    self.venues = postsArray
                }
            }
            
        })

    }
    
// MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.venues != nil{
            return self.venues.count
        }
        return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as SearchCell_TableViewCell
        let venue = venues[indexPath.row]["venue"]
        
        let venueLocation = venue["location"]
        var detailText = ""
        if let distance = venueLocation["distance"].double{
            detailText = distanceFormatter.stringFromDistance(CLLocationDistance(distance))
        }
        if let address = venueLocation["address"].string{
            detailText = detailText + " - " + address
        }
        
        cell.setSubtitle(detailText)
        cell.setTitle(venue["name"].string)
        
        return cell
    }
    
    var venueInfo: JSON!        //Send over to venuePhoto_collectionVC
    let sharedIGEngine = InstagramEngine.sharedEngine()
    var media = [InstagramMedia]()
    
    // Picked a search criteria
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.venueInfo = venues[indexPath.row]["venue"]
        
        let venueID = venueInfo["id"].string
        
        // call instagram to get locationID, then get the recent media at that location
        getLocationID(venueID)
    }
    
    
    func getLocationID(locationID: String!){
        
        
        let url = NSString(format: "https://api.instagram.com/v1/locations/search?foursquare_v2_id=%@&access_token=%@", locationID, sharedIGEngine.accessToken)
        DataManager.getDataFromInstagramWithSuccess(url, success: {(data, error)->Void in
            if error != nil{
                println("Error getting location details")
            }else{
                // fetch pins about this location
                if let dataArray = data["data"].array{
                    let LocationID = dataArray[0]["id"].string
                    
                    // fetch recent media at this location
                    self.fetchRecentMedia(LocationID)
                }
            }
        })
    }
    
    func fetchRecentMedia(locationID: String!){
        
        let url = NSString(format: "https://api.instagram.com/v1/locations/%@/media/recent?access_token=%@", locationID, sharedIGEngine.accessToken)
        DataManager.getDataFromInstagramWithSuccess(url, success: {(data, error)->Void in
            if error != nil{
                println("Error getting location details")
            }else{
                // fetch pins about this location
                if let dataArray = data["data"].array{
                    self.media.removeAll(keepCapacity: false)
                    for post in dataArray{
                        let mediaPost: InstagramMedia = InstagramMedia(info: post.dictionaryObject)
                        println(mediaPost.user.username)
                        self.media.append(mediaPost)
                    }
                    // perform the segue
                    dispatch_async(dispatch_get_main_queue(), {
                        self.performSegueWithIdentifier("showVenueInfo", sender: self)
                    })
                }
            }
        })
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */


// MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "showVenueInfo"){
            let destVC: venuePhoto_CollectionViewController = segue.destinationViewController as venuePhoto_CollectionViewController
            destVC.media = self.media
            destVC.venueDetails = self.venueInfo
            
        }
    }


}
