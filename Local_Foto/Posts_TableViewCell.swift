//
//  Posts_TableViewCell.swift
//  Local_Foto
//
//  Created by Tony on 2/25/15.
//  Copyright (c) 2015 Abbouds Corner. All rights reserved.
//

import UIKit

class Posts_TableViewCell: UITableViewCell {

// Actions & Outlets
    @IBOutlet var postPhoto: UIImageView!
    @IBOutlet var profilePhoto: UIImageView!
    @IBOutlet var userName: UIButton!

    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }


    func setUserName(name: String!){
        self.userName.setTitle(name, forState: .Normal)
    }

    func setUserProfilePhoto(profilePictureURL: NSURL!){
        self.profilePhoto.setImageWithURL(profilePictureURL)
    }
    
    func setPostPhoto(thumbnailURL: NSURL!, standardResURL: NSURL!){
        self.postPhoto.setImageWithURL(thumbnailURL)
        self.postPhoto.setImageWithURLRequest(NSURLRequest(URL: standardResURL), placeholderImage: nil, success: {(request, response, image)->Void in
            self.postPhoto.image = image
            }, failure: {(request, response, error)->Void in
                self.postPhoto.image = UIImage(named: "AvatarPlaceholder@2x.png")
                println("failed to get photo")
        })
    }

}
