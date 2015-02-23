//
//  Comments_TableViewCell.swift
//  Local_Foto
//
//  Created by Tony on 2/22/15.
//  Copyright (c) 2015 Abbouds Corner. All rights reserved.
//

import UIKit

class Comments_TableViewCell: UITableViewCell {


    @IBOutlet var commentsLabel: UILabel!
    
    
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

}
