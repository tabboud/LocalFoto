//
//  DataManager.swift
//  Local_Foto
//
//  Created by Tony on 2/15/15.
//  Copyright (c) 2015 Abbouds Corner. All rights reserved.
//

import Foundation


class DataManager {
    
    class func getDataFromInstagramWithSuccess(URL: String!, success: ((instagramData: JSON!, error: NSError!) -> Void)){
        let url = NSURL(string: URL)
        let request = NSURLRequest(URL: url!)
        
        let operation: AFHTTPRequestOperation = AFHTTPRequestOperation(request: request)
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
    }
    
}