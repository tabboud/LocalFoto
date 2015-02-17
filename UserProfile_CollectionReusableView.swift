//
//  UserProfile_CollectionReusableView.swift
//  Local_Foto
//
//  Created by Tony on 2/17/15.
//  Copyright (c) 2015 Abbouds Corner. All rights reserved.
//

import UIKit

class UserProfile_CollectionReusableView: UICollectionReusableView {
    
    @IBOutlet var fullName: UILabel!
    @IBOutlet var bio: UILabel!
    @IBOutlet var profilePicture: UIImageView!
    
    
    func setImage(strURL: String!){
        self.profilePicture.setImageWithURL(NSURL(string: strURL), placeholderImage: UIImage(named: "AvatarPlaceholder@2x.png"))
    }
    
    func setFullName(name: String!){
        self.fullName.text = name
    }
    
    func setBio(bio: String!){
        self.bio.text = bio
    }
    
}
