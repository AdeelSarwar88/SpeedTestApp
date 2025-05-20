//
//  PulseRingView.swift
//  SpeedTestApp
//
//  Created by Adeel Sarwar on 20/05/2025.
//

import UIKit
import Network

protocol PulseRingViewDelegate: AnyObject {
    func pulseRingView(_ pulseRingView: PulseRingView, didChangeConnectivityStatus color: UIColor)
}

class PulseRingView: UIView {

    weak var delegate: PulseRingViewDelegate? 

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")

    private let pulseLayer = CAReplicatorLayer()
    private let circle = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.width / 2
        pulseLayer.frame = bounds
        updateCirclePath()
    }

    private func sharedInit() {
        clipsToBounds = true
        setupPulse()
        startMonitoringNetwork()
    }

    private func setupPulse() {
        pulseLayer.instanceCount = 1
        layer.insertSublayer(pulseLayer, at: 0)

        circle.fillColor = UIColor.clear.cgColor
        circle.strokeColor = UIColor.systemGreen.cgColor
        circle.lineWidth = 2
        circle.lineCap = .butt
        let startAngle: CGFloat = -.pi / 2
        let endAngle: CGFloat = startAngle + .pi / 15
        let radius = min(bounds.width, bounds.height) / 2 - circle.lineWidth / 2
        let arcPath = UIBezierPath(arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
                                   radius: radius,
                                   startAngle: startAngle,
                                   endAngle: endAngle,
                                   clockwise: true)
        circle.path = arcPath.cgPath
        circle.frame = bounds

        pulseLayer.addSublayer(circle)

        let rotate = CABasicAnimation(keyPath: "transform.rotation")
        rotate.fromValue = 0
        rotate.toValue = 2 * Double.pi
        rotate.duration = 1.0
        rotate.repeatCount = .infinity
        rotate.timingFunction = CAMediaTimingFunction(name: .linear)

        pulseLayer.add(rotate, forKey: "rotatePulse")
    }

    private func updateCirclePath() {
        let diameter = min(bounds.width, bounds.height)
        let radius = diameter / 2 - circle.lineWidth / 2
        let startAngle: CGFloat = -.pi / 2
        let endAngle: CGFloat = .pi / 2.5

        let path = UIBezierPath(arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
                                radius: radius,
                                startAngle: startAngle,
                                endAngle: endAngle,
                                clockwise: true)
        circle.path = path.cgPath
        circle.frame = bounds
    }

    private func startMonitoringNetwork() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }

            DispatchQueue.main.async {
                let color: UIColor
                if path.status == .satisfied {
                    if path.usesInterfaceType(.wifi) {
                        color = UIColor.systemGreen
                    } else if path.usesInterfaceType(.cellular) {
                        color = UIColor.systemOrange
                    } else {
                        color = UIColor.systemRed
                    }
                } else {
                    color = UIColor.lightGray
                }

                self.circle.strokeColor = color.cgColor
                self.delegate?.pulseRingView(self, didChangeConnectivityStatus: color)
            }
        }

        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}
