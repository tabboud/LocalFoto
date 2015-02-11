//
//  ViewController.swift
//  Local_Foto
//
//  Created by Tony on 2/7/15.
//  Copyright (c) 2015 Abbouds Corner. All rights reserved.
//

//Leave this to strictly getting authorization. I will implement the pop up webview if needed.

import UIKit
import CoreLocation

var strAccessToken = ""
let AUTHURL        = "https://api.instagram.com/oauth/authorize/"       // Used for Oauth
let CLIENTID       = "db65495f5ece4a4aac490ccc13963c05"
let REDIRECTURL    = "http://AbboudsCorner.wordpress.com"

class ViewController: UIViewController, UIWebViewDelegate {
    let fullURL = NSString(format: "%@?client_id=%@&redirect_uri=%@&response_type=token", AUTHURL, CLIENTID, REDIRECTURL)

    
// Outlets
    @IBOutlet var myWebView: UIWebView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let accessToken = NSUserDefaults.standardUserDefaults().objectForKey("accessToken") as? String{
            println("Already have Token")
            // Set global access Token
            strAccessToken = accessToken
        }else{
            self.loadURL()
        }
//        self.getUserLocation()
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
            println("Acc Tok: \(strAccessToken)")
            
            // Store key in NSUserDefaults
            NSUserDefaults.standardUserDefaults().setObject(strAccessTok, forKey: "accessToken")
            NSUserDefaults.standardUserDefaults().synchronize()
            println("Stored key in NSUserDefaults")
            
            self.view.viewWithTag(3)?.removeFromSuperview()
            return false
        }
        
        return true
    }
    
    
}









