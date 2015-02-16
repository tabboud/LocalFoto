//
//  photo_CollectionViewCell.swift
//  Local_Foto
//
//  Created by Tony on 2/10/15.
//  Copyright (c) 2015 Abbouds Corner. All rights reserved.
//

import UIKit

class photo_CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var imageView: UIImageView!
    
    func setThumbnailImage(thumbnailImageURL: NSURL!){
        self.activityIndicator.hidden = false
        self.activityIndicator.startAnimating()
        self.imageView.setImageWithURLRequest(NSURLRequest(URL: thumbnailImageURL), placeholderImage: nil, success: {(request, response, image)->Void in
            self.activityIndicator.stopAnimating()
            self.activityIndicator.hidden = true
            self.imageView.image = image
            }, failure: {(request, response, error)->Void in
                self.imageView.image = UIImage(named: "AvatarPlaceholder@2x.png")
                println("failed to get photos")
        })
    }
}

