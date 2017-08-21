//
//  LocationBias.swift
//  LookFwd Challenge
//
//  Created by Sarjil Hasan on 8/21/17.
//  Copyright © 2017 Sarjil Hasan. All rights reserved.
//

import CoreLocation

public struct LocationBias {
    public let latitude: CLLocationDegrees
    public let longitude: CLLocationDegrees
    public let radius: CLLocationDistance
    
    public init(latitude: Double = 0, longitude: Double = 0, radius: Int = 20000000) {
        self.latitude = latitude
        self.longitude = longitude
        self.radius = Double(radius)
    }
    
    public init(latitude: Double = 0, longitude: Double = 0, radius: CLLocationDistance = 20000000) {
        self.latitude = latitude
        self.longitude = longitude
        self.radius = radius
    }
    
    public init(location:CLLocation, radius: CLLocationDistance = 20000000){
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        self.radius = radius
    }
    
    public init(region:CLCircularRegion){
        self.latitude = region.center.latitude
        self.longitude = region.center.longitude
        self.radius = region.radius
    }
    
    public var location: String {
        return "\(latitude),\(longitude)"
    }
}
