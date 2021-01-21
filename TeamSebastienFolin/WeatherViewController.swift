//
//  WeatherViewController.swift
//  TeamSebastienFolin
//
//  Created by etudiant on 20/01/2021.
//  Copyright © 2021 etudiant. All rights reserved.
//

import UIKit
import SDWebImage

class WeatherViewController: UIViewController {
    
    @IBOutlet weak var imgDemain: UIImageView!
    
    @IBOutlet weak var imgApresDemain: UIImageView!
    
    
    @IBOutlet weak var apresDemain: UILabel!
    
    @IBOutlet weak var demain: UILabel!
    
    @IBOutlet weak var visibilite: UILabel!
    @IBOutlet weak var huminidite: UILabel!
    @IBOutlet weak var PressionAir: UILabel!
    @IBOutlet weak var directionVent: UILabel!
    @IBOutlet weak var vitesseVent: UILabel!
    @IBOutlet weak var titre: UILabel!
    @IBOutlet weak var temp: UILabel!
    @IBOutlet weak var icone: UIImageView!
    
    
    private var inTemp : String?
    private var inVisiblite : String?
    private var inHuminidite : String?
    private var inPressionAir : String?
    private var inDirectionVent : String?
    private var inVitesseVent : String?
    private var inTitre : String?
    private var inIcone : String?
    private var inDemain : String?
    private var inApresDemain : String?
    
    private var inIconeDemain : String?
    private var inIconeApresDemain : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        visibilite.text = inVisiblite
        huminidite.text = inHuminidite
        PressionAir.text = inPressionAir
        directionVent.text = inDirectionVent
        vitesseVent.text = inVitesseVent
        titre.text = inTitre
        temp.text = inTemp
        demain.text = inDemain
        apresDemain.text = inApresDemain
        
        icone.sd_setImage(with: URL(string: inIcone ?? ""), placeholderImage: UIImage(named: "placeholder.png"))
        imgDemain.sd_setImage(with: URL(string: inIconeDemain ?? ""), placeholderImage: UIImage(named: "placeholder.png"))
        imgApresDemain.sd_setImage(with: URL(string: inIconeApresDemain ?? ""), placeholderImage: UIImage(named: "placeholder.png"))
        // Do any additional setup after loading the view.
    }
    

    func setTitre(titre: String){
        self.inTitre = titre
    }
    
    
    func setVisiblite(Visiblite: String){
        self.inVisiblite = Visiblite
    }
    
    func setHuminidite(Huminidite: String){
        self.inHuminidite = Huminidite
    }
    
    func setPressionAir(PressionAir: String){
        self.inPressionAir = PressionAir
    }
    
    func setDirectionVent(DirectionVent: String){
        self.inDirectionVent = DirectionVent
    }
    
    func setVitesseVent(VitesseVent: String){
        self.inVitesseVent = VitesseVent
    }
    func setTemp(Temp: String){
        self.inTemp = Temp
    }
    func setDemain(demain: String){
        self.inDemain = demain
    }
    
    func setApremDemain(apremdemain: String){
        self.inApresDemain = apremdemain
    }
    
    func setIcone(url: String){
        self.inIcone = url
    }
    
    func setIconeDemain(url: String){
        self.inIconeDemain = url
    }
    
    func setIconeApresDemain(url: String){
        self.inIconeApresDemain = url
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
