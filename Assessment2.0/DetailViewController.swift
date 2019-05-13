//
//  DetailViewController.swift
//  Assessment2.0
//
//  Created by Kayn Critchley on 15/4/19.
//  Copyright © 2019 Kayn Critchley. All rights reserved.
//

import CoreLocation
import UIKit
import MapKit

protocol DetailViewControllerDelegate: class {
    func okayPressed()
    func cancelPressed()
    
}

class DetailViewController: UITableViewController, UITextFieldDelegate {
//    var copyOfOriginalExpense: Location?
//    var location: Location?
    weak var delegate: DetailViewControllerDelegate?
    var number = 0.0
    var number1 = 0.0
    var a = 0.0
    var b = 0.0

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var latitudeField: UITextField!
    @IBOutlet weak var longitudeField: UITextField!
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var mapViewField: MKMapView!
    
    
    override func viewDidLoad() {
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelPressed(_:)))
        self.navigationItem.rightBarButtonItem = cancelButton
        super.viewDidLoad()
        configureView()
        self.nameField.delegate = self
        self.addressField.delegate = self
        self.latitudeField.delegate = self
        self.longitudeField.delegate = self
        // Do any additional setup after loading the view.

    }
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
        //guard let variable = variable else {return} is a method of dealing with this error --- Value of optional type 'String?' must be unwrapped to a value of type 'String'
        guard let location = detailItem else { return }
        nameField?.text = location.name
        addressField?.text = "\(location.address)"
        latitudeField?.text = "\(location.latitude)"
        longitudeField?.text = "\(location.longitude)"

        guard copyOfOriginalExpense == nil else { return }
        copyOfOriginalExpense = Location(name: location.name, address: location.address, latitude: location.latitude, longitude: location.longitude)
        
        
    }

    @IBAction func addressInputField(_ sender: UITextField) {
        self.geoCode(sender: sender)
        mapView1()
    }
    

    @IBAction func latitudeInputField(_ sender: UITextField) {
        guard let latitudeText = sender.text,
            let latitude = Double(latitudeText) else { return }
        number = latitude
        reverseGeoCode()
        mapView()
    }
    
    @IBAction func longitudeInputField(_ sender: UITextField) {
        guard let longitudeText = sender.text,
            let longitude = Double(longitudeText) else { return }
        number1 = longitude
        reverseGeoCode()
        mapView()
    }
    

    func reverseGeoCode(){
        let geo = CLGeocoder()
        let location = CLLocation(latitude: number, longitude: number1)
        geo.reverseGeocodeLocation(location){
            guard let places = $0 else {
                print("Got error \(String(describing: $1))")
                return
            }
            for place in places{
                guard let name = place.name, let state = place.administrativeArea, let cityLocation = place.locality else {
                    print("Got no name")
                    continue
                }
                print("Name: \(name), \(place.administrativeArea ?? "nothingFound"), \(place.locality ?? "nothingFound")")
                
                self.addressField.text = "\(name), \(cityLocation),\(state) "
            }
        }

  
    }
    
    func geoCode (sender: UITextField){
        print(sender.text!)
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
                self.a = location.coordinate.latitude
                self.b = location.coordinate.longitude
                
            }
        }
        
    }

    func saveInModel(){
        // this is another way of dealing with the error above. delete the ?? "" to see error
        detailItem?.name = nameField.text ?? ""
        detailItem?.address = addressField.text ?? ""
//        detailItem?.latitude = latitudeField.text ?? ""
//        detailItem?.longitude = longitudeField.text ?? ""
        
        guard let latitudeText = latitudeField?.text else { return }
            let latitude = Double(latitudeText) ?? 0.0
        detailItem?.latitude = latitude
//
        guard let longitudeText = longitudeField.text else { return }
            let longitude = Double(longitudeText) ?? 0.0
        detailItem?.longitude = longitude

        
        // how to deal with a data type is too ambigious
    }

    func mapView(){
        guard let latitudeText = latitudeField?.text else { return }
        let latitude = Double(latitudeText) ?? 0.0
        detailItem?.latitude = latitude
        //
        guard let longitudeText = longitudeField.text else { return }
        let longitude = Double(longitudeText) ?? 0.0
        detailItem?.longitude = longitude

        let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        print(coordinates)
        let region = MKCoordinateRegion(center: coordinates, latitudinalMeters: 10_000, longitudinalMeters: 10_000)
        
        mapViewField.setRegion(region, animated: true)
        //mapOutlet.setCenter(coordinates, animated: true)
        
        //mapPin
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinates
            
            annotation.title = self.nameField.text
            annotation.subtitle = "\(coordinates.latitude), \(coordinates.longitude)"
            //let pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "")
            self.mapViewField.addAnnotation(annotation)
        }
    }
    
    func mapView1(){
        
        let coordinates = CLLocationCoordinate2D(latitude: a, longitude: b)
        print(coordinates)
        let region = MKCoordinateRegion(center: coordinates, latitudinalMeters: 10_000, longitudinalMeters: 10_000)
        
        mapViewField.setRegion(region, animated: true)
        //mapOutlet.setCenter(coordinates, animated: true)
        
        //mapPin
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinates
            
            annotation.title = self.nameField.text
            annotation.subtitle = "\(coordinates.latitude), \(coordinates.longitude)"
            //let pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "")
            self.mapViewField.addAnnotation(annotation)
        }
    }
    
    
    @IBAction func okayPressed(_ sender: Any) {
        if let d = delegate{
            d.okayPressed()
        }
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        guard let copy = copyOfOriginalExpense else { return }
        detailItem?.name = copy.name
        detailItem?.address = copy.address
//        detailItem?.latitude = copy.latitude
//        detailItem?.longitude = copy.longitude
        
        configureView()
        guard let d = delegate else { return }
        d.cancelPressed()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
        
    }
    
    var detailItem: Location? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    var copyOfOriginalExpense: Location? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    
    
}
