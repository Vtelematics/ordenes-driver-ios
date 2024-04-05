//
//  GradientHeaderView.swift
//  FoodDelivery
//
//  Created by Apple on 13/06/18.
//  Copyright © 2018 Adyas Iinfotech. All rights reserved.
//

import UIKit
import Foundation

@IBDesignable class GradientHeaderView: UIView {

    /// Gradient layer that is added on top of the view
    var gradientLayer: CAGradientLayer!
    
    /// Top color of the gradient layer
    @IBInspectable var topColor: UIColor = UIColor.black {
        didSet {
            updateUI()
        }
    }
    
    /// Bottom color of the gradient layer
    @IBInspectable var bottomColor: UIColor = UIColor.clear {
        didSet {
            updateUI()
        }
    }
    
    /// At which vertical point the layer should end
    @IBInspectable var bottomYPoint: CGFloat = 0.6 {
        didSet {
            updateUI()
        }
    }
    
   /* Updates the UI
    */
    func updateUI() {
        setNeedsDisplay()
    }
    
    /**
     Sets up the gradient layer
     */
    func setupGradientLayer() {
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = frame
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: bottomYPoint)
        layer.addSublayer(gradientLayer)
    }
    
    /**
     Lays out all the subviews it has, in our case the gradient layer
     */
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = frame
    }
    
    /**
     Initialises the view
     
     - parameter aDecoder: aDecoder
     
     - returns: self
     */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupGradientLayer()
    }
    
    /**
     Initialises the view
     
     - parameter frame: frame to use
     
     - returns: self
     */
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradientLayer()
    }
    
    /**
     Adjusts the background of the view if user scrolls down enough
     
     - parameter isClear: YES, if the background needs to be clear, otherwise use a solid color
     */
    func adjustBackground(isClear: Bool) {
        if isClear == true {
            gradientLayer.isHidden = false
            backgroundColor = UIColor.clear
        } else {
            gradientLayer.isHidden = true
            backgroundColor = themeColor
        }
    }

}
