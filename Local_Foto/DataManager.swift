//
//  DataManager.swift
//  Local_Foto
//
//  Created by Tony on 2/15/15.
//  Copyright (c) 2015 Abbouds Corner. All rights reserved.
//

import Foundation

@objc protocol DataManagerDelegate{
    optional func dataManager(client: DataManager!, didUpdateInfo info:AnyObject!)
    optional func dataManager(client: DataManager!, didFailWithError error: AnyObject!)
}

class DataManager: AFHTTPSessionManager {
    
    class func getDataFromInstagramWithSuccess(URL: String!, success: ((instagramData: JSON!, error: NSError!) -> Void)){
        let url = NSURL(string: URL)
        let request = NSURLRequest(URL: url!)
        
        let operation = AFHTTPRequestOperation(request: request)
        operation.responseSerializer = AFJSONResponseSerializer()
        operation.setCompletionBlockWithSuccess({(operation, responseObject: AnyObject!)-> Void in
                let json = JSON(responseObject)
                success(instagramData: json, error: nil)
            },
            failure: {(operation, error)->Void in
                success(instagramData: nil, error: error)
                println("Cannot get data from Instagram!")

        })
        operation.start()
        
        
        // Found in AFNetworking with Ray Wenderlich -> Using AFHTTPSessionManager (based on NSURLSession targets ios7+)
//        let baseURL = NSURL(string: URL)
//        let parameters = ["format":"json"]
//        
//        let manager = AFHTTPSessionManager(baseURL: baseURL)
//        manager.responseSerializer = AFJSONResponseSerializer()
        
    }
    
    class func cancelCurrentHTTPOperation(){

    }
    
}