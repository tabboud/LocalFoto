//
//  FirstViewController.swift
//  Demo-iOS
//
//  Created by Constantine Fry on 08/11/14.
//  Copyright (c) 2014 Constantine Fry. All rights reserved.
//

import UIKit

/** Shows result from `explore` endpoint. And has search controller to search in nearby venues. */
class ExploreViewController: UITableViewController, SearchTableViewControllerDelegate {
    
    private enum exploreSections: String{
        case Food = "Food"
        case Drinks = "Drinks"
        case Coffee = "Coffee"
        case Shops = "Shops"
        case Arts = "Arts"
        case Outdoors = "Outdoor Sights"
        case Trending = "Trending"
        case Specials = "Specials"
        case TopPicks = "Top Picks"
        
        static let allValues = [Food, Drinks, Coffee, Shops, Arts, Outdoors, Trending, Specials, TopPicks]
        static let count = allValues.count
    }
    
    
    var media = [InstagramMedia]()
    var category: String!
    
    @IBAction private func btnPressed(sender: AnyObject!){
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showCollection"{
            let dVC = segue.destinationViewController as venuePhoto_CollectionViewController
            dVC.media = self.media
            dVC.venueDetails = self.venueInfo
        }else if(segue.identifier == "showExploreDetails"){
            let destVC = segue.destinationViewController as ExploreDetails_TableViewController
            destVC.category = self.category
        }
    }
    
    var searchController: UISearchController!
    var resultsTableViewController: SearchTableViewController!
    let ManagerSingleton = Manager.sharedInstance
    let sharedIGEngine = InstagramEngine.sharedEngine()
    
    /** Number formatter for rating. */
    let numberFormatter = NSNumberFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        numberFormatter.numberStyle = .DecimalStyle
        
        resultsTableViewController = Storyboard.create("venueSearch") as SearchTableViewController
        resultsTableViewController.delegate = self
        resultsTableViewController.location = ManagerSingleton.currentLocation
        searchController = UISearchController(searchResultsController: resultsTableViewController)
        searchController.searchResultsUpdater = resultsTableViewController
        searchController.searchBar.sizeToFit()
        tableView.tableHeaderView = searchController.searchBar
        definesPresentationContext = true
        
    }
    
    
    func showNoPermissionsAlert() {
        let alertController = UIAlertController(title: "No permission", message: "In order to work, app needs your location", preferredStyle: .Alert)
        let openSettings = UIAlertAction(title: "Open settings", style: .Default, handler: {
            (action) -> Void in
            let URL = NSURL(string: UIApplicationOpenSettingsURLString)
            UIApplication.sharedApplication().openURL(URL!)
            self.dismissViewControllerAnimated(true, completion: nil)
        })
        alertController.addAction(openSettings)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func showErrorAlert(error: NSError) {
        let alertController = UIAlertController(title: "Error", message:error.localizedDescription, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "Ok", style: .Default, handler: {
            (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        })
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exploreSections.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: ExploreCell_TableViewCell = tableView.dequeueReusableCellWithIdentifier("exploreTableViewCell", forIndexPath: indexPath) as ExploreCell_TableViewCell
        
        let section: exploreSections = exploreSections.allValues[indexPath.row]
        let category = section.rawValue
        
        cell.setCategoryName(category)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as ExploreCell_TableViewCell
        self.category = cell.categoryName.text
        self.performSegueWithIdentifier("showExploreDetails", sender: self)
    }
    
    
    var venueInfo: JSON!
    
    // Search Delegate
    func searchTableViewController(controller: SearchTableViewController, didSelectVenue venue:JSON) {

        self.venueInfo = venue
        let venueID = venue["id"].string

        resultsTableViewController.dismissViewControllerAnimated(true, completion: nil)

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
                    
                }
            }
        })
    }

}


class Storyboard: UIStoryboard {
    class func create(name: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(name) as UIViewController
    }
}

