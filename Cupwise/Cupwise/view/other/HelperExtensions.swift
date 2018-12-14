//
//  Copyright © 2018 Jan Wasgint. All rights reserved.
//

import Cocoa

enum ViewController {
    case login
    case setup
    case configure
    case coffee
    case credits
}

import AVFoundation

fileprivate var player: AVAudioPlayer?

func preparePaymentSound() {
    let url = Bundle.main.url(forResource: "payment_success", withExtension: "m4a")!
    do {
        player = try AVAudioPlayer(contentsOf: url)
        guard let player = player else { return }
        
        player.prepareToPlay()
    } catch let error {
        print(error.localizedDescription)
    }
}

func playPaymentSound() {
    player?.play()
}

func setClosesOnPressOutsidePopover(_ closes: Bool) {
    closesOnPressOutsidePopover = closes
    if let unwrappedMonitor = monitor as? NSObject {
        NSEvent.removeMonitor(unwrappedMonitor)
        monitor = nil
    }
    
    if closes {
        monitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { _ in
            if popover.isShown {
                closePopover()
            }
        }
    }
}

func showPopover() {
    if let button = statusItem.button {
        setClosesOnPressOutsidePopover(closesOnPressOutsidePopover)
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
    }
}

func closePopover() {
    if let unwrappedMonitor = monitor as? NSObject {
        NSEvent.removeMonitor(unwrappedMonitor)
        monitor = nil
    }
    popover.performClose(nil)
}

func switchFrom(currentViewController: NSViewController?, toViewController: ViewController) {
    if let fromVC = currentViewController {
        fromVC.view.fadeOut(duration: 0.5, completion: {
            fromVC.view.alphaValue = 0
            performSwitch(toViewController: toViewController)
        })
    } else {
        performSwitch(toViewController: toViewController)
    }
}

fileprivate func performSwitch(toViewController: ViewController) {
    let newViewController: NSViewController
    switch toViewController {
    case .login:
        let loginViewController: LoginViewController = NSStoryboard.freshViewController(withStoryboardIdentifier: NSStoryboard.StoryboardIdentifiers.loginViewController)
        newViewController = loginViewController
        setClosesOnPressOutsidePopover(false)
    case .setup:
        let setupViewController: SetupViewController = NSStoryboard.freshViewController(withStoryboardIdentifier: NSStoryboard.StoryboardIdentifiers.setupViewController)
        newViewController = setupViewController
        setClosesOnPressOutsidePopover(false)
    case .configure:
        let configureViewController: ConfigureViewController = NSStoryboard.freshViewController(withStoryboardIdentifier: NSStoryboard.StoryboardIdentifiers.configureViewController)
        newViewController = configureViewController
        setClosesOnPressOutsidePopover(true)
    case .coffee:
        let coffeeViewController: CoffeeViewController = NSStoryboard.freshViewController(withStoryboardIdentifier: NSStoryboard.StoryboardIdentifiers.coffeeViewController)
        newViewController = coffeeViewController
        setClosesOnPressOutsidePopover(true)
    case .credits:
        let creditsViewController: CreditsViewController = NSStoryboard.freshViewController(withStoryboardIdentifier: NSStoryboard.StoryboardIdentifiers.creditsViewController)
        newViewController = creditsViewController
        setClosesOnPressOutsidePopover(true)
    }
    newViewController.loadView()
    newViewController.view.alphaValue = 0
    popover.contentViewController = newViewController
    popover.contentViewController?.view.fadeIn(duration: 0.5)
}

extension Date {
    
    static func dateTimeStamp() -> String {
        return Date().toDateTimeStamp()
    }
    
    static func toDate(string: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        return dateFormatter.date(from: string)
    }
    
    func toDateTimeStamp() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        return dateFormatter.string(from: self)
    }
}

extension CGColor {
    static func colorWith(r: Int, g: Int, b: Int) -> CGColor {
        return CGColor(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: 1)
    }
}

extension NSColor {
    convenience init(r: Int, g: Int, b: Int) {
        self.init(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: 1)
    }
    
    static let uiKitBlue = NSColor(r: 0, g: 122, b: 255)
    
    static let accentColor: NSColor = {
        let mode = UserDefaults.standard.string(forKey: "AppleInterfaceStyle")
        if mode == "Dark" {
            return .white
        } else {
            return .uiKitBlue
        }
    }()
}

extension NSStoryboard {
    struct StoryboardIdentifiers {
        static let loginViewController = "LoginViewController"
        static let configureViewController = "ConfigureViewController"
        static let setupViewController = "SetupViewController"
        static let coffeeViewController = "CoffeeViewController"
        static let creditsViewController = "CreditsViewController"
    }
    
    static func freshViewController<ViewControllerType>(withStoryboardIdentifier storyboardIdentifier: String) -> ViewControllerType {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let identifier = NSStoryboard.SceneIdentifier(storyboardIdentifier)
        guard let viewController = storyboard.instantiateController(withIdentifier: identifier) as? ViewControllerType else {
            fatalError("Something went wrong with the ViewController setup.")
        }
        return viewController
    }
}

extension Double {
    func roundedWithTwoDecimalPlaces() -> Double {
        return Double((self * 100).rounded()/100)
    }
}

extension NSView {
    func pin(subview: NSView) {
        addSubview(subview)
        subview.translatesAutoresizingMaskIntoConstraints = false
        subview.frame = frame
        NSLayoutConstraint.activate([
            bottomAnchor.constraint(equalTo: subview.bottomAnchor),
            leftAnchor.constraint(equalTo: subview.leftAnchor),
            rightAnchor.constraint(equalTo: subview.rightAnchor),
            topAnchor.constraint(equalTo: subview.topAnchor)
            ])
    }
    
    static func animate(duration: Double, animations: () -> (), completion: (() -> Void)? = nil) {
        NSAnimationContext.runAnimationGroup({ (context) -> Void in
            NSAnimationContext.beginGrouping()
            context.duration = duration
            context.allowsImplicitAnimation = true
            animations()
            NSAnimationContext.endGrouping()
        }, completionHandler: {
            completion?()
        })
    }
    
    func fadeOut(duration: Double, completion: (() -> Void)? = nil) {
        NSView.animate(duration: duration, animations: {
            animator().alphaValue = 0
        }, completion: {
            completion?()
            self.alphaValue = 0
        })
    }
    
    func fadeIn(duration: Double, completion: (() -> Void)? = nil) {
        alphaValue = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            NSView.animate(duration: duration, animations: {
                self.animator().alphaValue = 1
            }, completion: {
                completion?()
            })
        })
    }
}

extension NSRect {
    var mid: CGPoint {
        return CGPoint(x: self.midX, y: self.midY)
    }
}


extension NSBezierPath {
    var cgPath: CGPath {
        let path = CGMutablePath()
        let points = UnsafeMutablePointer<NSPoint>.allocate(capacity: 3)
        let numElements = self.elementCount
        
        for index in 0..<numElements {
            let pathType = self.element(at: index, associatedPoints: points)
            switch pathType {
            case .moveTo:
                path.move(to: points[0])
            case .lineTo:
                path.addLine(to: points[0])
            case .curveTo:
                path.addCurve(to: points[2], control1: points[0], control2: points[1])
            case .closePath:
                path.closeSubpath()
            }
        }
        
        points.deallocate()
        return path
    }
}
