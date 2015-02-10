//
//  photo_CollectionViewCell.swift
//  Local_Foto
//
//  Created by Tony on 2/10/15.
//  Copyright (c) 2015 Abbouds Corner. All rights reserved.
//

import UIKit

class photo_CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    
    
    func setThumbnailImage(thumbnailImage: UIImage){
        self.imageView.image = thumbnailImage
    }
}
