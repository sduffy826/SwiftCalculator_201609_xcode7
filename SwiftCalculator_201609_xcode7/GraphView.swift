//
//  GraphView.swift
//  SwiftCalculator_201609_xcode7
//
//  Created by Sean Regular on 11/13/16.
//  Copyright © 2016 CS193p. All rights reserved.
//

import UIKit

@IBDesignable
class GraphView: UIView {
    
    @IBInspectable
    // If var is set we need to call setNeedsDisplay to tell it we need to redraw
    var scale: CGFloat = 0.9 { didSet { setNeedsDisplay() } }
    @IBInspectable
    var color: UIColor = UIColor.blueColor() { didSet { setNeedsDisplay() } }
    @IBInspectable
    var lineWidth: CGFloat = 5.0 { didSet { setNeedsDisplay() } }
    @IBInspectable
    var origin: CGPoint = CGPoint(x: 0, y: 0) { didSet { setNeedsDisplay() } }
    @IBInspectable
    var pointsPerUnit: CGFloat = 1.0 { didSet { setNeedsDisplay() } }
    
    //var cSF = self.contentScaleFactor

    // Computed property for the radius (min of half width or height)
    private var ballRadius: CGFloat {
        return min(bounds.size.width, bounds.size.height) / 2 * scale
    }
    
    // Computed property for the skull center
    private var ballCenter: CGPoint {
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    // remember withRadius is external name, radius is internal name :)
    private func pathForCircleCenteredAtPoint(midPoint: CGPoint, withRadius radius: CGFloat) -> UIBezierPath
    {
        // Return bezier path for a circle based on midpoint/radius
        let thePath = UIBezierPath(arcCenter: midPoint,
                                   radius: radius,
                                   startAngle: 0.0,
                                   endAngle: CGFloat(2*M_PI),
                                   clockwise: false)
        thePath.lineWidth = lineWidth
        return thePath
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        let cSF = contentScaleFactor
        let axesDrawer = AxesDrawer(color: UIColor.blackColor(), contentScaleFactor: cSF)

        print("width: \(bounds.size.width) height: \(bounds.size.height)")
        print("Origin: \(origin) PtsPerUnit \(pointsPerUnit) ScaleFactor \(cSF)")
        
        let ball = pathForCircleCenteredAtPoint(ballCenter, withRadius: ballRadius)
        color.set()
        ball.stroke()

        axesDrawer.drawAxesInRect(rect, origin: origin, pointsPerUnit: pointsPerUnit)
        
    }
    
}
