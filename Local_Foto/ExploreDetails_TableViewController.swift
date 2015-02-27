//
//  ExploreDetails_TableViewController.swift
//  Local_Foto
//
//  Created by Tony on 2/26/15.
//  Copyright (c) 2015 Abbouds Corner. All rights reserved.
//

//TODO: Make sure no segue goes from cell or photo, should go from VC to VC, then use if inside didselect or prepareForSegue to determine which to go to. Used along with performSegue

import UIKit
import MapKit

class ExploreDetails_TableViewController: UITableViewController {
    var venues: [JSON]!{
        didSet{
            self.navigationController?.title = self.category
            self.tableView.reloadData()
        }
    }
    var location: CLLocation!
    var category: String!
    let distanceFormatter = MKDistanceFormatter()
    var venueInfo: JSON!        //Send over to venuePhoto_collectionVC

    
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

    
/*
My Methods
*/
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
    
    // Picked a search category
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.venueInfo = venues[indexPath.row]["venue"]
        
        self.performSegueWithIdentifier("showVenueInfo", sender: self)
    }

    
    
    
// MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "showVenueInfo"){
            let destVC: venuePhoto_CollectionViewController = segue.destinationViewController as venuePhoto_CollectionViewController
            destVC.venueDetails = self.venueInfo
        }
    }


}
