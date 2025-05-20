//
//  ISPInfoService.swift
//  SpeedTestApp
//
//  Created by Adeel Sarwar on 20/05/2025.
//

import Foundation

class ISPInfoService {

    struct ISPResponse: Codable {
        let ip: String
        let hostname: String?
        let city: String?
        let region: String?
        let country: String?
        let loc: String?
        let org: String? 
        let postal: String?
        let timezone: String?
    }

    func fetchISPInfo(completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "https://ipinfo.io/json") else {
            completion(nil)
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }

            do {
                let response = try JSONDecoder().decode(ISPResponse.self, from: data)
                completion(response.org)
            } catch {
                completion(nil)
            }
        }

        task.resume()
    }
}
