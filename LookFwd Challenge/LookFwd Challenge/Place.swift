//
//  Place.swift
//  LookFwd Challenge
//
//  Created by Sarjil Hasan on 8/21/17.
//  Copyright © 2017 Sarjil Hasan. All rights reserved.
//

import Foundation

open class Place: NSObject {
    open let id: String
    open let desc: String
    open var apiKey: String?
    
    override open var description: String {
        get { return desc }
    }
    
    public init(id: String, description: String) {
        self.id = id
        self.desc = description
    }
    
    public convenience init(prediction: [String: Any], apiKey: String?) {
        
        self.init(
            id: prediction["place_id"] as! String,
            description: prediction["description"] as! String
        )
        
        self.apiKey = apiKey
    }
    
    /**
     Call Google Place Details API to get detailed information for this place
     
     Requires that Place#apiKey be set
     
     - parameter result: Callback on successful completion with detailed place information
     */
    open func getDetails(_ result: @escaping (PlaceDetails) -> ()) {
        GooglePlaceDetailsRequest(place: self).request(result)
    }
}
