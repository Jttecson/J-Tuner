//
//  GaugeView.swift
//  test gauge
//
//  Created by Joel Tecson on 2019-06-20.
//  Copyright © 2019 bignerdranch. All rights reserved.
//

import UIKit

class GaugeView: UIView {
    let gaugeColor = UIColor(red: 50.0/255, green: 101.0/255, blue: 148.0/255, alpha: 1)
    let gaugeWidth: CGFloat = 10

    let endAngle: CGFloat = deg2rad(-18)
    let startAngle: CGFloat = deg2rad(-162)

    let needleWidth: CGFloat = 8
    let needle = UIView()

    var value: Int = 0 {
        didSet {

            // update the value label to show the exact number
            // figure out where the needle is, between 0 and 1
            let needlePosition = CGFloat(value) / 100 + 0.5

            // create a lerp from the start angle (rotation) through to the end angle (rotation + totalAngle)
            let lerpFrom = GaugeView.deg2rad(-72)
            let lerpTo = GaugeView.deg2rad(72)

            // lerp from the start to the end position, based on the needle's position
            let needleRotation = lerpFrom + (lerpTo - lerpFrom) * needlePosition
            UIView.animate(withDuration: 0.4, animations: {
                self.needle.transform = CGAffineTransform(rotationAngle: needleRotation) })
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }

    func setUp() {
//        needle.backgroundColor = needleColor
        needle.translatesAutoresizingMaskIntoConstraints = false

        // make the needle a third of our height
        needle.bounds = CGRect(x: 0, y: 0, width: needleWidth, height: min(bounds.width,bounds.height) / 2 - gaugeWidth*3)

        // align it so that it is positioned and rotated from the bottom center
        needle.layer.anchorPoint = CGPoint(x: 0.5, y: 1)

        // now center the needle over our center point
        needle.center = CGPoint(x: bounds.midX, y: bounds.midY)
        addSubview(needle)
        
        let imageName = "needle.png"
        let image = UIImage(named: imageName)
        let imageView = UIImageView(image: image!)
        imageView.frame = needle.bounds
        needle.addSubview(imageView)
        //Imageview on Top of View
        needle.bringSubviewToFront(imageView)
    }

    func drawSegments(in rect: CGRect, context ctx: CGContext) {
        // 1: Save the current drawing configuration
        ctx.saveGState()

        // 2: Move to the center of our drawing rectangle and rotate so that we're pointing at the start of the first segment
        ctx.translateBy(x: rect.midX, y: rect.midY)

        // 3: Set up the user's line width
        ctx.setLineWidth(gaugeWidth)

        // 5: Calculate how wide the segment arcs should be
        let gaugeRadius = (min(rect.height,rect.width) / 2 - gaugeWidth)

        // activate its color
        gaugeColor.set()

        // add a path for the segment
        ctx.addArc(center: .zero, radius: gaugeRadius, startAngle: .pi-startAngle, endAngle: .pi-endAngle, clockwise: true)

        // and stroke it using the activated color
        ctx.drawPath(using: .stroke)

        // 7: Reset the graphics state
        ctx.restoreGState()
    }

    func drawTicks(in rect: CGRect, context ctx: CGContext) {
        drawMajorTicks(in: rect, context: ctx)
//        drawInnerTicks(in: rect, context: ctx)
        drawMinorTicks(in: rect, context: ctx)
    }

    let outerTickWidth: CGFloat = 4
    let outerTickLength: CGFloat = 35
    let innerTickWidth: CGFloat = 4
    let innerTickLength: CGFloat = 30
    let middleTickWidth: CGFloat = 4
    let middleTickLength: CGFloat = 35

    func drawMajorTicks(in rect: CGRect, context: CGContext) {
        drawTick(in: rect, context: context, angle: startAngle, width: outerTickWidth, length: outerTickLength, color: gaugeColor)
        drawTick(in: rect, context: context, angle: endAngle, width: middleTickWidth, length: middleTickLength, color: gaugeColor)
        drawTick(in: rect, context: context, angle: -.pi/2, width: middleTickWidth, length: middleTickLength, color: gaugeColor)
        drawTick(in: rect, context: context, angle: startAngle + .pi/10, width: innerTickWidth, length: innerTickLength, color: gaugeColor)
        drawTick(in: rect, context: context, angle: startAngle + .pi/10*2, width: innerTickWidth, length: innerTickLength, color: gaugeColor)
        drawTick(in: rect, context: context, angle: startAngle + .pi/10*3, width: innerTickWidth, length: innerTickLength, color: gaugeColor)
        drawTick(in: rect, context: context, angle: endAngle - .pi/10*3, width: innerTickWidth, length: innerTickLength, color: gaugeColor)
        drawTick(in: rect, context: context, angle: endAngle - .pi/10*2, width: innerTickWidth, length: innerTickLength, color: gaugeColor)
        drawTick(in: rect, context: context, angle: endAngle - .pi/10, width: innerTickWidth, length: innerTickLength, color: gaugeColor)
    }

    let minorTickWidth: CGFloat = 2
    let minorTickLength: CGFloat = 22

    func drawMinorTicks(in rect: CGRect, context: CGContext) {
        for i in 1...20 {
            drawTick(in: rect, context: context, angle: startAngle + .pi/50*CGFloat(i), width: minorTickWidth, length: minorTickLength, color: gaugeColor)
            drawTick(in: rect, context: context, angle: endAngle - .pi/50*CGFloat(i), width: minorTickWidth, length: minorTickLength, color: gaugeColor)
        }
    }

    func drawTick(in rect: CGRect, context ctx: CGContext, angle: CGFloat, width: CGFloat, length: CGFloat, color: UIColor) {

        ctx.saveGState()
        ctx.translateBy(x: rect.midX, y: rect.midY)
        ctx.rotate(by: angle)
        ctx.saveGState()

        let radius = ((rect.width / 2) - gaugeWidth)


        ctx.setLineWidth(width)
        color.set()

        let end = radius + (gaugeWidth / 2)
        let start = end - length

        ctx.move(to: CGPoint(x: end, y: 0))
        ctx.addLine(to: CGPoint(x: start, y: 0))
        ctx.drawPath(using: .stroke)

        ctx.restoreGState()
        ctx.restoreGState()
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        drawSegments(in: rect, context: ctx)
        drawTicks(in: rect, context: ctx)
    }

    static func deg2rad(_ number: CGFloat) -> CGFloat {
        return number * .pi / 180
    }
}
