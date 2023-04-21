//
//  CustomPointAnnotation.swift
//  MapKitTask
//
//  Created by apple on 13/04/23.
//

import UIKit
import MapKit

class CustomAnnotationView: MKAnnotationView {

    var calloutView: CustomCallOutView?
    
    var temperature: String?
    var weather: String?
    var windSpeed: String?
    var humidity: String?

    override var annotation: MKAnnotation? {
        willSet {
            self.calloutView?.removeFromSuperview()
        }
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        if let customPointAnnotation = annotation as? CustomPointAnnotation {
            self.temperature = customPointAnnotation.temperature
            self.weather = customPointAnnotation.weather
            self.windSpeed = customPointAnnotation.windSpeed
            self.humidity = customPointAnnotation.humidity
        }
        self.canShowCallout = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.canShowCallout = false
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)
        self.calloutView?.removeFromSuperview()
        if selected {
            if let newCalloutView = self.loadCalloutView() {
                newCalloutView.temperature = self.temperature ?? ""
                newCalloutView.weather = self.weather ?? ""
                newCalloutView.windSpeed = self.windSpeed ?? ""
                newCalloutView.humidity = self.humidity ?? ""
                let calloutViewWidth = UIDevice.current.userInterfaceIdiom == .pad ? screenWidth * 0.5 : screenWidth - 40
                newCalloutView.frame.size.width = calloutViewWidth
                newCalloutView.center = CGPoint(x: self.frame.width/2, y: -(newCalloutView.frame.height/2))
                self.addSubview(newCalloutView)
                self.calloutView = newCalloutView
            }
        }
    }

    func loadCalloutView() -> CustomCallOutView? {
        if let views = Bundle.main.loadNibNamed("CustomCallOutView", owner: self, options: nil) as? [CustomCallOutView], !views.isEmpty {
            return views.first!
        }
        return nil
    }
}

let screenWidth = UIScreen.main.bounds.size.width
let screenHeight = UIScreen.main.bounds.size.height
