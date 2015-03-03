//
//  SearchCell_TableViewCell.swift
//  Local_Foto
//
//  Created by Tony on 2/26/15.
//  Copyright (c) 2015 Abbouds Corner. All rights reserved.
//

import UIKit

class SearchCell_TableViewCell: UITableViewCell {

    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    func setTitle(title: String!){
        self.titleLabel.text = title
    }
    
    func setSubtitle(subtitle: String!){
        self.subtitleLabel.text = subtitle
    }
}
