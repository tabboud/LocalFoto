//
//  LocalPinsModel.swift
//  Local_Foto
//
//  Created by Tony on 2/12/15.
//  Copyright (c) 2015 Abbouds Corner. All rights reserved.
//

import UIKit

class LocalPinsModel: NSObject, Printable {
    let latitude: String
    let longitude: String
    let name: String
    let id: String
    
    init(lat: String?, long: String?, Name: String?, ID: String?){
        self.latitude = lat ?? ""
        self.longitude = long ?? ""
        self.name = Name ?? ""
        self.id = ID ?? ""
    }
    
    override var description: String {
        return "Name: \(name)\nLat: \(latitude)\nLong: \(longitude)\nID: \(id)"
    }
}
