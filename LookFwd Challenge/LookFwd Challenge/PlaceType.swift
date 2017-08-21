//
//  PlaceType.swift
//  LookFwd Challenge
//
//  Created by Sarjil Hasan on 8/21/17.
//  Copyright © 2017 Sarjil Hasan. All rights reserved.
//

public enum PlaceType: CustomStringConvertible {
    case all
    case geocode
    case address
    case establishment
    case regions
    case cities
    
    public var description : String {
        switch self {
        case .all: return ""
        case .geocode: return "geocode"
        case .address: return "address"
        case .establishment: return "establishment"
        case .regions: return "(regions)"
        case .cities: return "(cities)"
        }
    }
}
