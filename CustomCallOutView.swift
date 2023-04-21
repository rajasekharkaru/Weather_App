//
//  CustomPointAnnotation.swift
//  MapKitTask
//
//  Created by apple on 13/04/23.
//

import UIKit

class CustomCallOutView: UIView {

   @IBOutlet weak var backgroundView: UIView!
   @IBOutlet weak var windLabel: UILabel!
   @IBOutlet weak var temperatureLabel: UILabel!
   @IBOutlet weak var weatherLabel: UILabel!
   @IBOutlet weak var humidityLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setUpElements()
    }
    
    func setUpElements() {
        self.layer.applySketchShadow(color: .black, alpha:0.5, x: 0, y: 2, blur: 30, spread: 0)
    }
    
    var temperature: String = "" {
        didSet {
            temperatureLabel.text = temperature
        }
    }
    
    var windSpeed: String = "" {
        didSet {
            windLabel.text = windSpeed
            windLabel.isHidden = windSpeed.isEmpty
        }
    }
    
    var weather: String = "" {
        didSet {
            weatherLabel.text = weather
            weatherLabel.isHidden = weather.isEmpty
        }
    }
    
    var humidity: String = "" {
        didSet {
            humidityLabel.text = humidity
            humidityLabel.isHidden = humidity.isEmpty
        }
    }
}

extension CALayer {
    
    func applySketchShadow(
        color: UIColor = .black,
        alpha: Float = 0.5,
        x: CGFloat = 0,
        y: CGFloat = 2,
        blur: CGFloat = 4,
        spread: CGFloat = 0) {
        shadowColor = color.cgColor
        shadowOpacity = alpha
        shadowOffset = CGSize(width: x, height: y)
        shadowRadius = blur / 2.0
        shadowPath = nil
        if spread != 0 {
            let dx = -spread
            let rect = bounds.insetBy(dx: dx, dy: dx)
            let path = UIBezierPath(rect: rect).cgPath
            shadowPath = path
        }
    }
}
