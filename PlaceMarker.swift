//
//  PlaceMarker.swift
//  
//
//  Created by Maria I Tarazona on 11/30/18.
//


import UIKit
import GoogleMaps

class PlaceMarker: GMSMarker {
    // Add a property of type GooglePlace to the PlaceMarker.
    let place: GooglePlace
    
    // Declare a new designated initializer that accepts a GooglePlace as its sole parameter and fully initializes a PlaceMarker with a position, icon image, anchor for the marker’s position and an appearance animation.
    init(place: GooglePlace) {
        self.place = place
        super.init()
        
        position = place.coordinate
        icon = UIImage(named: place.placeType+"_pin")
        groundAnchor = CGPoint(x: 0.5, y: 1)
        appearAnimation = .pop
    }
}
