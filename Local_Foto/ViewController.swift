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


class ViewController: UIViewController, UIWebViewDelegate {
    var scope: IKLoginScope!
    
    @IBOutlet var myWebView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myWebView.autoresizingMask = .FlexibleHeight | .FlexibleWidth
        myWebView.scrollView.bounces = false
        myWebView.contentMode = .ScaleAspectFit
        myWebView.delegate = self
        
        self.scope = IKLoginScope.Relationships | .Comments | .Likes
        
        let configuration   = InstagramEngine.sharedEngineConfiguration()
        let urlConfigKey    = configuration[kInstagramKitAuthorizationUrlConfigurationKey] as String
        let clientId        = configuration[kInstagramKitAppClientIdConfigurationKey] as String
        let redirectURL     = configuration[kInstagramKitAppRedirectUrlConfigurationKey] as String
        let scopeString     = InstagramEngine.stringForScope(self.scope)
        
        let urlString = NSString(format: "%@?client_id=%@&redirect_uri=%@&response_type=token&scope=%@", urlConfigKey, clientId, redirectURL, scopeString)
        if let url = NSURL(string: urlString){
            let requestObj: NSURLRequest = NSURLRequest(URL: url)
            myWebView.loadRequest(requestObj)
        }else{
            println("Error making url object")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // UIWebView - Delegate method
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool{
        var urlString:NSString = request.URL.absoluteString!
        
        if(urlString.containsString("#access_token=")){
            let accessTok: NSRange = urlString.rangeOfString("#access_token=")
            let strAccessTok: String = urlString.substringFromIndex(NSMaxRange(accessTok))
            
            // Save access token in UserDefaults
            NSUserDefaults.standardUserDefaults().setObject(strAccessTok, forKey: "accessToken")
            NSUserDefaults.standardUserDefaults().synchronize()
            
            
            
            InstagramEngine.sharedEngine().accessToken = strAccessTok
            var appdelTemp = UIApplication.sharedApplication().delegate as AppDelegate
            appdelTemp.window?.rootViewController = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateInitialViewController() as? UIViewController
            
            self.dismissViewControllerAnimated(true, completion: nil)

            return false
        }
        return true
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        println("Error occured loading webView")
    }
    
    
}









