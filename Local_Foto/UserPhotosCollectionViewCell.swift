//
//  UserPhotosCollectionViewCell.swift
//  Local_Foto
//
//  Created by Tony on 2/15/15.
//  Copyright (c) 2015 Abbouds Corner. All rights reserved.
//

import UIKit

class UserPhotosCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    
    func setThumbnailImage(thumbnailImageURL: NSURL!){
        self.imageView.image = nil

        self.imageView.setImageWithURLRequest(NSURLRequest(URL: thumbnailImageURL), placeholderImage: nil, success: {(request, response, image)->Void in
            self.imageView.contentMode = UIViewContentMode.ScaleToFill
            dispatch_async(dispatch_get_main_queue(), {
                self.imageView.image = image
            })
            }, failure: {(request, response, error)->Void in
                self.imageView.image = UIImage(named: "AvatarPlaceholder@2x.png")
                println("failed to get photos - user photos collection view cell")
        })

    }
    
}
