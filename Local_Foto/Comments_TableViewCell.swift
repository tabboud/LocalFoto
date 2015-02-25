//
//  Comments_TableViewCell.swift
//  Local_Foto
//
//  Created by Tony on 2/22/15.
//  Copyright (c) 2015 Abbouds Corner. All rights reserved.
//

import UIKit

@objc protocol CommentsTableViewCellDelegate{
    func didPressUserButton(instagramUser: InstagramUser!)
}
class Comments_TableViewCell: UITableViewCell {
    
    var commentUser: InstagramUser!
    var delegate: CommentsTableViewCellDelegate? = nil

    @IBOutlet var commentsLabel: UILabel!
    @IBOutlet var userButton: UIButton!
    @IBAction func userBtnPressed(sender: AnyObject){     // Defined a target in LargePhoto_VC to handle button press
        if let del = self.delegate{
            del.didPressUserButton(self.commentUser)
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
    
    func setComment(comment: String!){
        self.commentsLabel.text = comment
    }
    
    func setUser(user: String!){
        self.userButton.setTitle(user + ":", forState: .Normal)
        self.userButton.sizeToFit()
    }
    
    func setCommentUser(user: InstagramUser!){
        self.commentUser = user
    }

}
