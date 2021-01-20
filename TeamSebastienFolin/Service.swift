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
    
    typealias locationsCallBack = (_ locations:[Location]?, _ status: Bool, _ message:String) -> Void
    var callBack:locationsCallBack?
    
    var listOfLocations: [Location] = []
    
    init(baseUrl: String) {
          self.baseUrl = baseUrl
      }
    

    
    func getLocationWoeid(latlong:String) {
        print(self.baseUrl+latlong)
        
        

        let params = [
             "lattlong": latlong]

 AF.request(self.baseUrl, method: .get, parameters: params, encoding: URLEncoding.default, headers: nil, interceptor: nil).responseString {
     
     (responseData) in
     
      guard let data = responseData.data else {return}
        // self.callBack?(nil, false, "") ; return }
     //print(responseData)
     
         do {
             print("mossaab fr")
         let locations = try JSONDecoder().decode([Location].self, from: data)
             print(locations)
            let wd = locations[0].distance
            print( wd)
             
             //self.callBack?(locations, true,"")
         } catch {
            print("errrrrrrr")
             //self.callBack?(nil, false, error.localizedDescription)
         }
         
     }
    }
    
    func completionHandler(callBack: @escaping locationsCallBack) {
        self.callBack = callBack
    }
        
    }

