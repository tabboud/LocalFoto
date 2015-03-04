//
//  UserProfile_CollectionReusableView.swift
//  Local_Foto
//
//  Created by Tony on 2/17/15.
//  Copyright (c) 2015 Abbouds Corner. All rights reserved.
//

import UIKit

class UserProfile_CollectionReusableView: UICollectionReusableView {
    
    @IBOutlet var posts: UILabel!
    @IBOutlet var bio: UILabel!
    @IBOutlet var profilePicture: UIImageView!
    @IBOutlet var followersCount: UILabel!
    @IBOutlet var followingCount: UILabel!
    
    @IBOutlet var btnFollow: UIButton!
    
    func setImage(URL: NSURL!){
        // Make photo circular
        self.profilePicture.layer.cornerRadius = self.profilePicture.frame.size.width / 2
        self.profilePicture.clipsToBounds = true
        // Add border
        self.profilePicture.layer.borderWidth = 2.0
        self.profilePicture.layer.borderColor = UIColor.whiteColor().CGColor
        
        profilePicture.setImageWithURLRequest(NSURLRequest(URL: URL), placeholderImage: nil, success: {(request, response, image)->Void in
            dispatch_async(dispatch_get_main_queue(), {
                self.profilePicture.image = image
            })
            }, failure: {(request, response, error)->Void in
                println("failed to get photos - user profile collection reusable view")
        })
    }
    
 
    func setPostCount(postCount: String!){
        self.posts.text = postCount
    }
    func setFollowersCount(followersCnt: String!){
        self.followersCount.text = followersCnt
    }
    func setFollowingCount(followingCnt: String!){
        self.followingCount.text = followingCnt
    }
    
    func setBio(bio: String!){
        self.bio.text = bio
    }
    
    func setFollowButton(label: String!){
        self.btnFollow.setTitle(label, forState: .Normal)
        if(label == "Follow"){
            self.btnFollow.backgroundColor = UIColor.redColor()
        }else{
            self.btnFollow.backgroundColor = UIColor.purpleColor()
        }
    }
    
}
