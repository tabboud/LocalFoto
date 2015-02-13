//
//  LocalPinPhotos_ViewController.swift
//  Local_Foto
//
//  Created by Tony on 2/12/15.
//  Copyright (c) 2015 Abbouds Corner. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class LocalPinPhotos_ViewController: UIViewController {
//Local Variables
    var requestedPin: LocalPinsModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        println("viewDidLoad")

        // We have coordinates for map, and location id for photo request
        // getDataFromIG
        // getDataFromInstagram
        let photosURL = NSString(format: "https://api.instagram.com/v1/locations/%@/media/recent?access_token=%@", requestedPin.id, strAccessToken)

        let url = NSURL(string: photosURL)
        let request = NSURLRequest(URL: url!)
        
        let operation: AFHTTPRequestOperation = AFHTTPRequestOperation(request: request)
        operation.responseSerializer = AFJSONResponseSerializer()
        operation.setCompletionBlockWithSuccess({(operation, responseObject: AnyObject!)-> Void in
            println("JSON received from IG")
            
            let json = JSON(responseObject)
            
            if let pinsArray = json["data"].array{
                for val in pinsArray {
                    var name = val["user"]["username"].string
                    var caption = val["caption"]["text"].string
                    var location = val["location"]["name"].string

                    println("\(name)\n\(caption)\n\(location)")
                }

            }else{
                println("No photos at this location")
            }
            
            }, failure: {(operation, error)->Void in
                println("Some error occured in AFNEtworking: \(error)")
        })
        
        operation.start()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
