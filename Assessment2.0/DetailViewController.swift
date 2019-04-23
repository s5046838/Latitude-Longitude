//
//  DetailViewController.swift
//  Assessment2.0
//
//  Created by Kayn Critchley on 15/4/19.
//  Copyright © 2019 Kayn Critchley. All rights reserved.
//

import CoreLocation
import UIKit

protocol DetailViewControllerDelegate: class {
    func okayPressed()
    func cancelPressed()
    
}

class DetailViewController: UIViewController {
//    var copyOfOriginalExpense: Location?
//    var location: Location?
    weak var delegate: DetailViewControllerDelegate?
    var number = 0.0
    var number1 = 0.0


    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var latitudeField: UITextField!
    @IBOutlet weak var longitudeField: UITextField!
    @IBOutlet weak var detailDescriptionLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        // Do any additional setup after loading the view.

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureView()
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
//        latitudeField?.text = "\(location.latitude)"
//        longitudeField?.text = "\(location.longitude)"

        guard copyOfOriginalExpense == nil else { return }
        copyOfOriginalExpense = Location(name: location.name, address: location.address)
        
        
    }
    
    @IBAction func nameInputField(_ sender: UITextField) {
        self.geoCode(sender: sender)
    }
    @IBAction func addressInputField(_ sender: UITextField) {
        self.geoCode(sender: sender)
    }
    
    @IBAction func latitudeInputField(_ sender: UITextField) {
        guard let latitudeText = sender.text,
            let latitude = Double(latitudeText) else { return }
        number = latitude
        reverseGeoCode()


    }
    
    @IBAction func longitudeInputField(_ sender: UITextField) {
        guard let longitudeText = sender.text,
            let longitude = Double(longitudeText) else { return }
        number1 = longitude
        reverseGeoCode()
        
        
    }
    
    @IBAction func clearField(_ sender: Any) {
        nameField.text = ""
        addressField.text = ""
        latitudeField.text = ""
        longitudeField.text = ""
        
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
                guard let name = place.name else {
                    print("Got no name")
                    continue
                }
                print("Name: \(name), \(place.administrativeArea ?? "nothingFound"), \(place.locality ?? "nothingFound")")
                self.nameField.text = place.locality
                self.addressField.text = name
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
            }
        }
    }

    func saveInModel(){
        // this is another way of dealing with the error above. delete the ?? "" to see error
        detailItem?.name = nameField.text ?? ""
        detailItem?.address = addressField.text ?? ""
//        detailItem?.latitude = latitudeField.text ?? ""
//        detailItem?.longitude = longitudeField.text ?? ""
        
//        guard let latitudeText = latitudeField.text,
//            let latitude = Double(latitudeText) else { return }
//        detailItem?.latitude = latitude
//
//        guard let longitudeText = longitudeField.text,
//            let longitude = Double(longitudeText) else { return }
//        detailItem?.longitude = longitude
        
        
        // how to deal with a data type is too ambigious
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
