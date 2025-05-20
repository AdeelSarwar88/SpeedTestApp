//
//  ViewController.swift
//  SpeedTestApp
//
//  Created by Adeel Sarwar on 20/05/2025.
//

import UIKit

class ViewController: UIViewController, PulseRingViewDelegate {

    @IBOutlet weak var deviceName: UILabel!
    @IBOutlet weak var serverName: UILabel!
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var startLbl: UILabel!
    @IBOutlet weak var startTestView: PulseRingView!

    private let viewModel = ViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        startTestView.delegate = self

        viewModel.onDataUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.deviceName.text = self?.viewModel.deviceName
                self?.serverName.text = self?.viewModel.ispName
            }
        }

        deviceName.text = viewModel.deviceName
        serverName.text = viewModel.ispName
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        startTestView.layer.cornerRadius = startTestView.frame.width / 2
    }

    func pulseRingView(_ pulseRingView: PulseRingView, didChangeConnectivityStatus color: UIColor) {
        startLbl.textColor = color
    }
}
