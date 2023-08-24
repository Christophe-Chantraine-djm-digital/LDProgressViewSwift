//
//  LDProgressViewSwift.swift
//  RealiBox
//
//  Created by wxh on 2018/12/20.
//  Copyright © 2018 wxh. All rights reserved.
//

import UIKit

// Enum representing the types of progress visualization
public enum LDProgressType {
    case stripes
    case gradient
    case solid
}

open class LDProgressView: UIView {
    
    /// The type of progress bar used, which can be either stripes or gradient.
    public var type = LDProgressType.stripes

    private var _progress: Float = 0.0
    
    /// The current progress value of the progress bar.
    open var progress: Float {
        set {
            // Set the target progress for animation
            self.progressToAnimateTo = newValue
            
            // Check if animation is enabled
            if self.animate {
                // Invalidate any existing animation timer
                if self.animationTimer != nil {
                    self.animationTimer!.invalidate()
                }
                
                // Schedule a new animation timer
                self.animationTimer = Timer.scheduledTimer(timeInterval: 0.008, target: self, selector: #selector(incrementAnimatingProgress), userInfo: nil, repeats: true)
            } else {
                // Update the progress value and trigger a redraw
                _progress = newValue
                self.setNeedsDisplay()
            }
        }
        get {
            return _progress
        }
    }
    
    /// The progress value used for label display.
    public var labelProgress: Float = 0.0
    
    /// The target progress value for animation.
    public var progressToAnimateTo: Float = 0.0
    
    /// The timer used for handling animation.
    public var animationTimer: Timer?

    
    private var _gradientProgress: UIImage?
    
    /// A gradient image for the progress bar.
    public var gradientProgress: UIImage {
        get {
            if _gradientProgress == nil {
                UIGraphicsBeginImageContext(self.stripeSize)
                let imageCxt = UIGraphicsGetCurrentContext()
                
                let colorSpace = CGColorSpaceCreateDeviceRGB()
                let locations: [CGFloat] = [CGFloat(0.0), CGFloat(0.5), CGFloat(1.0)]
                let colors = [UIColor.clear.cgColor, self.color.darker.darker.withAlphaComponent(0.3).cgColor, UIColor.clear.cgColor]
                
                let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: locations)!
                
                imageCxt?.drawLinearGradient(gradient,
                                             start: CGPoint(x: 0, y: self.stripeSize.height / 2.0),
                                             end: CGPoint(x: self.stripeSize.width, y: self.stripeSize.height / 2.0),
                                             options: .drawsBeforeStartLocation)
                _gradientProgress = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
            }
            return _gradientProgress!
        }
        set {
            _gradientProgress = newValue
        }
    }
    
    /// The color of the progress bar.
    public var color: UIColor = UIColor.RGB(0.07, 0.56, 1.0) {
        didSet {
            // Reset the gradient progress image when the color changes
            _gradientProgress = nil
        }
    }
    
    /// The background color of the progress bar.
    public var background: UIColor = UIColor.RGB(0.51, 0.51, 0.51)
    
    /// Determines whether the progress bar has a flat style.
    public var flat: Bool = false
    
    /// Determines whether the progress bar animation is enabled.
    public var animate = true {
        didSet {
            if animate {
                // Start or stop the animation timer based on the animate setting
                self.timer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(incrementOffset), userInfo: nil, repeats: true)
            } else if self.timer != nil {
                self.timer!.invalidate()
                self.timer = nil
            }
        }
    }

    
    /// Determines whether the progress text label is displayed.
    open var showText = true
    
    /// Determines whether the outer stroke is displayed.
    open var showStroke = true
    
    /// Determines whether the progress background is displayed.
    open var showBackground = true
    
    /// Determines whether the background inner shadow effect is displayed.
    open var showBackgroundInnerShadow = true
    
    /// The width of the outer stroke.
    open var outerStrokeWidth: Float?
    
    /// The inset for the progress bar.
    open var progressInset: Float?
    
    /// An optional override for the progress text label.
    open var progressTextOverride: String?
    
    /// Overrides the default progress text with a custom string.
    /// - Parameter progressText: The custom progress text to display.
    func overrideProgressText(_ progressText: String) {
        self.progressTextOverride = progressText
        
        // Trigger a redraw of the view to display the updated text
        self.setNeedsDisplay()
    }

    private var _borderRadius: Float?
    
    /// The radius of the corner for the progress bar's rounded rectangle.
    /// If not explicitly set, it defaults to half of the view's height.
    public var borderRadius: Float {
        get {
            if _borderRadius == nil {
                return Float(self.frame.size.height / 2.0)
            } else {
                return _borderRadius!
            }
        }
        set {
            _borderRadius = newValue
        }
    }
    
    /// The width of the stripes in the progress bar, varies based on the type of progress.
    open var stripeWidth: Float {
        get {
            switch type {
                case .gradient:
                    return 15.0
                default:
                    return 50
            }
        }
    }
    
    /// The size of the stripes in the progress bar.
    open var stripeSize: CGSize = CGSize(width: 0, height: 0)
    
    /// The offset for creating animation of stripes.
    open var offset: Float = 0.0
    
    /// The timer used for handling animation.
    open var timer: Timer?
    /// Initializes the progress bar with a specified frame.
    /// - Parameter frame: The frame for the progress bar.
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    /// Required initializer when creating the view from a storyboard or nib.
    /// - Parameter aDecoder: The NSCoder instance used for decoding.
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    /// Increments the offset value for creating animation of stripes and triggers a redraw.
    @objc func incrementOffset() {
        if self.offset >= 0 {
            self.offset = -self.stripeWidth
        } else {
            self.offset += 1
        }
        self.setNeedsDisplay()
    }

    /// Incrementally adjusts the progress value for animation purposes and triggers a redraw.
    @objc func incrementAnimatingProgress() {
        if self.progress >= self.progressToAnimateTo - 0.01 && self.progress <= self.progressToAnimateTo + 0.01 {
            _progress = self.progressToAnimateTo
            self.animationTimer?.invalidate()
        } else {
            _progress = _progress < self.progressToAnimateTo ? _progress + 0.01 : _progress - 0.01
        }
        self.setNeedsDisplay()
    }
    
    private func initialize() {
        self.backgroundColor = .clear
    }
}

//MARK: - Draw
extension LDProgressView {
    
    /// Custom drawing method that handles drawing the progress bar based on the provided settings.
    /// - Parameter rect: The rectangle in which the progress bar will be drawn.
    override open func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        
        if self.showBackground {
            self.drawProgressBackground(context: context, rect: rect)
        }
        
        if self.outerStrokeWidth != nil {
            self.drawOuterStroke(context: context, rect: rect)
        }
        if self.progress > 0.0 {
            let  inset = self.progressInset ?? 0
            self.drawProgress(context: context, frame: self.progressInset == nil ? rect : rect.insetBy(dx: CGFloat(inset), dy: CGFloat(inset)))
        }
    }
    
    /// Draws the background of the progress bar with various effects using a given graphics context within the specified rectangle.
    /// - Parameters:
    ///   - context: The graphics context in which the progress background will be drawn.
    ///   - rect: The rectangle in which the progress background will be drawn.
    func drawProgressBackground(context: CGContext, rect: CGRect) {
        context.saveGState()
        
        let roundedRect = UIBezierPath(roundedRect: rect, cornerRadius: CGFloat(self.borderRadius))
        context.setFillColor(self.background.cgColor)
        roundedRect.fill()
        
        let roundedRectangleNegativePath = UIBezierPath(rect: CGRect(x: -10, y: -10, width: rect.size.width + 10, height: rect.size.height + 10))
        roundedRectangleNegativePath.append(roundedRect)
        roundedRectangleNegativePath.usesEvenOddFillRule = true
        
        if self.showBackgroundInnerShadow {
            let shadowOffset = CGSize(width: 0.5, height: 1)
            context.saveGState()
            let xOffset = shadowOffset.width + round(rect.size.width)
            let yOffset = shadowOffset.height
            context.setShadow(offset: CGSize(width: xOffset + copysign(0.1, xOffset), height: yOffset + copysign(0.1, yOffset)),
                              blur: 5,
                              color: UIColor.black.withAlphaComponent(0.7).cgColor)
        }
        roundedRect.addClip()
        let transform = CGAffineTransform(translationX: CGFloat(-roundf(Float(rect.size.width))), y: 0)
        roundedRectangleNegativePath.apply(transform)
        UIColor.gray.setFill()
        
        roundedRectangleNegativePath.fill()
        context.restoreGState()
        roundedRect.addClip()
    }
    
    /// Draws an outer stroke around the specified rectangle using a given graphics context.
    /// - Parameters:
    ///   - context: The graphics context in which the outer stroke will be drawn.
    ///   - rect: The rectangle around which the outer stroke will be drawn.
    func drawOuterStroke(context: CGContext, rect: CGRect) {
        let outerStrokeWidth = self.outerStrokeWidth ?? 0
        let bezierPath = UIBezierPath(roundedRect: rect.insetBy(dx: CGFloat(outerStrokeWidth / 2.0), dy: CGFloat(outerStrokeWidth / 2.0)), cornerRadius: CGFloat(self.borderRadius))
        self.color.setStroke()
        bezierPath.lineWidth = CGFloat(outerStrokeWidth)
        bezierPath.stroke()
    }
    
    /// Draws progress with various visual effects using a given graphics context within the specified frame.
    /// - Parameters:
    ///   - context: The graphics context in which the progress will be drawn.
    ///   - frame: The frame within which the progress will be drawn.
    func drawProgress(context: CGContext, frame: CGRect) {
        let rectToDrawIn = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width * CGFloat(self.progress), height: frame.size.height)
        var insetRect = rectToDrawIn.insetBy(dx: self.progress > 0.03 ? 0.5 : -0.5, dy: 0.5)
        
        if self.showText {
            insetRect = rectToDrawIn
        }
        
        let roundedRect = UIBezierPath(roundedRect: insetRect, cornerRadius: CGFloat(self.borderRadius))
        
        if self.flat {
            context.setFillColor(self.color.cgColor)
            roundedRect.fill()
        } else {
            context.saveGState()
            roundedRect.addClip()
            
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let locations: [CGFloat] = [CGFloat(0.0), CGFloat(1.0)]
            let colors = [self.color.lighter.cgColor, self.color.darker.cgColor]
            
            let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: locations)!
            
            context.drawLinearGradient(gradient,
                                       start: CGPoint(x: insetRect.size.width / 2.0, y: 0),
                                       end: CGPoint(x: insetRect.size.width / 2.0, y: insetRect.size.height),
                                       options: .drawsBeforeStartLocation)
            _gradientProgress = UIGraphicsGetImageFromCurrentImageContext()
            context.restoreGState()
        }
        
        if self.progress != 1.0 {
            switch self.type {
            case .gradient:
                self.drawGradients(context: context, rect: insetRect)
            case .stripes:
                self.drawStripes(context: context, rect: insetRect)
            default: break
            }
        }
        
        if self.showStroke {
            context.setStrokeColor(self.color.darker.darker.cgColor)
            roundedRect.stroke()
        }
        if self.showText {
            self.drawRightAlignedLabelInRect(insetRect)
        }
    }
    
    /// Draws gradients using a given graphics context within the specified rectangle.
    /// - Parameters:
    ///   - context: The graphics context in which the gradients will be drawn.
    ///   - rect: The rectangle in which the gradients will be drawn.
    func drawGradients(context: CGContext, rect: CGRect) {
        self.stripeSize = CGSize(width: CGFloat(self.stripeWidth), height: rect.size.height)
        context.saveGState()
        UIBezierPath(roundedRect: rect, cornerRadius: CGFloat(self.borderRadius)).addClip()
        
        var xStart = self.offset
        while xStart < Float(rect.size.width) {
            self.gradientProgress.draw(at: CGPoint(x: Int(xStart), y: 0))
            xStart += self.stripeWidth
        }
        context.restoreGState()
    }
    
    /// Draws diagonal stripes using a given graphics context within the specified rectangle.
    /// - Parameters:
    ///   - context: The graphics context in which the stripes will be drawn.
    ///   - rect: The rectangle in which the stripes will be drawn.
    func drawStripes(context: CGContext, rect: CGRect) {
        context.saveGState()
        UIBezierPath(roundedRect: rect, cornerRadius: CGFloat(self.borderRadius)).addClip()
        context.setFillColor(UIColor.white.withAlphaComponent(0.2).cgColor)
        
        
        var xStart = self.offset
        let height = rect.size.height
        let width = self.stripeWidth
        let y = rect.origin.y
        
        while xStart < Float(rect.size.width) {
            context.saveGState()
            context.move(to: CGPoint(x: CGFloat(xStart), y: CGFloat(height) + y))
            context.addLine(to: CGPoint(x: CGFloat(xStart + width * 0.25), y: CGFloat(0)))
            context.addLine(to: CGPoint(x: CGFloat(xStart + width * 0.75), y: CGFloat(0)))
            context.addLine(to: CGPoint(x: CGFloat(xStart + width * 0.50), y: CGFloat(height) + y))
            context.closePath()
            context.fillPath()
            context.restoreGState()
            xStart += width
        }
        context.restoreGState()
    }
    
    /// Draws a right-aligned label within the given rectangle, if the width of the rectangle is greater than 40.
    /// - Parameter rect: The rectangle in which the label should be drawn.
    func drawRightAlignedLabelInRect(_ rect: CGRect) {
        if rect.size.width > 40 {
            let label = UILabel(frame: rect)
            label.adjustsFontSizeToFitWidth = true
            label.backgroundColor = .clear
            label.textAlignment = .right
            label.text = self.progressTextOverride == nil ? String(format: "%.0f%%", self.progress * 100) : self.progressTextOverride!
            label.font = UIFont.boldSystemFont(ofSize: CGFloat(17 - (self.progressInset ?? 0) * 1.75))
            
            if self.color.isLighter {
                label.textColor = UIColor.black.withAlphaComponent(0.6)
            } else {
                label.textColor = UIColor.white.withAlphaComponent(0.6)
            }
            label.drawText(in: CGRect(x: rect.origin.x + 6, y: rect.origin.y, width: rect.size.width - 12, height: rect.size.height))
        }
    }
}
