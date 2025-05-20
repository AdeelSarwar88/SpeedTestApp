//
//  ViewModel.swift
//  SpeedTestApp
//
//  Created by Adeel Sarwar on 20/05/2025.
//

import Foundation
import CoreTelephony
import SystemConfiguration.CaptiveNetwork
import UIKit

class ViewModel {

    private let ispInfoService = ISPInfoService()

    // Data properties
    private(set) var deviceName: String = ""
    private(set) var ispName: String = "Loading..."

    var onDataUpdated: (() -> Void)?

    init() {
        fetchDeviceName()
        fetchISPName()
    }

    private func fetchDeviceName() {
        deviceName = UIDevice.current.name
    }

    private func fetchISPName() {

        if let ssid = currentWiFiSSID() {
            ispName = ssid
            onDataUpdated?()
            return
        }

        ispInfoService.fetchISPInfo { [weak self] org in
            DispatchQueue.main.async {
                self?.ispName = org ?? "Unknown"
                self?.onDataUpdated?()
            }
        }
    }

    private func currentWiFiSSID() -> String? {
        guard let interfaces = CNCopySupportedInterfaces() as? [String] else {
            return nil
        }
        for interface in interfaces {
            if let info = CNCopyCurrentNetworkInfo(interface as CFString) as? [String: AnyObject],
               let ssid = info[kCNNetworkInfoKeySSID as String] as? String {
                return ssid
            }
        }
        return nil
    }
}
