//
//  weather.swift
//  TeamSebastienFolin
//
//  Created by etudiant on 20/01/2021.
//  Copyright © 2021 etudiant. All rights reserved.
//

import Foundation



struct ConsolidatedWeather : Decodable {
    
    var consolidated_weather = [weather]()
    
    enum CodingKeys: String, CodingKey {
        case consolidated_weather
    }
}


struct weather : Decodable {


    var weather_state_name : String
    var weather_state_abbr : String
    var the_temp : Double
    var air_pressure : Double
    var humidity : Double
    var visibility : Double
    var min_temp: Double
    var max_temp: Double
    var wind_direction: Double
    var wind_direction_compass : String
    enum CodingKeys: String, CodingKey {
        case weather_state_name,weather_state_abbr, the_temp, air_pressure, humidity, visibility, min_temp, max_temp, wind_direction, wind_direction_compass
    }
    
}
    


