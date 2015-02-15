//
//  LargePhoto_ViewController.swift
//  Local_Foto
//
//  Created by Tony on 2/10/15.
//  Copyright (c) 2015 Abbouds Corner. All rights reserved.
//

import UIKit

class LargePhoto_ViewController: UIViewController {
    var post: PostModel!
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var userName: UILabel!
    @IBOutlet var caption: UILabel!
    @IBOutlet var timeTaken: UILabel!
    @IBOutlet var scrollView: UIScrollView!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // setup scroll view
        self.scrollView.pagingEnabled = false
        let screenSize = UIScreen.mainScreen().bounds.size
        self.scrollView.contentSize = CGSize(width: screenSize.width, height: screenSize.height*1.5)
        
        
        self.imageView.setImageWithURL(NSURL(string: post.highResPhotoURL), placeholderImage: UIImage(named: "AvatarPlaceholder@2x.png"))
        self.userName.text = post.userName
        self.caption.text = post.caption
        self.navigationItem.title = post.timeTaken
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

}
