//
//  PlaceDetails.swift
//  LookFwd Challenge
//
//  Created by Sarjil Hasan on 8/21/17.
//  Copyright © 2017 Sarjil Hasan. All rights reserved.
//

import CoreLocation

open class PlaceDetails: CustomStringConvertible {
    
    init(name: String, latitude: Double, longitude: Double, location: CLLocation, region: CLCircularRegion) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.location = location
        self.region = region
    }
    
    open let name: String
    open let latitude: Double
    open let longitude: Double
    
    open let location: CLLocation
    
    open var region: CLCircularRegion
    
    open var radius: CLLocationDistance {
        get {
            return region.radius
        }
    }
    
    open var description: String {
        return "PlaceDetails: \(name) (\(latitude), \(longitude))"
    }
}
