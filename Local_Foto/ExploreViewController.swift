//
//  FirstViewController.swift
//  Demo-iOS
//
//  Created by Constantine Fry on 08/11/14.
//  Copyright (c) 2014 Constantine Fry. All rights reserved.
//

import UIKit

/** Shows result from `explore` endpoint. And has search controller to search in nearby venues. */
class ExploreViewController: UITableViewController, SearchTableViewControllerDelegate, UISearchBarDelegate {
    
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
    
    
    var category: String!
    var venueInfo: JSON!
    var searchController: UISearchController!
    var resultsTableViewController: SearchTableViewController!
    let ManagerSingleton = Manager.sharedInstance
    let sharedIGEngine = InstagramEngine.sharedEngine()
    
    
    @IBAction private func btnPressed(sender: AnyObject!){
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showCollection"{
            let dVC = segue.destinationViewController as venuePhoto_CollectionViewController
            dVC.venueDetails = self.venueInfo
        }else if(segue.identifier == "showExploreDetails"){
            let destVC = segue.destinationViewController as ExploreDetails_TableViewController
            destVC.category = self.category
        }
    }

    
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
        searchController.searchBar.delegate = resultsTableViewController
        tableView.tableHeaderView = searchController.searchBar
        self.definesPresentationContext = true
        
    }
    
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        println("Sections count = \(exploreSections.count)")
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
    
    

    
    // Search Delegate
    func searchTableViewController(controller: SearchTableViewController, didSelectVenue venue:JSON) {
        self.venueInfo = venue
    }
    // perform segue now that search has finished dismissing
    func searchTableViewController(controller: SearchTableViewController, viewDidDisappear venueSelected: Bool!) {
        if(venueSelected == true){
            self.performSegueWithIdentifier("showCollection", sender: self)
        }
    }

}


class Storyboard: UIStoryboard {
    class func create(name: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(name) as UIViewController
    }
}

