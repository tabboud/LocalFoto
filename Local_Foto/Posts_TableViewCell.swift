//
//  Posts_TableViewCell.swift
//  Local_Foto
//
//  Created by Tony on 2/25/15.
//  Copyright (c) 2015 Abbouds Corner. All rights reserved.
//

import UIKit

@objc protocol PostsTabeViewCellDelegate{
    func didPressUserButton(cellIndex: Int)
}


class Posts_TableViewCell: UITableViewCell {
    var delegate: PostsTabeViewCellDelegate? = nil
    var cellIndex: Int? = nil
    
// Actions & Outlets
    @IBOutlet var postPhoto: UIImageView!
    @IBOutlet var profilePhoto: UIImageView!
    @IBOutlet var userName: UIButton!

    @IBAction func userBtnClicked(sender: AnyObject) {
        if let index = self.cellIndex{
            delegate?.didPressUserButton(index)
        }else{
            delegate?.didPressUserButton(0)
        }
    }
    

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
