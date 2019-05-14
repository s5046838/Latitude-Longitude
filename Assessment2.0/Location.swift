//
//  Contact.swift
//  Assessment2.0
//
//  Created by Kayn Critchley on 15/4/19.
//  Copyright © 2019 Kayn Critchley. All rights reserved.
//

import Foundation

/// Model Class to store input user data. Codable added after class name to make it codable for JSON persistance
class Location:Codable {
    var name: String = ""
    var address: String = ""
    var latitude: Double
    var longitude: Double
    
    init(name:String, address: String, latitude:Double, longitude:Double){
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        
    }
}

