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
    func didPressCommentsButton(cellIndex: Int)
}


class Posts_TableViewCell: UITableViewCell {
    var delegate: PostsTabeViewCellDelegate? = nil
    var cellIndex: Int? = nil
    
// Actions & Outlets
    @IBOutlet var postPhoto: UIImageView!
    @IBOutlet var profilePhoto: UIImageView!
    @IBOutlet var userName: UIButton!
    @IBOutlet var likes: UILabel!
    @IBOutlet var timeTakenLabel: UILabel!
    @IBOutlet var numOfComments: UILabel!
    @IBOutlet var caption: UILabel!

    
    
    @IBAction func userBtnClicked(sender: AnyObject) {
        if let index = self.cellIndex{
            delegate?.didPressUserButton(index)
        }else{
            delegate?.didPressUserButton(0)
        }
    }
    
    @IBAction func commentsClicked(sender: AnyObject) {
        if let index = self.cellIndex{
            delegate?.didPressCommentsButton(index)
        }else{
            delegate?.didPressCommentsButton(0)
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

    func setTimeTakenLabel(time: String!){
        self.timeTakenLabel.text = time
    }
    func setNumOfComments(count: String!){
        self.numOfComments.text = count
    }
    func setCaption(caption: String!){
        self.caption.text = caption
    }
    func setUserName(name: String!){
        self.userName.setTitle(name, forState: .Normal)
    }
    func setLikeCount(likes: String!){
        self.likes.text = likes
    }
    func setUserProfilePhoto(profilePictureURL: NSURL!){
        self.profilePhoto.image = nil
        
        // Make photo circular
        self.profilePhoto.layer.cornerRadius = self.profilePhoto.frame.size.width / 2
        self.profilePhoto.clipsToBounds = true
        // Add border
        self.profilePhoto.layer.borderWidth = 2.0
        self.profilePhoto.layer.borderColor = UIColor.whiteColor().CGColor
        
        self.profilePhoto.setImageWithURLRequest(NSURLRequest(URL: profilePictureURL), placeholderImage: nil, success: {(request, response, image)->Void in
            self.profilePhoto.layer.cornerRadius = self.profilePhoto.frame.size.width/2
            dispatch_async(dispatch_get_main_queue(), {
                self.profilePhoto.image = image
            })
            }, failure: {(request, response, error)->Void in
                println("failed to get photos")
        })
    }
    func setPostPhoto(thumbnailURL: NSURL!, standardResURL: NSURL!){
        self.postPhoto.image = nil
        self.postPhoto.setImageWithURLRequest(NSURLRequest(URL: standardResURL), placeholderImage: nil, success: {(request, response, image)->Void in
                dispatch_async(dispatch_get_main_queue(), {
                    self.postPhoto.image = image
                })
//                //Add gesture recognizer to this image view
//                self.postPhoto.userInteractionEnabled = true
//                var tapGesture = UITapGestureRecognizer(target: self, action: "LikedPhoto:")
//                tapGesture.numberOfTapsRequired = 2
//                self.postPhoto.addGestureRecognizer(tapGesture)
//            
            }, failure: {(request, response, error)->Void in
                println("failed to get photo")
        })
    }
    
    private func LikedPhoto(sender: AnyObject!){
        println("Liked photo")
    }
    
}
