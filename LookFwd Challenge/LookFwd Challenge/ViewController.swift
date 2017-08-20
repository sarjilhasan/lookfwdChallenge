//
//  ViewController.swift
//  LookFwd Challenge
//
//  Created by Sarjil Hasan on 8/16/17.
//  Copyright © 2017 Sarjil Hasan. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

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


class ViewController: UIViewController, GMSPanoramaViewDelegate {
    
    
    @IBOutlet weak var streetView: UIView!
    @IBOutlet weak var addressView: UITextView!

    @IBOutlet weak var latitudeView: UITextView!
    @IBOutlet weak var longitudeView: UITextView!
    @IBOutlet weak var regionView: UITextView!
    @IBOutlet weak var fullDetails: UITextView!
    
    let gpaViewController = GooglePlacesAutocomplete(
        apiKey: apiKey,
        placeType: .address
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func searchButton(_ sender: Any) {
        gpaViewController.placeDelegate = self
        
        present(gpaViewController, animated: true, completion: nil)
        //So the StreetView can be updated when another address is choosen.
        self.loadView()
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
            
            //Google Street View.
            let panoView = GMSPanoramaView(frame: self.streetView.frame)

            self.streetView.addSubview(panoView)
            self.streetView.sendSubview(toBack: panoView)
            
            panoView.moveNearCoordinate(CLLocationCoordinate2D(latitude: details.latitude, longitude: details.longitude))
            
            
            let equalWidth = NSLayoutConstraint(item: panoView, attribute: .width, relatedBy: .equal, toItem: self.streetView, attribute: .width, multiplier: 1.0, constant: 0)
            let equalHeight = NSLayoutConstraint(item: panoView, attribute: .height, relatedBy: .equal, toItem: self.streetView, attribute: .height, multiplier: 1.0, constant: 0)
            let top = NSLayoutConstraint(item: panoView, attribute: .top, relatedBy: .equal, toItem: self.streetView, attribute: .top, multiplier: 1.0, constant: 0)
            let left = NSLayoutConstraint(item: panoView, attribute: .left, relatedBy: .equal, toItem: self.streetView, attribute: .left, multiplier: 1.0, constant: 0)
            
            panoView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([equalWidth, equalHeight, top, left])
            
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func placeViewClosed() {
        dismiss(animated: true, completion: nil)
    }
    
 
}
