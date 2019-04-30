//
//  Contact.swift
//  Assessment2.0
//
//  Created by Kayn Critchley on 15/4/19.
//  Copyright © 2019 Kayn Critchley. All rights reserved.
//

import Foundation

//class Contact {
//    
//    var famName: String
//    var othName: String
//    var phoneNum: String
//    
//    init(famName: String, othName: String, phoneNum: String){
//        self.famName = famName
//        self.othName = othName
//        self.phoneNum = phoneNum
//    }
//    
//    var description: String {
//        return "\(othName) \(famName): \(phoneNum)"
//    }
//    
//}

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

