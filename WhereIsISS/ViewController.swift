//
//  ViewController.swift
//  WhereIsISS
//
//  Created by Mike on 9/24/19.
//  Copyright © 2019 Mike. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Set a repeating 2 second timer to fetch and update our position
        let timer = Timer(timeInterval: 2.0, target: self, selector: #selector(fetchAndUpdateISSPosition), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: .default)
    }
    
    @objc private func fetchAndUpdateISSPosition() {
        let url = URL(string: "http://api.open-notify.org/iss-now.json")!
        let request = URLRequest(url: url)
        
        // Kick off the HTTP request. This shit happens on a background thread by default
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            // Deserialize JSON response
            guard let deserialized = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers) else {
                print("Couldn't deserialize response")
                return
            }
            
            // Cast our JSON response as a Dictionary<String, Any>
            guard let json = deserialized as? Dictionary<String, Any> else {
                print("Couldn't parse response")
                return
            }
            
            // Parse our the information we want
            if let position = json["iss_position"] as? [String: String],
                let latitudeString = position["latitude"],
                let longitudeString = position["longitude"] {
                
                // These values are strings. Need to cast them to Double bc
                // downstream CLLocationCoordinate2D requires Double
                let latitude = Double(latitudeString)
                let longitude = Double(longitudeString)
                
                let span = MKCoordinateSpan(latitudeDelta: 50, longitudeDelta: 50)
                let center = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
                let region = MKCoordinateRegion(center: center, span: span)
                
                // update UI on the main thread
                DispatchQueue.main.async {
                    self.mapView.setRegion(region, animated: true)
                }
            }
        }.resume()
    }
}

