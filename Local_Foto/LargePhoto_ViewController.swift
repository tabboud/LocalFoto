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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.imageView.image = post.getStandardResPhoto()
        self.userName.text = post.userName
        self.caption.text = post.caption
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

}
