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
    
    func setRegion(coordinate: CLLocationCoordinate2D!){
        let center = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        self.map.setRegion(region, animated: true)
    }
    
    func addAnnotation(coordinate: CLLocationCoordinate2D!, title: String!){
        self.removeAllAnnotations()
        
        let point = MKPointAnnotation()
        point.coordinate = coordinate
        point.title = title
        self.map.addAnnotation(point)
    }
    
    private func removeAllAnnotations(){
        if let annotations = self.map.annotations as? [MKAnnotation]{
            self.map.removeAnnotations(annotations)
        }
    }
}
