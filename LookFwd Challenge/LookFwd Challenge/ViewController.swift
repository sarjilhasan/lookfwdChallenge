//
//  ViewController.swift
//  LookFwd Challenge
//
//  Created by Sarjil Hasan on 8/16/17.
//  Copyright © 2017 Sarjil Hasan. All rights reserved.
//

import UIKit

#if API_KEY
    /// You can either set an API_KEY environment variable which will be used by the example and tests ...
    lazy var apiKey: String = {
        let dict = NSProcessInfo.processInfo().environment
        return dict["API_KEY"] as! String
    }()
#else
    /// or you can type one in here - just try not to reveal it to the world
let apiKey: String = "AIzaSyAQODbnty6TgPX82-X18RUrj7KR5nI-T5w"
#endif


class ViewController: UIViewController {
    
    
    @IBOutlet weak var addressView: UITextView!

    @IBOutlet weak var latitudeView: UITextView!
    @IBOutlet weak var longitudeView: UITextView!
    @IBOutlet weak var regionView: UITextView!
    @IBOutlet weak var fullDetails: UITextView!
    
    let gpaViewController = GooglePlacesAutocomplete(
        apiKey: apiKey,
        placeType: .address
    )
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        

    }
    
    @IBAction func searchButton(_ sender: Any) {
        gpaViewController.placeDelegate = self
        
        present(gpaViewController, animated: true, completion: nil)
    }
}

extension ViewController: GooglePlacesAutocompleteDelegate {
    func placeSelected(_ place: Place) {
        print("Address: ")
        print(place.description + "\n")
        self.addressView.text = place.description

        place.getDetails { details in
            self.fullDetails.text = String(describing: details)
            
            print("Lattitude: ")
            print(details.latitude)
            self.latitudeView.text = String(describing: details.latitude)
            print("\nLongitude: ")
            print(details.longitude)
            self.longitudeView.text =  String(describing: details.longitude)
            
            print("\nRegion: ")
            print(details.region)
            self.regionView.text =  String(describing: details.location)

            
        }
        dismiss(animated: true, completion: nil)
    }
    
    func placeViewClosed() {
        dismiss(animated: true, completion: nil)
    }
    
 
}
