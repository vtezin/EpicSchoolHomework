//
//  HeartImage.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 25.03.2022.
//

import UIKit

@IBDesignable class HeartBezierView: UIView {
    @IBInspectable private var filled: Bool = true
    @IBInspectable private var strokeWidth: CGFloat = 2.0
    
    @IBInspectable var strokeColor: UIColor?
    
    override func draw(_ rect: CGRect) {
        let bezierPath = UIBezierPath(heartIn: self.bounds)
        
        if self.strokeColor != nil {
            self.strokeColor!.setStroke()
        } else {
            self.tintColor.setStroke()
        }
        
        bezierPath.lineWidth = self.strokeWidth
        bezierPath.stroke()
        
        if self.filled {
            self.tintColor.setFill()
            bezierPath.fill()
        }
    }    
}
