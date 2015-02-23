//
//  LocalPins_TableViewController.swift
//  Local_Foto
//
//  Created by Tony on 2/12/15.
//  Copyright (c) 2015 Abbouds Corner. All rights reserved.
//

//TODO: Pins are not removed and every time screen is loaded pins add to end


import UIKit
import CoreLocation

class LocalPins_TableViewController: UITableViewController {
// Local variables
    var localPins = [LocalPinsModel]()
    var curCoordinates: CLLocationCoordinate2D? = nil
    let ManagerSingleton = Manager.sharedInstance
    
// Outlets and Actions
    @IBOutlet var myTableView: UITableView!
    
    override func viewWillAppear(animated: Bool) {
        //Want to update on initial load and anytime location changes
        if let localCoord = self.curCoordinates{
            // compare local coordinates with singleton coordinates
            let tolerance = 0.005
            let lat = ManagerSingleton.currentLocation.coordinate.latitude
            let long = ManagerSingleton.currentLocation.coordinate.longitude
            if((fabs(localCoord.latitude - lat) >= tolerance) && (fabs(localCoord.longitude - long) >= tolerance)){
                self.curCoordinates = ManagerSingleton.currentLocation.coordinate
                self.updateTablePins()
            }
        }else{
            println("Coordinates are nil")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.curCoordinates = ManagerSingleton.currentLocation.coordinate
        self.updateTablePins()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateTablePins(){
        // If location is saved then
        self.localPins.removeAll(keepCapacity: false)
        self.getDataFromInstagram(self.curCoordinates?.latitude, longitude: self.curCoordinates?.longitude)
    }

// MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return localPins.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("localPinsReuseID", forIndexPath: indexPath) as UITableViewCell

        cell.textLabel?.text = localPins[indexPath.row].name

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        self.performSegueWithIdentifier("showLocalPinPhotos", sender: indexPath)
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "showLocalPinPhotos"){
            let destVC: MainScreen_ViewController = segue.destinationViewController as MainScreen_ViewController
            let indexPath: NSIndexPath = (sender as NSIndexPath)
            destVC.requestedPin = localPins[indexPath.row]
            destVC.controllerState = .Pin
        }
    }
    
    func getDataFromInstagram(latitude: CLLocationDegrees!, longitude: CLLocationDegrees!){
        let lat  = NSString(format: "%f", latitude)
        let long = NSString(format: "%f", longitude)
        
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey("accessToken") as NSString
        let requestURL = NSString(format: "https://api.instagram.com/v1/locations/search?lat=%@&lng=%@&distance=4000&access_token=%@",lat, long, accessToken)
        
        DataManager.getDataFromInstagramWithSuccess(requestURL, success: {(instagramData, error)->Void in
            if(error != nil){
                println("Some error occurred")
            }else{
                if let pinsArray = instagramData["data"].array{
                    for val in pinsArray {
                        var name        = val["name"].string
                        var id          = val["id"].string
                        var coord       = val["latitude"].double
                        var latitude    = NSString(format: "%f", val["latitude"].double!)
                        var longitude   = NSString(format: "%f", val["longitude"].double!)
                        
                        self.localPins.append(LocalPinsModel(lat: latitude, long: longitude, Name: name, ID: id))
                    }
                    dispatch_async(dispatch_get_main_queue(), {
                        self.myTableView.reloadData()
                    })
                }
            }
        })
    }
}
