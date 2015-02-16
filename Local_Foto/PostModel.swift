//
//  PostModel.swift
//  Local_Foto
//
//  Created by Tony on 2/9/15.
//  Copyright (c) 2015 Abbouds Corner. All rights reserved.
//

import Foundation
import UIKit


class PostModel: NSObject, Printable {
    let userName: String
    let fullName: String
    let thumbnailPhotoURL: String
    let highResPhotoURL: String
    let caption: String
    let timeTaken: String
    let userId: String
    let profilePictureURL: String

    
    override var description: String {
        return "User Name: \(userName), Full Name: \(fullName), URL: \(thumbnailPhotoURL)\n"
    }
    
    init(userName: String?, fullName: String?, thumbPhotoURL: String?, highPhotoURL: String?, caption: String?, timeTaken: String?, ID: String?, profilePic: String?) {
        self.userName = userName ?? ""
        self.fullName = fullName ?? ""
        self.thumbnailPhotoURL = thumbPhotoURL ?? ""
        self.highResPhotoURL = highPhotoURL ?? ""
        self.caption = caption ?? ""
        self.timeTaken = timeTaken ?? ""
        self.userId = ID ?? ""
        self.profilePictureURL = profilePic ?? ""
    }
}