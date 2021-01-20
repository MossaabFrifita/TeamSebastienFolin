//
//  ViewController.swift
//  TeamSebastienFolin
//
//  Created by etudiant on 19/01/2021.
//  Copyright © 2021 etudiant. All rights reserved.
///Users/etudiant/.gem/ruby/2.6.0/bin/pod

import UIKit
import MapKit
import Alamofire

class ViewController: UIViewController {
     let baseUrl = "https://www.metaweather.com/api/location/search/?lattlong="
     var baseUrlWeather = "https://www.metaweather.com/api/location/"
    
    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap))
        mapView.addGestureRecognizer(longTapGesture)
        
    }
    
    @objc func longTap(sender: UIGestureRecognizer){
        print("long tap")
        if sender.state == .began {
            let locationInView = sender.location(in: mapView)
            let locationOnMap = mapView.convert(locationInView, toCoordinateFrom: mapView)
            //addAnnotation(location: locationOnMap)
            print(locationOnMap.latitude)
            print(locationOnMap.longitude)
            
           let  lt = String(locationOnMap.latitude)
           let  lg = String(locationOnMap.longitude)
            
            let lattlong = "\(lt),\(lg)"
            let params = [
                "lattlong": lattlong]

            AF.request(self.baseUrl, method: .get, parameters: params, encoding: URLEncoding.default, headers: nil, interceptor: nil).responseString {
                (responseData) in
                 guard let data = responseData.data else {return}
                    do {
                    let locations = try JSONDecoder().decode([Location].self, from: data)
                        //print(locations)
                       let wd = locations[0].woeid
                        //-------------------------- GET WEATHER
                        self.baseUrlWeather += String(wd)
                        print(self.baseUrlWeather)
                        
                        AF
                            .request(self.baseUrlWeather)
                            .validate(statusCode: [200])
                            .responseDecodable(of: ConsolidatedWeather.self) {[weak self] (resp) in
                                switch resp.result {
                                case .success(let resWeather):
                                    print(resWeather.consolidated_weather[0])
                                case .failure(let error):
                                    print(error)
                                }
                            }
                        
                        //-------------------------------------
                      
                        

                    } catch {
                       print(error)
                   
                    }
                    
                }
            
        }
    }

}

extension ViewController: MKMapViewDelegate{

func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    guard annotation is MKPointAnnotation else { print("no mkpointannotaions"); return nil }
    
    let reuseId = "pin"
    var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
    
    if pinView == nil {
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView!.canShowCallout = true
        pinView!.rightCalloutAccessoryView = UIButton(type: .infoDark)
        pinView!.pinTintColor = UIColor.black
    }
    else {
        pinView!.annotation = annotation
    }
    return pinView
}
}

