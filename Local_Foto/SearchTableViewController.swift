//
//  SearchTableViewController.swift
//  Demo-iOS
//
//  Created by Constantine Fry on 30/11/14.
//  Copyright (c) 2014 Constantine Fry. All rights reserved.
//

import Foundation
import UIKit
import MapKit


protocol SearchTableViewControllerDelegate: class {
    func searchTableViewController(controller: SearchTableViewController, didSelectVenue venue:JSON)
    func searchTableViewController(controller: SearchTableViewController, viewDidDisappear venueSelected: Bool!)
}

class SearchTableViewController: UITableViewController, UISearchResultsUpdating {
    var location: CLLocation!
    var myVenues: [JSON]!
    let distanceFormatter = MKDistanceFormatter()
    weak var delegate: SearchTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()


    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        // Strip out all the leading and trailing spaces.
        let whitespaceCharacterSet = NSCharacterSet.whitespaceAndNewlineCharacterSet()
        //        let words:NSArray = searchController.searchBar.text.componentsSeparatedByCharactersInSet(whitespaceCharacterSet)
        //        let strippedString = words.componentsJoinedByString("")
        let mystr: NSString = searchController.searchBar.text as NSString
        let strippedString = mystr.stringByReplacingOccurrencesOfString("\\s", withString: "", options: .RegularExpressionSearch, range: NSMakeRange(0, mystr.length))
        
        if self.location == nil {
            return
        }
        let ll = NSString(format: "%f,%f", self.location.coordinate.latitude, self.location.coordinate.longitude)
        let limit = "20"
        let query = strippedString
        
        let client_id = "5P1OVCFK0CCVCQ5GBBCWRFGUVNX5R4WGKHL2DGJGZ32FDFKT"
        let client_secret = "UPZJO0A0XL44IHCD1KQBMAYGCZ45Z03BORJZZJXELPWHPSAR"
        
        let url = NSString(format: "https://api.foursquare.com/v2/venues/explore?limit=%@&query=%@&client_id=%@&client_secret=%@&v=20140806&m=swarm&ll=%@&sortByDistance=1", limit, query, client_id, client_secret, ll)
        
        DataManager.getDataFromInstagramWithSuccess(url, success: {(response, error)->Void in
            if (error != nil){
                println("Error occured getting data!")
                println(error)
            }else{
                if let postsArray = response["response"]["groups"][0]["items"].array{
                    self.myVenues = postsArray
                }
            self.tableView.reloadData()
            }
        
        })
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as SearchCell_TableViewCell
        let venue = myVenues[indexPath.row]["venue"]

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
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.myVenues != nil {
            return self.myVenues!.count
        }
        return 0
    }
    
    var didSelectVenue = false
    // Picked a search criteria
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.didSelectVenue = true
        self.dismissViewControllerAnimated(true, completion: nil)
        let venueInfo = myVenues[indexPath.row]["venue"]
        delegate?.searchTableViewController(self, didSelectVenue: venueInfo)
    }
    
    // Tell other VC that this view is gone -> then the other VC can perform a Segue
    override func viewDidDisappear(animated: Bool) {
        delegate?.searchTableViewController(self, viewDidDisappear: self.didSelectVenue)
        self.didSelectVenue = false
    }
    

}

extension SearchTableViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        // Send current Foursquare results for search
        searchBar.resignFirstResponder()
    }

}
