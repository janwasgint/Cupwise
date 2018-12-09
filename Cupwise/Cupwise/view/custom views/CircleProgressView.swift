//
//  Copyright © 2018 Jan Wasgint. All rights reserved.
//

import Cocoa

class CircleProgressView: NSView {
    var strokeWidth: CGFloat = 5 { didSet { updateView() } }
    var arcLength: Int = 35 { didSet { updateView() } }
    var color = NSColor.accentColor
    
    fileprivate var arcLayer = CAShapeLayer()
    fileprivate var checkmarkLayer = CAShapeLayer()
    fileprivate var finish = false
    fileprivate var reset = false
    fileprivate var completion: (() -> Void)?
    fileprivate var radius: CGFloat {
        return (self.frame.width / 2) * CGFloat(0.75)
    }
    fileprivate var rotationAnimation: CABasicAnimation = {
        var tempRotation = CABasicAnimation(keyPath: "transform.rotation")
        tempRotation.repeatCount = 1
        tempRotation.fromValue = 0.0
        tempRotation.toValue = -CGFloat(2) * CGFloat.pi
        tempRotation.duration = 1
        return tempRotation
    }()
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        configureLayers()
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        configureLayers()
    }
    
    func startAnimation() {
        isHidden = false
        fadeIn(duration: 0.5)
        rotationAnimation.delegate = self
        arcLayer.add(rotationAnimation, forKey: nil)
    }
    
    func stopAnimation(completion: @escaping () -> Void) {
        finish = true
        reset = false
        self.completion = completion
    }
    
    func reset(completion: @escaping () -> Void) {
        finish = true
        reset = true
        self.completion = completion
    }
    
    fileprivate func configureLayers() {
        updateView()
        wantsLayer = true
        
        layer?.addSublayer(arcLayer)
        layer?.addSublayer(checkmarkLayer)
        
        isHidden = true
    }
    
    fileprivate func updateView() {
        arcLayer.strokeColor = color.cgColor
        checkmarkLayer.strokeColor = color.cgColor
        arcLayer.lineWidth = strokeWidth
        checkmarkLayer.lineWidth = strokeWidth - 1
        arcLayer.fillColor = NSColor.clear.cgColor
        checkmarkLayer.fillColor = NSColor.clear.cgColor
        arcLayer.lineCap = .round
        checkmarkLayer.lineCap = .round
        arcLayer.frame = self.bounds
        checkmarkLayer.frame = self.bounds
        
        let arcPath = NSBezierPath()
        arcPath.appendArc(withCenter: self.bounds.mid, radius: radius, startAngle: 90, endAngle: -20, clockwise: true)
    
        arcLayer.path = arcPath.cgPath
    }
}

extension CircleProgressView: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if !finish {
            arcLayer.add(rotationAnimation, forKey: nil)
        } else {
            if !reset {
                animateCheckmarkAndRingClose {
                    self.fadeOut(duration: 0.5) {
                        self.cleanup()
                        self.completion?()
                    }
                }
            } else {
                self.cleanup()
                completion?()
            }
        }
    }
}

extension CircleProgressView { // Ring close animation
    fileprivate func animateCheckmarkAndRingClose(completion: @escaping () -> Void) {
        initializeCheckmarkAndRingCloseAnimation()
        drawCheckmarkAndCloseRingAnimated(completion: completion)
    }
    
    fileprivate func initializeCheckmarkAndRingCloseAnimation() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        initializeRingPath()
        initializeCheckmarkPath()
        CATransaction.commit()
        self.checkmarkLayer.isHidden = false
    }
    
    fileprivate func initializeRingPath() {
        let arcPath = NSBezierPath()
        arcPath.appendArc(withCenter: self.bounds.mid, radius: radius, startAngle: 90, endAngle: 90-360, clockwise: true)
        arcLayer.path = arcPath.cgPath
        arcLayer.strokeStart = 0
        arcLayer.strokeEnd = 0.3
    }
    
    fileprivate func initializeCheckmarkPath() {
        let side = bounds.size.width
        let checkmarkPath = NSBezierPath()
        checkmarkPath.move(to: CGPoint(x: side * 0.32, y: side * 0.5))
        checkmarkPath.line(to: CGPoint(x: side * 0.45, y: side * 0.36))
        checkmarkPath.line(to: CGPoint(x: side * 0.67, y: side * 0.6))
        checkmarkLayer.path = checkmarkPath.cgPath
        checkmarkLayer.strokeStart = 0
        checkmarkLayer.strokeEnd = 0
    }
    
    fileprivate func cleanup() {
        self.isHidden = true
        self.animator().alphaValue = 1.0
        self.checkmarkLayer.isHidden = true
        let arcPath = NSBezierPath()
        arcPath.appendArc(withCenter: self.bounds.mid, radius: self.radius, startAngle: 90, endAngle: -20, clockwise: true)
        self.arcLayer.path = arcPath.cgPath
    }
    
    fileprivate func drawCheckmarkAndCloseRingAnimated(completion: @escaping () -> Void) {
        CATransaction.begin()
        CATransaction.setDisableActions(false)
        CATransaction.setAnimationDuration(0.7)
        let timing = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        CATransaction.setAnimationTimingFunction(timing)
        arcLayer.strokeEnd = 1
        checkmarkLayer.strokeEnd = 1
        CATransaction.commit()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            completion()
        })
    }
}
