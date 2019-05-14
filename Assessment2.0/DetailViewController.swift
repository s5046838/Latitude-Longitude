//
//  DetailViewController.swift
//  Assessment2.0
//
//  Created by Kayn Critchley on 15/4/19.
//  Copyright © 2019 Kayn Critchley. All rights reserved.
//
/// Frameworks imported into swift
import CoreLocation
import UIKit
import MapKit

///Protocols designated to check if user presses ok or cancel
protocol DetailViewControllerDelegate: class {
    /// okayPressed function protocol is designed to accept input when activ
    func okayPressed()
    func cancelPressed()
    
}

class DetailViewController: UITableViewController, UITextFieldDelegate {
    
    ///DetailView controller delegate
    weak var delegate: DetailViewControllerDelegate?
    /// var latitudeNumber and longitudeNumber store the user's inputted lat/long from their corrosponding textFields to use in reverseGeo location
    var latitudeNumber = 0.0
    var longitudeNumber = 0.0

    ///The text fields the user interacts with and enters user data into
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var latitudeField: UITextField!
    @IBOutlet weak var longitudeField: UITextField!
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    
    ///mapViewField is the map object placed onto the UI View
    @IBOutlet weak var mapViewField: MKMapView!
    
    
    override func viewDidLoad() {
        ///cancel button dynamically added
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelPressed(_:)))
        self.navigationItem.rightBarButtonItem = cancelButton
        super.viewDidLoad()
        configureView()
        
        ///assigning the textFields as their own delegates
        self.nameField.delegate = self
        self.addressField.delegate = self
        self.latitudeField.delegate = self
        self.longitudeField.delegate = self
        // Do any additional setup after loading the view.

    }
    
    ///calling the configureView/mapViewFunction
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureView()
        mapView()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        saveInModel()
        delegate?.okayPressed()
    }
    
    func configureView(){
        guard let location = detailItem else { return }
        nameField?.text = location.name
        addressField?.text = "\(location.address)"
        latitudeField?.text = "\(location.latitude)"
        longitudeField?.text = "\(location.longitude)"
        
        /// copyOfOriginalLocation is a variable which stores the class uneditied by the user to act as a cancel feature 
        guard copyOfOriginalLocation == nil else { return }
        copyOfOriginalLocation = Location(name: location.name, address: location.address, latitude: location.latitude, longitude: location.longitude)
        mapView()
        
        
    }
    
    /// Responsible for taking the user input from the AddressField and applying the geoCode function and mapView Function
    @IBAction func addressInputField(_ sender: UITextField) {
        self.geoCode(sender: sender)
        mapView()
    }
    
    /// Responsible for taking the user input from the LatitudeField and applying the ReverseGeoCode function and mapView Function
    @IBAction func latitudeInputField(_ sender: UITextField) {
        guard let latitudeText = sender.text,
            let latitude = Double(latitudeText) else { return }
        latitudeNumber = latitude
        reverseGeoCode()
        mapView()
    }
    
    /// Responsible for taking the user input from the Longitude and applying the reverseGeoCode function and mapView Function
    @IBAction func longitudeInputField(_ sender: UITextField) {
        guard let longitudeText = sender.text,
            let longitude = Double(longitudeText) else { return }
        longitudeNumber = longitude
        reverseGeoCode()
        mapView()
    }
    
    /// Function responsible for doing reverse geocoding and looking up an address based off its latitude/longitude and outputting the locations name/street, city, state and country
    func reverseGeoCode(){
        let geo = CLGeocoder()
        let location = CLLocation(latitude: latitudeNumber, longitude: longitudeNumber)
        geo.reverseGeocodeLocation(location){
            guard let places = $0 else {
                print("Got error \(String(describing: $1))")
                return
            }
            for place in places{
                guard let name = place.name, let state = place.administrativeArea, let cityLocation = place.locality, let country = place.country else {
                    print("Got no name")
                    continue
                }
                print("Name: \(name), \(place.administrativeArea ?? "nothingFound"), \(place.locality ?? "nothingFound")")
                self.addressField.text = "\(name), \(cityLocation), \(state), \(country)"
            }
        }

  
    }
    /// Function responsible for doing  geocoding and looking up an address based off its street name/address and outpuitting its latitude/longitude
    func geoCode (sender: UITextField){
        let geo = CLGeocoder()
        let address = sender.text ?? ""
        
        geo.geocodeAddressString(address){
            guard let placeMarks = $0 else{
                print("Got error \(String(describing: $1))")
                return
            }
            for placeMark in placeMarks{
                guard let location = placeMark.location else {
                    continue
                }
                self.latitudeField.text = String(location.coordinate.latitude)
                self.longitudeField.text = String(location.coordinate.longitude)
                
            }
        }
        
    }
    
    ///Saves inputted data from textFields into model class Location
    func saveInModel(){
        detailItem?.name = nameField.text ?? ""
        detailItem?.address = addressField.text ?? ""
        guard let latitudeText = latitudeField?.text else { return }
            let latitude = Double(latitudeText) ?? 0.0
        detailItem?.latitude = latitude
        guard let longitudeText = longitudeField.text else { return }
            let longitude = Double(longitudeText) ?? 0.0
        detailItem?.longitude = longitude
    }
    
    /// mapView Function is responsible for taking a latitude/longitude and entering that data into the map and updating the map's location
    func mapView(){
        guard let latitudeText = latitudeField?.text else { return }
        let latitude = Double(latitudeText) ?? 0.0
        guard let longitudeText = longitudeField.text else { return }
        let longitude = Double(longitudeText) ?? 0.0
    
        ///code to find map location based off latitude/longitude
        let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        print(coordinates)
        let region = MKCoordinateRegion(center: coordinates, latitudinalMeters: 10_000, longitudinalMeters: 10_000)
        mapViewField.setRegion(region, animated: true)

        ///mapPin places a pin inside the map based off the latitude/longitude
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinates
            annotation.title = self.nameField.text
            annotation.subtitle = "\(coordinates.latitude), \(coordinates.longitude)"

            self.mapViewField.addAnnotation(annotation)
        }
    }
    
    /// function responsible for when the user presses ok
    @IBAction func okayPressed(_ sender: Any) {
        if let d = delegate{
            d.okayPressed()
        }
    }
    
    /// function responsible for when the user presses cancel
    @IBAction func cancelPressed(_ sender: Any) {
        guard let copy = copyOfOriginalLocation else { return }
        detailItem?.name = copy.name
        detailItem?.address = copy.address
//        detailItem?.latitude = copy.latitude
//        detailItem?.longitude = copy.longitude
        
        configureView()
        guard let d = delegate else { return }
        d.cancelPressed()
    }
    
    /// function responsible for when the user ends using onscreen keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
        
    }
    
    /// The model class saved as a variable to use in the MasterDetailView to store user input into
    var detailItem: Location? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    /// The model class saved as a variable to use in the MasterDetailView if the user decides to cancel any inputthe user doesn't want to enter
    var copyOfOriginalLocation: Location? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    
    
}
