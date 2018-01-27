//
//  ViewController.swift
//  Spirograph
//
//  Created by Johan Ospina on 6/25/16.
//  Copyright © 2016 Johan Ospina. All rights reserved.
//

import UIKit
import QuartzCore

class ViewController: UIViewController {
    
    var pointCollection : [CGPoint] = []
    var paths           : [CAShapeLayer] = []
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var smallGear: CircleView!
    @IBOutlet weak var smallGearContainer: UIView!
    @IBOutlet weak var bigGear: CircleView!
    @IBOutlet weak var sliderLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        slider.maximumValue = Float(smallGearContainer.bounds.size.width / 2)
        
     }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        self.sliderLabel.text = "Value: " + String(sender.value)
        
        var oldCenter = smallGear.center
        smallGear.frame = CGRect(x: smallGear.frame.minX, y: smallGear.frame.minY, width: CGFloat(sender.value), height: CGFloat(sender.value))
    
        let delta = oldCenter.x - smallGear.center.x;
        oldCenter = CGPoint( x: oldCenter.x + delta, y: oldCenter.y);
        smallGear.center = oldCenter;
        smallGear.setNeedsUpdateConstraints();
        smallGear.setNeedsDisplay();
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let point = touch.location(in: self.view)
            if detectAndValidateScreenTouch(pointInScreen: point){
                pointCollection.append(point)
            }
        }
    }


    func runSpinAnimationOnView(view: UIView, duration : CFTimeInterval, rotations: Double, repetitions : Float)
    {
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.toValue = NSNumber(value: Float.pi * 2.0 * Float(rotations))
        rotationAnimation.duration = duration
        rotationAnimation.isCumulative = true
        rotationAnimation.repeatCount = repetitions
        view.layer.add(rotationAnimation, forKey: "rotationAnimation")
    }
    
    func detectAndValidateScreenTouch(pointInScreen : CGPoint) -> Bool
    {
        let touchCGRect = CGRect(x: smallGear.frame.minX + smallGearContainer.frame.minX, y: smallGear.frame.minY + smallGearContainer.frame.minY, width: smallGear.frame.width, height: smallGear.frame.height)
        
        return touchCGRect.contains(pointInScreen)
    }

    @IBAction func startButtonWasPressed(_ sender: AnyObject) {
        runSpinAnimationOnView(view: smallGearContainer, duration: 10.0, rotations: 1, repetitions: 1)
        
        for point in pointCollection{
            let bezierPath     = spirographBezierPathForPoint(point: point)
            let bezier         = CAShapeLayer()
            bezier.path        = bezierPath.cgPath
            bezier.strokeColor = UIColor.purple.cgColor
            bezier.fillColor   = UIColor.clear.cgColor
            bezier.lineWidth   = CGFloat(3.0)
            bezier.strokeStart = CGFloat(0.0)
            bezier.strokeEnd   = CGFloat(0.5)
            self.view.layer.addSublayer(bezier)
            paths.append(bezier)
            
            let animateStrokeEnd = CABasicAnimation(keyPath:"strokeEnd")
            animateStrokeEnd.duration = 30.0;
            animateStrokeEnd.fromValue = NSNumber(value: 0.0)
            animateStrokeEnd.toValue   = NSNumber(value: 0.5)
            bezier.add(animateStrokeEnd, forKey: "strokeEndAnimation")
            
        }
    }
    

    func spirographBezierPathForPoint(point : CGPoint) -> UIBezierPath{
        let path   = UIBezierPath()
        var startPoint : CGPoint
        
        for t in  stride(from: 0.0, to: 700, by: 0.25) {

            //let
            
            let R      = bigGear.circleRadius
            let r      = smallGear.circleRadius
            let a      = Double(sqrt( pow( smallGear.center.x  - point.x , 2) + pow( smallGear.center.y  - point.y, 2)))
            let deltaR = R - r
            let ratioR = r / R
            
            
            // x(t) = (R-r)*cos((r/R) *t) + a*cos((1-(r/R))*t)
            // y(t) = (R-r)*sin((r/R) *t) - a*sin((1-(r/R))*t)
            
            let x : Double     = (deltaR) * cos( (ratioR) * t) + a * cos((1 - (ratioR)) * t)
            let y : Double     = (deltaR) * sin( (ratioR) * t) - a * sin((1 - (ratioR)) * t)
            startPoint = CGPoint(x: Double(smallGear.center.x + smallGearContainer.frame.origin.x) + x , y: Double(smallGear.center.y + smallGearContainer.frame.origin.y ) + y)
            path.addLine(to: startPoint)
            path.move(to: startPoint)
            
        }
        
        return path
    }
    
    @IBAction func clearButtonWasPressed(_ sender: UIButton) {
        if let layers = self.view.layer.sublayers {
            
            for path in paths {
                path.removeFromSuperlayer()
            }

            smallGearContainer.layer.removeAnimation(forKey: "rotationAnimation")
            
            pointCollection.removeAll()
            
        }
    }
}

