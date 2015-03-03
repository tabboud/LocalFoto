//
//  Comments_TableViewCell.swift
//  Local_Foto
//
//  Created by Tony on 2/22/15.
//  Copyright (c) 2015 Abbouds Corner. All rights reserved.
//

import UIKit

@objc protocol CommentsTableViewCellDelegate{
    optional func didPressUserButton(instagramUser: InstagramUser!)
}
class Comments_TableViewCell: UITableViewCell {
    
    var delegate: CommentsTableViewCellDelegate? = nil

    @IBOutlet var userProfilePhoto: UIImageView!
    @IBOutlet var commentTime: UILabel!
    @IBOutlet var commentLabel: UILabel!
    @IBOutlet var userNameBtn: UIButton!
    @IBAction func pressedUserName(sender: AnyObject) {
    }


    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setComment(comment: String!){
        self.commentLabel.text = comment
    }
    
    func setUserName(user: String!){
        self.userNameBtn.setTitle(user, forState: .Normal)
        self.userNameBtn.sizeToFit()
    }

    func setCommentTime(time: String!){
        self.commentTime.text = time
    }
    
    func setProfilePhoto(URL: NSURL!){
        // Make photo circular
        self.userProfilePhoto.layer.cornerRadius = self.userProfilePhoto.frame.size.width / 2
        self.userProfilePhoto.clipsToBounds = true
        // Add border
        self.userProfilePhoto.layer.borderWidth = 2.0
        self.userProfilePhoto.layer.borderColor = UIColor.whiteColor().CGColor
        
        self.userProfilePhoto.setImageWithURL(URL)
    }

}
