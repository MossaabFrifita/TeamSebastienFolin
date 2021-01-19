//
//  Service.swift
//  TeamSebastienFolin
//
//  Created by etudiant on 19/01/2021.
//  Copyright © 2021 etudiant. All rights reserved.
//

import Foundation
import Alamofire

class Service {
    fileprivate var baseUrl = ""
    
    init(baseUrl: String) {
          self.baseUrl = baseUrl
      }
    
    
    func getLocationWoeid(latlong:String) {
    AF.request(self.baseUrl + latlong, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil, interceptor: nil).response {
        
        (responseData) in
        
        print("we got the response mossaab ye maalem")
        }
        
    }
}
