//
//  DrawingLayers.swift
//  GraphView
//
//  Created by Jay Moore on 2017-03-24.
//
//

import UIKit

// MARK: - Drawing Layers

// MARK: Delegate definition that provides the data required by the drawing layers.
protocol ScrollableGraphViewDrawingDelegate {
    func intervalForActivePoints() -> CountableRange<Int>
    func rangeForActivePoints() -> (min: Double, max: Double)
    func graphPoint(forIndex index: Int) -> GraphPoint

    func currentPath() -> UIBezierPath
}

// MARK: Drawing Layer Classes

// MARK: Base Class
class ScrollableGraphViewDrawingLayer : CAShapeLayer {

    var offset: CGFloat = 0 {
        didSet {
            offsetDidChange()
        }
    }

    var viewportWidth: CGFloat
    var viewportHeight: CGFloat
    var zeroYPosition: CGFloat = 0

    var graphViewDrawingDelegate: ScrollableGraphViewDrawingDelegate?

    var active = true

    init(viewportWidth: CGFloat, viewportHeight: CGFloat, offset: CGFloat = 0) {
        self.viewportWidth = viewportWidth
        self.viewportHeight = viewportHeight
        super.init()

        self.frame = CGRect(origin: CGPoint(x: offset, y: 0), size: CGSize(width: viewportWidth, height: viewportHeight))

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        // Get rid of any animations.
        self.actions = ["position" : NSNull(), "bounds" : NSNull()]
    }

    private func offsetDidChange() {
        self.frame.origin.x = offset
        self.bounds.origin.x = offset
    }

    func updatePath() {
        fatalError("updatePath needs to be implemented by the subclass")
    }
}

// MARK: Drawing the bars
class BarDrawingLayer: ScrollableGraphViewDrawingLayer {

    private var barPath = UIBezierPath()
    private var barWidth: CGFloat
    private var shouldRoundCorners: Bool

    init(frame: CGRect, barWidth: CGFloat, barColor: UIColor, barLineWidth: CGFloat, barLineColor: UIColor, shouldRoundCorners: Bool) {

        self.barWidth = barWidth
        self.shouldRoundCorners = shouldRoundCorners

        super.init(viewportWidth: frame.size.width, viewportHeight: frame.size.height)
        self.lineWidth = barLineWidth
        self.strokeColor = barLineColor.cgColor
        self.fillColor = barColor.cgColor

        self.lineJoin = lineJoin
        self.lineCap = lineCap
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createBarPath(centre: CGPoint) -> UIBezierPath {

        let barWidthOffset: CGFloat = self.barWidth / 2

        let origin = CGPoint(x: centre.x - barWidthOffset, y: centre.y)
        let size = CGSize(width: barWidth, height: zeroYPosition - centre.y)
        let rect = CGRect(origin: origin, size: size)

        let barPath: UIBezierPath = {
            if shouldRoundCorners {
                return UIBezierPath(roundedRect: rect, cornerRadius: barWidthOffset)
            } else {
                return UIBezierPath(rect: rect)
            }
        }()

        return barPath
    }

    private func createPath () -> UIBezierPath {

        barPath.removeAllPoints()

        // We can only move forward if we can get the data we need from the delegate.
        guard let
            activePointsInterval = self.graphViewDrawingDelegate?.intervalForActivePoints()
            else {
                return barPath
        }

        for i in activePointsInterval {

            var location = CGPoint.zero

            if let pointLocation = self.graphViewDrawingDelegate?.graphPoint(forIndex: i).location {
                location = pointLocation
            }

            let pointPath = createBarPath(centre: location)
            barPath.append(pointPath)
        }

        return barPath
    }

    override func updatePath() {

        self.path = createPath ().cgPath
    }

}

// MARK: Drawing the Graph Line
class LineDrawingLayer : ScrollableGraphViewDrawingLayer {

    init(frame: CGRect, lineWidth: CGFloat, lineColor: UIColor, lineStyle: ScrollableGraphViewLineStyle, lineJoin: String, lineCap: String) {
        super.init(viewportWidth: frame.size.width, viewportHeight: frame.size.height)

        self.lineWidth = lineWidth
        self.strokeColor = lineColor.cgColor

        self.lineJoin = lineJoin
        self.lineCap = lineCap

        // Setup
        self.fillColor = UIColor.clear.cgColor // This is handled by the fill drawing layer.
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updatePath() {
        self.path = graphViewDrawingDelegate?.currentPath().cgPath
    }
}

// MARK: Drawing the Individual Data Points
class DataPointDrawingLayer: ScrollableGraphViewDrawingLayer {

    private var dataPointPath = UIBezierPath()
    private var dataPointSize: CGFloat
    private var dataPointType: ScrollableGraphViewDataPointType

    private var customDataPointPath: ((_ centre: CGPoint) -> UIBezierPath)?

    init(frame: CGRect, fillColor: UIColor, dataPointType: ScrollableGraphViewDataPointType, dataPointSize: CGFloat, customDataPointPath: ((_ centre: CGPoint) -> UIBezierPath)? = nil) {

        self.dataPointType = dataPointType
        self.dataPointSize = dataPointSize
        self.customDataPointPath = customDataPointPath

        super.init(viewportWidth: frame.size.width, viewportHeight: frame.size.height)

        self.fillColor = fillColor.cgColor
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createDataPointPath() -> UIBezierPath {

        dataPointPath.removeAllPoints()

        // We can only move forward if we can get the data we need from the delegate.
        guard let
            activePointsInterval = self.graphViewDrawingDelegate?.intervalForActivePoints()
            else {
                return dataPointPath
        }

        let pointPathCreator = getPointPathCreator()

        for i in activePointsInterval {

            var location = CGPoint.zero

            if let pointLocation = self.graphViewDrawingDelegate?.graphPoint(forIndex: i).location {
                location = pointLocation
            }

            let pointPath = pointPathCreator(location)
            dataPointPath.append(pointPath)
        }

        return dataPointPath
    }

    private func createCircleDataPoint(centre: CGPoint) -> UIBezierPath {
        return UIBezierPath(arcCenter: centre, radius: dataPointSize, startAngle: 0, endAngle: CGFloat(2.0 * M_PI), clockwise: true)
    }

    private func createSquareDataPoint(centre: CGPoint) -> UIBezierPath {

        // TODO: use UIBezierPath(rect:)
        let squarePath = UIBezierPath()

        squarePath.move(to: centre)

        let topLeft = CGPoint(x: centre.x - dataPointSize, y: centre.y - dataPointSize)
        let topRight = CGPoint(x: centre.x + dataPointSize, y: centre.y - dataPointSize)
        let bottomLeft = CGPoint(x: centre.x - dataPointSize, y: centre.y + dataPointSize)
        let bottomRight = CGPoint(x: centre.x + dataPointSize, y: centre.y + dataPointSize)

        squarePath.move(to: topLeft)
        squarePath.addLine(to: topRight)
        squarePath.addLine(to: bottomRight)
        squarePath.addLine(to: bottomLeft)
        squarePath.addLine(to: topLeft)

        return squarePath
    }

    private func getPointPathCreator() -> (_ centre: CGPoint) -> UIBezierPath {
        switch(self.dataPointType) {
        case .circle:
            return createCircleDataPoint
        case .square:
            return createSquareDataPoint
        case .custom:
            if let customCreator = self.customDataPointPath {
                return customCreator
            }
            else {
                // We don't have a custom path, so just return the default.
                fallthrough
            }
        default:
            return createCircleDataPoint
        }
    }

    override func updatePath() {
        self.path = createDataPointPath().cgPath
    }
}

// MARK: Drawing the Graph Gradient Fill
class GradientDrawingLayer : ScrollableGraphViewDrawingLayer {

    private var startColor: UIColor
    private var endColor: UIColor
    private var gradientType: ScrollableGraphViewGradientType

    lazy private var gradientMask: CAShapeLayer = ({
        let mask = CAShapeLayer()

        mask.frame = CGRect(x: 0, y: 0, width: self.viewportWidth, height: self.viewportHeight)
        mask.fillRule = kCAFillRuleEvenOdd
        mask.path = self.graphViewDrawingDelegate?.currentPath().cgPath
        mask.lineJoin = self.lineJoin

        return mask
    })()

    init(frame: CGRect, startColor: UIColor, endColor: UIColor, gradientType: ScrollableGraphViewGradientType, lineJoin: String = kCALineJoinRound) {
        self.startColor = startColor
        self.endColor = endColor
        self.gradientType = gradientType
        //self.lineJoin = lineJoin

        super.init(viewportWidth: frame.size.width, viewportHeight: frame.size.height)

        addMaskLayer()
        self.setNeedsDisplay()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addMaskLayer() {
        self.mask = gradientMask
    }

    override func updatePath() {
        gradientMask.path = graphViewDrawingDelegate?.currentPath().cgPath
    }

    override func draw(in ctx: CGContext) {

        let colors = [startColor.cgColor, endColor.cgColor]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let locations: [CGFloat] = [0.0, 1.0]
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: locations)

        let displacement = ((viewportWidth / viewportHeight) / 2.5) * self.bounds.height
        let topCentre = CGPoint(x: offset + self.bounds.width / 2, y: -displacement)
        let bottomCentre = CGPoint(x: offset + self.bounds.width / 2, y: self.bounds.height)
        let startRadius: CGFloat = 0
        let endRadius: CGFloat = self.bounds.width

        switch(gradientType) {
        case .linear:
            ctx.drawLinearGradient(gradient!, start: topCentre, end: bottomCentre, options: .drawsAfterEndLocation)
        case .radial:
            ctx.drawRadialGradient(gradient!, startCenter: topCentre, startRadius: startRadius, endCenter: topCentre, endRadius: endRadius, options: .drawsAfterEndLocation)
        }
    }
}

// MARK: Drawing the Graph Fill
class FillDrawingLayer : ScrollableGraphViewDrawingLayer {

    init(frame: CGRect, fillColor: UIColor) {
        super.init(viewportWidth: frame.size.width, viewportHeight: frame.size.height)
        self.fillColor = fillColor.cgColor
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updatePath() {
        self.path = graphViewDrawingDelegate?.currentPath().cgPath
    }
}
