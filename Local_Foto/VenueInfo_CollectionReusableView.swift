//
//  VenueInfo_CollectionReusableView.swift
//  Local_Foto
//
//  Created by Tony on 2/26/15.
//  Copyright (c) 2015 Abbouds Corner. All rights reserved.
//

import UIKit

class VenueInfo_CollectionReusableView: UICollectionReusableView {
    
    @IBOutlet var venueName: UILabel!
    @IBOutlet var address: UILabel!
    @IBOutlet var phoneNumber: UILabel!
    @IBOutlet var hoursOfOperation: UILabel!
    
    
    func setVenueName(name: String!){
        self.venueName.text = name
    }
    func setAddress(address: String!){
        self.address.text = address
    }
    func setPhoneNumber(number: String!){
        self.phoneNumber.text = number
    }
    func setHoursOfOperation(hours: String!){
        self.hoursOfOperation.text = hours
    }
    
}
