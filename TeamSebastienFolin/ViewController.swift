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
import SQLite3

class ViewController: UIViewController {
     let baseUrl = "https://www.metaweather.com/api/location/search/?lattlong="
     var baseUrlWeather = "https://www.metaweather.com/api/location/"
    
    internal let SQLITE_STATIC = unsafeBitCast(0, to: sqlite3_destructor_type.self)
    internal let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    
    
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
        getAllWeatherFromDb()
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
                                    
                                    self?.addAnnotation(lat : locationOnMap.latitude, long: locationOnMap.longitude,titre: locations[0].title,temp: String(Int(resWeather.consolidated_weather[0].the_temp))+"°")
                                    
                                    vc.setDemain(demain: String(Int(resWeather.consolidated_weather[1].min_temp)) + "° -  "+String(Int(resWeather.consolidated_weather[1].max_temp))+"°")
                                    
                                    vc.setApremDemain(apremdemain: String(Int(resWeather.consolidated_weather[2].min_temp)) + "° -  "+String(Int(resWeather.consolidated_weather[2].max_temp))+"°")
                                    
                                    vc.setTitre(titre: String(Int(resWeather.consolidated_weather[0].min_temp)) + "° -  "+String(Int(resWeather.consolidated_weather[0].max_temp))+"° | "+locations[0].title)
                                    
                                    vc.setTemp(Temp: String(Int(resWeather.consolidated_weather[0].the_temp))+"°")
                                    
                                    vc.setVitesseVent(VitesseVent: String(Int(resWeather.consolidated_weather[0].wind_speed))+" maph")
                                    vc.setDirectionVent(DirectionVent: resWeather.consolidated_weather[0].wind_direction_compass)
                                    vc.setPressionAir(PressionAir: String(Int(resWeather.consolidated_weather[0].air_pressure))+" mbar")
                                    vc.setHuminidite(Huminidite: String(Int(resWeather.consolidated_weather[0].humidity))+"%")
                                    vc.setVisiblite(Visiblite: String(Int(resWeather.consolidated_weather[0].visibility))+" miles")
                                    vc.setIcone(url: "https://www.metaweather.com/static/img/weather/png/64/"+resWeather.consolidated_weather[0].weather_state_abbr+".png")
                                                                        vc.setIconeDemain(url: "https://www.metaweather.com/static/img/weather/png/"+resWeather.consolidated_weather[1].weather_state_abbr+".png")
                                                                        vc.setIconeApresDemain(url: "https://www.metaweather.com/static/img/weather/png/"+resWeather.consolidated_weather[2].weather_state_abbr+".png")
                                    //init dataWeather to insert data into db
                                    
                                    let dw = DataWeather()
                                    dw.woeid = String(locations[0].woeid)
                                    dw.title = locations[0].title
                                    dw.air_pressure = String(Int(resWeather.consolidated_weather[0].air_pressure))+" mbar"
                                    dw.humidity = String(Int(resWeather.consolidated_weather[0].humidity))+"%"
                                    dw.the_temp = String(Int(resWeather.consolidated_weather[0].the_temp))+"°"
                                    dw.wind_speed = String(Int(resWeather.consolidated_weather[0].wind_speed))+" maph"
                                    dw.wind_direction_compass = resWeather.consolidated_weather[0].wind_direction_compass
                                    dw.wind_direction = ""
                                    dw.max_temp = String(Int(resWeather.consolidated_weather[0].max_temp))
                                    dw.min_temp = String(Int(resWeather.consolidated_weather[0].min_temp))
                                    dw.visibility = String(Int(resWeather.consolidated_weather[0].visibility))+" miles"
                                    dw.weather_state_name = resWeather.consolidated_weather[0].weather_state_name
                                    dw.icone = "https://www.metaweather.com/static/img/weather/png/64/"+resWeather.consolidated_weather[0].weather_state_abbr+".png"
                                    dw.latitude = lt
                                    dw.longitude = lg
                                    
                                    self?.insertWeather(data: dw)
                                  
                                
                                    
                                    
                                    guard let navController = self?.navigationController else {
                                        print("pas de nav")
                                        return
                                    }
                                    navController.pushViewController(vc, animated: true)
                                    
                                case .failure(let error):
                                    print(error)
                                    self?.notifError()
                                }
                            }
                        
                        //-------------------------------------
                      
                        

                    } catch {
                       print(error)
                       self.notifError()
                    }
                    
                }
            
        }
    }
    func addAnnotation(lat : Double, long : Double, titre : String, temp : String){
            let annotation = MKPointAnnotation()
            annotation.coordinate.latitude = lat
            annotation.coordinate.longitude = long
            annotation.title = titre
            annotation.subtitle = temp
            self.mapView.addAnnotation(annotation)
        
    }
    
    func notifError(){
        let alert = UIAlertController(title: "erreur", message: "les données sont actuellement indisponible", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func getAllWeatherFromDb() {
        
        let fileURL = try! FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("dbweather.sqlite")

        // open database

        var db: OpaquePointer?
        guard sqlite3_open(fileURL.path, &db) == SQLITE_OK else {
            print("error opening database")
            sqlite3_close(db)
            db = nil
            return
        }
        
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, "select id, title, woeid, weather_state_name, weather_state_abbr, the_temp, air_pressure, humidity, visibility, min_temp, max_temp, wind_direction, wind_direction_compass, wind_speed, latitude, longitude, icone from weather", -1, &statement, nil) != SQLITE_OK {
             let errmsg = String(cString: sqlite3_errmsg(db)!)
             print("error preparing select: \(errmsg)")
         }
       
         while sqlite3_step(statement) == SQLITE_ROW {
            
            let p1 = String(cString: sqlite3_column_text(statement, 14))
            let p2 = String(cString: sqlite3_column_text(statement, 15))
            let p3 = String(cString: sqlite3_column_text(statement, 1))
            let p4 = String(cString: sqlite3_column_text(statement, 5))
            
           
            print(p1)
            print(p2)
           
            
            addAnnotation(lat: Double(p1)!, long: Double(p2)!, titre: p3, temp : p4)
   
             
         }

         if sqlite3_finalize(statement) != SQLITE_OK {
             let errmsg = String(cString: sqlite3_errmsg(db)!)
             print("error finalizing prepared statement: \(errmsg)")
         }

         statement = nil
         
         if sqlite3_close(db) != SQLITE_OK {
             print("error closing database")
         }

         db = nil
         
    }
    func insertWeather(data : DataWeather){
            let fileURL = try! FileManager.default
                .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("dbweather.sqlite")

            // open database

            var db: OpaquePointer?
            guard sqlite3_open(fileURL.path, &db) == SQLITE_OK else {
                print("error opening database")
                sqlite3_close(db)
                db = nil
                return
            }
            
            var statement: OpaquePointer?

            
            if sqlite3_exec(db, "create table if not exists weather (id integer primary key autoincrement, title text, woeid text, weather_state_name text, weather_state_abbr text, the_temp text, air_pressure text, humidity text, visibility text, min_temp text, max_temp text, wind_direction text, wind_direction_compass text, wind_speed text, latitude text, longitude text, icone text)", nil, nil, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error creating table: \(errmsg)")
            }
            
            
            if sqlite3_prepare_v2(db, "insert into weather (title, woeid, weather_state_name, weather_state_abbr, the_temp, air_pressure, humidity, visibility, min_temp, max_temp, wind_direction, wind_direction_compass, wind_speed, latitude, longitude, icone) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", -1, &statement, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing insert: \(errmsg)")
            }

        
        if  sqlite3_bind_text(statement, 1, data.title, -1, SQLITE_TRANSIENT) != SQLITE_OK ||
            sqlite3_bind_text(statement, 2, data.woeid, -1, SQLITE_TRANSIENT) != SQLITE_OK ||
            sqlite3_bind_text(statement, 3, data.weather_state_name, -1, SQLITE_TRANSIENT) != SQLITE_OK ||
            sqlite3_bind_text(statement, 4, data.weather_state_abbr, -1, SQLITE_TRANSIENT) != SQLITE_OK ||
            sqlite3_bind_text(statement, 5, data.the_temp, -1, SQLITE_TRANSIENT) != SQLITE_OK ||
            sqlite3_bind_text(statement, 6, data.air_pressure, -1, SQLITE_TRANSIENT) != SQLITE_OK ||
            sqlite3_bind_text(statement, 7, data.humidity, -1, SQLITE_TRANSIENT) != SQLITE_OK ||
            sqlite3_bind_text(statement, 8, data.visibility, -1, SQLITE_TRANSIENT) != SQLITE_OK ||
            sqlite3_bind_text(statement, 9, data.min_temp, -1, SQLITE_TRANSIENT) != SQLITE_OK ||
            sqlite3_bind_text(statement, 10, data.max_temp, -1, SQLITE_TRANSIENT) != SQLITE_OK ||
            sqlite3_bind_text(statement, 11, data.wind_direction, -1, SQLITE_TRANSIENT) != SQLITE_OK ||
            sqlite3_bind_text(statement, 12, data.wind_direction_compass, -1, SQLITE_TRANSIENT) != SQLITE_OK ||
            sqlite3_bind_text(statement, 13, data.wind_speed, -1, SQLITE_TRANSIENT) != SQLITE_OK ||
            sqlite3_bind_text(statement, 14, data.latitude, -1, SQLITE_TRANSIENT) != SQLITE_OK ||
            sqlite3_bind_text(statement, 15, data.longitude, -1, SQLITE_TRANSIENT) != SQLITE_OK ||
            sqlite3_bind_text(statement, 16, data.icone, -1, SQLITE_TRANSIENT) != SQLITE_OK
        {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding foo: \(errmsg)")
            }

            if sqlite3_step(statement) != SQLITE_DONE {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure inserting foo: \(errmsg)")
            }
        
            if sqlite3_finalize(statement) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error finalizing prepared statement: \(errmsg)")
            }

            statement = nil
            
           
            
            if sqlite3_close(db) != SQLITE_OK {
                print("error closing database")
            }

            db = nil
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

