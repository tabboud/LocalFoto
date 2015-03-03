//
//  venuePhoto_CollectionViewCell.swift
//  Local_Foto
//
//  Created by Tony on 2/26/15.
//  Copyright (c) 2015 Abbouds Corner. All rights reserved.
//

import UIKit

class venuePhoto_CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var photo: UIImageView!
    
    func setPhoto(url: NSURL!){
        self.photo.image = nil
        self.photo.setImageWithURL(url)
    }
}
