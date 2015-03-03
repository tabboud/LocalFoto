//
//  ExploreCell_TableViewCell.swift
//  Local_Foto
//
//  Created by Tony on 2/26/15.
//  Copyright (c) 2015 Abbouds Corner. All rights reserved.
//

import UIKit

class ExploreCell_TableViewCell: UITableViewCell {

    @IBOutlet var categoryPhoto: UIImageView!
    @IBOutlet var categoryName: UILabel!
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func setCategoryPhoto(imageName: String!){
        self.categoryPhoto.contentMode = UIViewContentMode.ScaleAspectFit
        self.categoryPhoto.image = UIImage(named: imageName)
    }
    
    func setCategoryName(name: String!){
        self.categoryName.text = name
    }

}
