//
//  MapViewController.swift
//  Feed Me
//
/// Copyright (c) 2017 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import GoogleMaps
import CoreLocation

//var locationManager = CLLocationManager()
class MapViewController: UIViewController { 
  
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet private weak var mapCenterPinImage: UIImageView!
  @IBOutlet private weak var pinImageVerticalConstraint: NSLayoutConstraint!
  var searchedTypes = ["bakery", "bar", "cafe", "grocery_or_supermarket", "restaurant"]
  private let locationManager = CLLocationManager()
  override func loadView() {
    let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
    let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
    view = mapView
    let marker = GMSMarker()
    marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
    marker.title = "Sydney"
    marker.snippet = "Australia"
    marker.map = mapView
  } 
    @IBOutlet weak var mapView: GMSMapView!
    override func viewDidLoad() {
      super.viewDidLoad()
      locationManager.delegate = self
      locationManager.requestWhenInUseAuthorization()
      mapView.delegate = self
  
  
  }
  
  
  private func reverseGeocodeCoordinate(_ coordinate: CLLocationCoordinate2D) {
    
    // Creates a GMSGeocoder object to turn a latitude and longitude coordinate into a street address.
    let geocoder = GMSGeocoder()
    
    // Asks the geocoder to reverse geocode the coordinate passed to the method. It then verifies there is an address in the response of type GMSAddress. This is a model class for addresses returned by the GMSGeocoder.
    geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
      guard let address = response?.firstResult(), let lines = address.lines else {
        return
      }
      
      // Sets the text of the addressLabel to the address returned by the geocoder.
      self.addressLabel.text = lines.joined(separator: "\n")
      
      // Prior to the animation block, this adds padding to the top and bottom of the map. The top padding equals the view’s top safe area inset, while the bottom padding equals the label’s height.
      let labelHeight = self.addressLabel.intrinsicContentSize.height
      self.mapView.padding = UIEdgeInsets(top: self.view.safeAreaInsets.top, left: 0, bottom: 50, right: 0)
      
      UIView.animate(withDuration: 0.25) {
        // Updates the location pin’s position to match the map’s padding by adjusting its vertical layout constraint.
        self.pinImageVerticalConstraint.constant = ((labelHeight - self.view.safeAreaInsets.top) * 0.5)
        self.view.layoutIfNeeded()
      }
    }
    self.addressLabel.unlock()
  }
  
  
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let navigationController = segue.destination as? UINavigationController,
      let controller = navigationController.topViewController as? TypesTableViewController else {
        return
    }
    controller.selectedTypes = searchedTypes
    controller.delegate = self
  }
    
}

// MARK: - TypesTableViewControllerDelegate
extension MapViewController: TypesTableViewControllerDelegate {
  func typesController(_ controller: TypesTableViewController, didSelectTypes types: [String]) {
    searchedTypes = controller.selectedTypes.sorted()
    dismiss(animated: true)
  }
  
  

}
// MARK: - CLLocationManagerDelegate
//You create a MapViewController extension that conforms to CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
  // locationManager(_:didChangeAuthorization:) is called when the user grants or revokes location permissions.
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    // Here you verify the user has granted you permission while the app is in use.
    guard status == .authorizedWhenInUse else {
      return
    }
    // Once permissions have been established, ask the location manager for updates on the user’s location.
    locationManager.startUpdatingLocation()
    
    //GMSMapView has two features concerning the user’s location: myLocationEnabled draws a light blue dot where the user is located, while myLocationButton, when set to true, adds a button to the map that, when tapped, centers the map on the user’s location.
    mapView.isMyLocationEnabled = true
    mapView.settings.myLocationButton = true
  }
  
  // GMSMapView has two features concerning the user’s location: myLocationEnabled draws a light blue dot where the user is located, while myLocationButton, when set to true, adds a button to the map that, when tapped, centers the map on the user’s location.
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.first else {
      return
    }
    
    // This updates the map’s camera to center around the user’s current location. The GMSCameraPosition class aggregates all camera position parameters and passes them to the map for display.
    mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
    
    // Tell locationManager you’re no longer interested in updates; you don’t want to follow a user around as their initial location is enough for you to work with.
    locationManager.stopUpdatingLocation()
  }
}

// MARK: - GMSMapViewDelegate
extension MapViewController: GMSMapViewDelegate {
  func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
    reverseGeocodeCoordinate(position.target)
  }
  func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
    addressLabel.lock()
  }
}



