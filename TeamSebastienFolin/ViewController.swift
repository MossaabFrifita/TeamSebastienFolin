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
        
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
        }else{
            print("Internet Connection not Available!")
            let alert = UIAlertController(title: "Connexion internet", message: "Pour le fonctionnement de l'application une connexion internet est requise", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        mapView.delegate = self
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap))
        mapView.addGestureRecognizer(longTapGesture)
        
    }
    
    @objc func longTap(sender: UIGestureRecognizer){
        print("long tap")
        if sender.state == .began {
            let locationInView = sender.location(in: mapView)
            let locationOnMap = mapView.convert(locationInView, toCoordinateFrom: mapView)
            
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
                        print(locations[0].title)
                        //-------------------------- GET WEATHER
                        
                        print(self.baseUrlWeather)
                        
                        AF
                            .request(self.baseUrlWeather+String(wd))
                            .validate(statusCode: [200])
                            .responseDecodable(of: ConsolidatedWeather.self) {[weak self] (resp) in
                                switch resp.result {
                                case .success(let resWeather):
                                    print(resWeather.consolidated_weather[0].weather_state_name)

                                    let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                    let vc = storyboard.instantiateViewController(identifier: "weatherVC") as! WeatherViewController
                                    
                                    self?.addAnnotation(location: locationOnMap,titre: locations[0].title,temp: String(Int(resWeather.consolidated_weather[0].the_temp))+"°")
                                    
                                    vc.setTitre(titre: String(Int(resWeather.consolidated_weather[0].min_temp)) + "° -  "+String(Int(resWeather.consolidated_weather[0].max_temp))+"° | "+locations[0].title)
                                    
                                    vc.setTemp(Temp: String(Int(resWeather.consolidated_weather[0].the_temp))+"°")
                                    
                                    vc.setVitesseVent(VitesseVent: String(Int(resWeather.consolidated_weather[0].wind_speed))+" maph")
                                    vc.setDirectionVent(DirectionVent: resWeather.consolidated_weather[0].wind_direction_compass)
                                    vc.setPressionAir(PressionAir: String(Int(resWeather.consolidated_weather[0].air_pressure))+" mbar")
                                    vc.setHuminidite(Huminidite: String(Int(resWeather.consolidated_weather[0].humidity))+"%")
                                    vc.setVisiblite(Visiblite: String(Int(resWeather.consolidated_weather[0].visibility))+" miles")
                                    vc.setIcone(url: "https://www.metaweather.com/static/img/weather/png/64/"+resWeather.consolidated_weather[0].weather_state_abbr+".png")
                                    
                                    guard let navController = self?.navigationController else {
                                        print("pas de nav")
                                        return
                                    }
                                    navController.pushViewController(vc, animated: true)
                                    
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
    func addAnnotation(location: CLLocationCoordinate2D, titre : String, temp : String){
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            annotation.title = titre
            annotation.subtitle = temp
            self.mapView.addAnnotation(annotation)
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

