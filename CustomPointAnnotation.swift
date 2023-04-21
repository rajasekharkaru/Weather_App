//
//  CustomPointAnnotation.swift
//  MapKitTask
//
//  Created by apple on 13/04/23.
//

import MapKit

class CustomPointAnnotation: MKPointAnnotation {
    var temperature: String!
    var weather: String!
    var windSpeed: String!
    var humidity:String!

    override init() {
        
    }
}
