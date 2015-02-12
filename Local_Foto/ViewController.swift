//
//  ViewController.swift
//  Local_Foto
//
//  Created by Tony on 2/7/15.
//  Copyright (c) 2015 Abbouds Corner. All rights reserved.
//

//Leave this to strictly getting authorization. I will implement the pop up webview if needed.
//!!Protocol tutorial: http://sledgedev.com/create-custom-delegate-and-protocol-ios-swift-objective-c/#comment-232

import UIKit
import CoreLocation

var strAccessToken = ""
let AUTHURL        = "https://api.instagram.com/oauth/authorize/"       // Used for Oauth
let CLIENTID       = "db65495f5ece4a4aac490ccc13963c05"
let REDIRECTURL    = "http://AbboudsCorner.wordpress.com"

// Set up ViewControllerDelegate protocol with access token received method, Made optional so it does not have to be implemented
@objc protocol ViewControllerDelegate{
    func accessTokenReceived()
}

class ViewController: UIViewController, UIWebViewDelegate {
    let fullURL = NSString(format: "%@?client_id=%@&redirect_uri=%@&response_type=token", AUTHURL, CLIENTID, REDIRECTURL)
    var delegate: ViewControllerDelegate? = nil
    
// Outlets
    @IBOutlet var myWebView: UIWebView!
    @IBAction func cancelBtn(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadURL()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadURL(){
        let url: NSURL = NSURL(string: fullURL)!
        let requestObj: NSURLRequest = NSURLRequest(URL: url)
        self.myWebView.loadRequest(requestObj)
        self.myWebView.delegate = self
        self.view.addSubview(myWebView)
    }
    
    // UIWebView - Delegate method
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool{
        var urlString:NSString = request.URL.absoluteString!
        println("URL String : \(urlString)")
        
        if(urlString.containsString("#access_token=")){
            let accessTok: NSRange = urlString.rangeOfString("#access_token=")
            let strAccessTok: String = urlString.substringFromIndex(NSMaxRange(accessTok))
            
            // Access token is stored in strAccessTok
            strAccessToken = strAccessTok
            
            // Store key in NSUserDefaults
            NSUserDefaults.standardUserDefaults().setObject(strAccessTok, forKey: "accessToken")
            NSUserDefaults.standardUserDefaults().synchronize()
            println("Stored key in NSUserDefaults")
//            self.dismissViewControllerAnimated(true, completion: nil)

            // Delegate method called, implemented on MainScreen_ViewController
            if let del = delegate{
                del.accessTokenReceived()
//                self.dismissViewControllerAnimated(true, completion: nil)
            }else{
                println("delegate is nil")
            }
            return false
        }
        return true
    }
    
    
}









