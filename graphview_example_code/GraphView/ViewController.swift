//
//  Simple example usage of ScrollableGraphView.swift
//  #######################################
//

import UIKit

class LargeLabel: UILabel {

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width*1.5, height: size.height*2)
    }
}

enum GraphType: Int {
    case dark = 0
    case bar
    case dot
    case pink

    mutating func next() {
        guard let nextType = GraphType(rawValue: self.rawValue + 1) else {
            self = .dark
            return
        }
        self = nextType
    }
}

class ViewController: UIViewController {

    @IBOutlet var graphView: ScrollableGraphView!
    var graphType: GraphType = .dark {
        didSet {
            switch graphType {
            case .dark:
                label.text = "DARK"
                setupDarkGraph(graphView)
            case .dot:
                label.text = "DOT"
                setupDotGraph(graphView)
            case .bar:
                label.text = "BAR"
                setupBarGraph(graphView)
            case .pink:
                label.text = "PINK"
                setupPinkMountainGraph(graphView)
            }

        }
    }

    var label = LargeLabel()

    // Data
    let numberOfDataItems = 29

    lazy var data: [Double] = self.generateRandomData(self.numberOfDataItems, max: 50)
    lazy var labels: [String] = self.generateSequentialLabels(self.numberOfDataItems, text: "FEB")

    override func viewDidLoad() {
        super.viewDidLoad()

        // note: setting the data will clear any graph configuration
        graphView.set(data: data, withLabels: labels)

        graphType = .dark

        self.view.addSubview(graphView)
        
        setupLabel()
        label.text = "DARK (TAP HERE)"
    }
    
    func didTap(_ gesture: UITapGestureRecognizer) {
        
        graphType.next()

        graphView.set(data: data, withLabels: labels)

        graphView.setup()
    }

    fileprivate func setupDarkGraph(_ graphView: ScrollableGraphView) {

        graphView.backgroundFillColor = UIColor.colorFromHex(hexString: "#333333")
        
        graphView.lineWidth = 1
        graphView.lineColor = UIColor.colorFromHex(hexString: "#777777")
        graphView.lineStyle = .smooth

        graphView.fillType = .gradient
        graphView.fillGradientType = .linear
        graphView.fillGradientStartColor = UIColor.colorFromHex(hexString: "#555555")
        graphView.fillGradientEndColor = UIColor.colorFromHex(hexString: "#444444")

        graphView.dataPointType = .circle
        graphView.dataPointSpacing = 80
        graphView.dataPointSize = 2
        graphView.dataPointFillColor = .white

        graphView.referenceLineLabelFont = UIFont.boldSystemFont(ofSize: 8)
        graphView.referenceLineColor = UIColor.white.withAlphaComponent(0.2)
        graphView.referenceLineLabelColor = .white
        graphView.numberOfIntermediateReferenceLines = 5 // horizontal lines
        graphView.dataPointLabelColor = UIColor.white.withAlphaComponent(0.5)
        
        graphView.shouldAnimateOnStartup = true
        graphView.shouldAdaptRange = true
        graphView.adaptAnimationType = .elastic
        graphView.animationDuration = 1.5
        graphView.rangeMax = 50
        graphView.shouldRangeAlwaysStartAtZero = true
    }
    
    private func setupBarGraph(_ graphView: ScrollableGraphView) {

        graphView.resetConfiguration()

        graphView.shouldDrawBarLayer = true

        graphView.lineColor = .clear
        graphView.barWidth = 25
        graphView.barLineWidth = 1
        graphView.barLineColor = UIColor.colorFromHex(hexString: "#777777")
        graphView.barColor = UIColor.colorFromHex(hexString: "#555555")
        graphView.backgroundFillColor = UIColor.colorFromHex(hexString: "#333333")
        
        graphView.referenceLineLabelFont = UIFont.boldSystemFont(ofSize: 8)
        graphView.referenceLineColor = UIColor.white.withAlphaComponent(0.2)
        graphView.referenceLineLabelColor = .white
        graphView.numberOfIntermediateReferenceLines = 5
        graphView.dataPointLabelColor = UIColor.white.withAlphaComponent(0.5)
        
        graphView.shouldAnimateOnStartup = true
        graphView.shouldAdaptRange = true
        graphView.adaptAnimationType = ScrollableGraphViewAnimationType.elastic
        graphView.animationDuration = 1.5
        graphView.rangeMax = 50
        graphView.shouldRangeAlwaysStartAtZero = true
        
    }
    
    private func setupDotGraph(_ graphView: ScrollableGraphView) {

        graphView.resetConfiguration()

        graphView.backgroundFillColor = UIColor.colorFromHex(hexString: "#00BFFF")
        graphView.lineColor = .clear

        graphView.dataPointType = .circle
        graphView.dataPointSize = 5
        graphView.dataPointSpacing = 80
        graphView.dataPointLabelFont = UIFont.boldSystemFont(ofSize: 10)
        graphView.dataPointLabelColor = .white
        graphView.dataPointFillColor = .white
        
        graphView.referenceLineLabelFont = UIFont.boldSystemFont(ofSize: 10)
        graphView.referenceLineColor = UIColor.white.withAlphaComponent(0.5)
        graphView.referenceLineLabelColor = .white
        graphView.referenceLinePosition = ScrollableGraphViewReferenceLinePosition.both
        
        graphView.numberOfIntermediateReferenceLines = 9
        
        graphView.rangeMax = 50
        
    }
    
    private func setupPinkMountainGraph(_ graphView: ScrollableGraphView) {

        graphView.resetConfiguration()

        graphView.backgroundFillColor = UIColor.colorFromHex(hexString: "#222222")
        graphView.lineColor = .clear
        graphView.fillColor = UIColor.colorFromHex(hexString: "#FF0080")

        graphView.fillType = .solid
        graphView.shouldAnimateOnStartup = false
        
        graphView.dataPointSpacing = 20
        graphView.dataPointLabelFont = UIFont.boldSystemFont(ofSize: 10)
        graphView.dataPointLabelColor = .white
      
        graphView.dataPointLabelsSparsity = 3

        graphView.referenceLineThickness = 1
        graphView.referenceLineLabelFont = UIFont.boldSystemFont(ofSize: 10)
        graphView.referenceLineColor = UIColor.white.withAlphaComponent(0.5)
        graphView.referenceLineLabelColor = .white
        graphView.referenceLinePosition = ScrollableGraphViewReferenceLinePosition.both
        
        graphView.numberOfIntermediateReferenceLines = 1
        
        graphView.shouldAdaptRange = true
        
        graphView.rangeMax = 50
    }

    // Adding and updating the graph switching label in the top right corner of the screen.
    private func setupLabel() {

        label.isUserInteractionEnabled = true
        label.backgroundColor = UIColor.black.withAlphaComponent(0.5)

        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 14)

        label.layer.cornerRadius = 2
        label.clipsToBounds = true

        label.translatesAutoresizingMaskIntoConstraints = false

        self.view.insertSubview(label, aboveSubview: graphView)

        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: label, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1, constant: -20),
            NSLayoutConstraint(item: label, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 20),
        ])
        
        let tapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(didTap))
        label.addGestureRecognizer(tapGestureRecogniser)
    }

    // Data Generation
    private func generateRandomData(_ numberOfItems: Int, max: Double) -> [Double] {
        var data = [Double]()
        for _ in 0 ..< numberOfItems {
            var randomNumber = Double(arc4random()).truncatingRemainder(dividingBy: max)
            
            if(arc4random() % 100 < 10) {
                randomNumber *= 3
            }
            
            data.append(randomNumber)
        }
        return data
    }
    
    private func generateSequentialLabels(_ numberOfItems: Int, text: String) -> [String] {
        var labels = [String]()
        for i in 0 ..< numberOfItems {
            labels.append("\(text) \(i+1)")
        }
        return labels
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }
}

