//
//  Location.swift
//  OnTheMap
//
//  Created by Leqi Long on 6/23/16.
//  Copyright © 2016 Student. All rights reserved.
//
import MapKit

struct Location{
    
    // MARK: Properties
    
    let latitude: Double
    let longitude: Double
    let mapString: String
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(latitude, longitude)
    }
}
