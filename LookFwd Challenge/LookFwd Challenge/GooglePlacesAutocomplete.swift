//
//  GooglePlacesAutocomplete.swift
//  LookFwd Challenge
//
//  Created by Sarjil Hasan on 8/16/17.
//  Copyright © 2017 Sarjil Hasan. All rights reserved.
//  Credit to Howard Wilson

import UIKit
import CoreLocation

public let ErrorDomain: String! = "GooglePlacesAutocompleteErrorDomain"


public protocol GooglePlacesAutocompleteDelegate {
    func placeSelected(_ place: Place)
    func placeViewClosed()
}

// MARK: - GooglePlacesAutocompleteService

open class GooglePlacesAutocompleteService {
    var delegate: GooglePlacesAutocompleteDelegate?
    var apiKey: String?
    var places = [Place]()
    open var placeType: PlaceType = .all
    open var locationBias: LocationBias?
    open var country: String?
    
    public init(apiKey: String, placeType: PlaceType = .all) {
        self.apiKey = apiKey
        self.placeType = placeType
    }
    
    open func getPlaces(_ searchString: String, completion:@escaping (([Place]?, Error?) -> Void)) {
        var params = [
            "input": searchString,
            "types": placeType.description,
            "key": apiKey ?? ""
        ]
        
        if let bias = locationBias {
            params["location"] = bias.location
            params["radius"] = bias.radius.description
        }
        
        if let country = country {
            params["components"] = "country:\(country)"
        }
        
        if (searchString == ""){
            let error = NSError(domain: ErrorDomain, code: 1000, userInfo: [NSLocalizedDescriptionKey:"No search string given"])
            completion(nil,error)
            return
        }
        
        GooglePlacesRequestHelpers.doRequest(
            "https://maps.googleapis.com/maps/api/place/autocomplete/json",
            params: params
        ) { json, error in
            if let json = json{
                if let predictions = json["predictions"] as? Array<[String: Any]> {
                    self.places = predictions.map { (prediction: [String: Any]) -> Place in
                        return Place(prediction: prediction, apiKey: self.apiKey)
                    }
                    
                    completion(self.places, error)
                } else {
                    completion(nil, error)
                }
            } else {
                completion(nil,error)
            }
        }
    }
}

// MARK: - GooglePlacesAutocomplete (UINavigationController)

open class GooglePlacesAutocomplete: UINavigationController {
    open var gpaViewController: GooglePlacesAutocompleteContainer!
    open var closeButton: UIBarButtonItem!
    
    open var gpaService: GooglePlacesAutocompleteService!
    
    // Proxy access to container navigationItem
    open override var navigationItem: UINavigationItem {
        get { return gpaViewController.navigationItem }
    }
    
    open var placeDelegate: GooglePlacesAutocompleteDelegate? {
        get { return gpaService.delegate }
        set { gpaService.delegate = newValue }
    }
    
    open var locationBias: LocationBias? {
        get { return gpaService.locationBias }
        set { gpaService.locationBias = newValue }
    }
    
    public convenience init(apiKey: String, placeType: PlaceType = .all) {
        let service = GooglePlacesAutocompleteService(apiKey: apiKey, placeType: placeType)
        self.init(service:service)
    }
    
    public convenience init(service: GooglePlacesAutocompleteService) {
        
        let gpaViewController = GooglePlacesAutocompleteContainer(service: service)
        self.init(rootViewController: gpaViewController)
        self.gpaService = service
        self.gpaViewController = gpaViewController
        
        closeButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.stop, target: self, action: #selector(GooglePlacesAutocomplete.close))
        closeButton.style = UIBarButtonItemStyle.done
        
        gpaViewController.navigationItem.leftBarButtonItem = closeButton
        gpaViewController.navigationItem.title = "Enter Address"
        
    }
    
    func close() {
        placeDelegate?.placeViewClosed()
    }
    
    open func reset() {
        gpaViewController.searchBar.text = ""
        gpaViewController.searchBar(gpaViewController.searchBar, textDidChange: "")
    }
}

// MARK: - GooglePlacesAutocompleteContainer
open class GooglePlacesAutocompleteContainer: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    open var gpaService: GooglePlacesAutocompleteService!
    
    convenience init(service: GooglePlacesAutocompleteService) {
        let bundle = Bundle(for: GooglePlacesAutocompleteContainer.self)
        
        self.init(nibName: "GooglePlacesAutocomplete", bundle: bundle)
        self.gpaService = service
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override open func viewWillLayoutSubviews() {
        topConstraint.constant = topLayoutGuide.length
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(GooglePlacesAutocompleteContainer.keyboardWasShown(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GooglePlacesAutocompleteContainer.keyboardWillBeHidden(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        searchBar.becomeFirstResponder()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    func keyboardWasShown(_ notification: Notification) {
        if isViewLoaded && view.window != nil {
            if let info: Dictionary = (notification as NSNotification).userInfo,
                let keyboardSize: CGSize = ((info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size){
                let contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0)
                tableView.contentInset = contentInsets;
                tableView.scrollIndicatorInsets = contentInsets;
            }
        }
    }
    
    func keyboardWillBeHidden(_ notification: Notification) {
        if isViewLoaded && view.window != nil {
            self.tableView.contentInset = UIEdgeInsets.zero
            self.tableView.scrollIndicatorInsets = UIEdgeInsets.zero
        }
    }
}

// MARK: - GooglePlacesAutocompleteContainer (UITableViewDataSource / UITableViewDelegate)
extension GooglePlacesAutocompleteContainer: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gpaService.places.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // Get the corresponding candy from our candies array
        let place = gpaService.places[(indexPath as NSIndexPath).row]
        
        // Configure the cell
        cell.textLabel!.text = place.description
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        gpaService.delegate?.placeSelected(gpaService.places[(indexPath as NSIndexPath).row])
        
    }
}

// MARK: - GooglePlacesAutocompleteContainer (UISearchBarDelegate)
extension GooglePlacesAutocompleteContainer: UISearchBarDelegate {
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchText == "") {
            gpaService.places = []
            tableView.isHidden = true
        } else {
            getPlaces(searchText)
        }
    }
    
    /**
     Call the Google Places API and update the view with results.
     
     - parameter searchString: The search query
     */
    
    fileprivate func getPlaces(_ searchText: String){
        gpaService.getPlaces(searchText, completion: {(places: [Place]?,error: Error?) in
            self.tableView.reloadData()
            self.tableView.isHidden = false
            
        }
        )
    }
}

// MARK: - GooglePlaceDetailsRequest
class GooglePlaceDetailsRequest {
    let place: Place
    
    init(place: Place) {
        self.place = place
    }
    
    func request(_ result: @escaping (PlaceDetails) -> ()) {
        GooglePlacesRequestHelpers.doRequest(
            "https://maps.googleapis.com/maps/api/place/details/json",
            params: [
                "placeid": place.id,
                "key": place.apiKey ?? ""
            ]
        ) { json, error in
            if let json = json as [String: AnyObject]? {
                let res = json["result"] as! [String: AnyObject]
                let geometry = res["geometry"] as! [String: AnyObject]
                let jsonLoc = geometry["location"] as! [String: AnyObject]
                
                let name = res["name"] as! String
                let latitude = jsonLoc["lat"] as! Double
                let longitude = jsonLoc["lng"] as! Double
                let location = CLLocation(latitude: latitude, longitude: longitude)
                
                var radius: CLLocationDistance = 10 // default to 10m radius
                
                if let viewport = geometry["viewport"] as? [String: AnyObject] {
                    // We are assuming that the place is circular and using the north-east to centre distance to derive the radius
                    let northEastDict = viewport["northeast"] as! [String: AnyObject]
                    let northEast = CLLocation(latitude: northEastDict["lat"] as! Double, longitude: northEastDict["lng"] as! Double)
                    
                    radius = location.distance(from: northEast)
                }
                
                
                let region = CLCircularRegion(center: location.coordinate, radius: radius, identifier: name)
                
                result(PlaceDetails(name: name, latitude: latitude, longitude: longitude, location: location, region: region))
            }
            if let error = error {
                // TODO: We should probably pass back details of the error
                print("Error fetching google place details: \(error)")
            }
        }
    }
}

// MARK: - GooglePlacesRequestHelpers
class GooglePlacesRequestHelpers {
    /**
     Build a query string from a dictionary
     
     - parameter parameters: Dictionary of query string parameters
     - returns: The properly escaped query string
     */
    
    typealias JSON = [String: Any]
    
    fileprivate class func query(_ parameters: [String: String]) -> String {
        var components: [(String, String)] = []
        for key in Array(parameters.keys).sorted(by: <) {
            let value = parameters[key]!
            components += [(escape(key), escape("\(value)"))]
        }
        
        return (components.map{"\($0)=\($1)"} as [String]).joined(separator: "&")
    }
    
    fileprivate class func escape(_ string: String) -> String {
        let legalURLCharactersToBeEscaped: NSCharacterSet = NSCharacterSet(charactersIn: ":/?&=;+!@#$()',*")
        return NSString(string: string).addingPercentEncoding(withAllowedCharacters: legalURLCharactersToBeEscaped as CharacterSet)! as String
    }
    
    fileprivate class func doRequest(_ url: String, params: [String: String], completion: @escaping (JSON?,Error?) -> ()) {
        let request = URLRequest(
            url: URL(string: "\(url)?\(query(params))")!
        )
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request){ data, response, error in
            self.handleResponse(data, response: response , error: error, completion: completion)
        }
        
        task.resume()
    }
    
    fileprivate class func handleResponse(_ data: Data?, response: URLResponse?, error: Error?, completion: @escaping (JSON?, Error?) -> ()) {
        
        // Always return on the main thread...
        let done: ((JSON?, Error?) -> Void) = {(json, error) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                completion(json,error)
            })
        }
        
        if let error = error {
            print("GooglePlaces Error: \(error.localizedDescription)")
            done(nil,error)
            return
        }
        
        if response == nil {
            print("GooglePlaces Error: No response from API")
            let error = NSError(domain: ErrorDomain, code: 1001, userInfo: [NSLocalizedDescriptionKey:"No response from API"])
            done(nil,error)
            return
        }
        
        let httpResponse = response as! HTTPURLResponse
        
        
        if httpResponse.statusCode != 200 {
            print("GooglePlaces Error: Invalid status code \(httpResponse.statusCode) from API")
            let error = NSError(domain: ErrorDomain, code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey:"Invalid status code"])
            done(nil,error)
            return
        }
        
        let json: NSDictionary?
        do {
            json = try JSONSerialization.jsonObject(
                with: data!,
                options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
        } catch {
            print("Serialisation error")
            let serialisationError = NSError(domain: ErrorDomain, code: 1002, userInfo: [NSLocalizedDescriptionKey:"Serialization error"])
            done(nil,serialisationError)
            return
        }
        
        if let status = json?["status"] as? String {
            if status != "OK" {
                print("GooglePlaces API Error: \(status)")
                let error = NSError(domain: ErrorDomain, code: 1002, userInfo: [NSLocalizedDescriptionKey:status])
                done(nil,error)
                return
            }
        }
        done(json as? [String:Any], nil)
    }
}
