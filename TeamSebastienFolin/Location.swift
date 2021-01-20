//
//  Location.swift
//  TeamSebastienFolin
//
//  Created by etudiant on 19/01/2021.
//  Copyright © 2021 etudiant. All rights reserved.
//

import Foundation


struct Location: Decodable {
    
    var distance : Int
    var title: String
    var location_type: String
    var woeid : Int
   
    
    enum CodingKeys: String, CodingKey {
        case distance,title, location_type, woeid
    }
    

}
