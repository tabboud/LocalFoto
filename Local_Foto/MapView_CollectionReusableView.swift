//
//  MapView_CollectionReusableView.swift
//  Local_Foto
//
//  Created by Tony on 2/17/15.
//  Copyright (c) 2015 Abbouds Corner. All rights reserved.
//

import UIKit
import MapKit

class MapView_CollectionReusableView: UICollectionReusableView {
 
    
    @IBOutlet var map: MKMapView!
    
    func setRegion(region: MKCoordinateRegion!){
        self.map.setRegion(region, animated: true)
    }
    
    func addAnnotation(annotation: MKAnnotation!){
        self.map.addAnnotation(annotation)
    }
    
}
