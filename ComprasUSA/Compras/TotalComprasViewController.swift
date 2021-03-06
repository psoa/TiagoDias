//
//  TotalComprasViewController.swift
//  TiagoDias
//
//  Created by Tiago Novaes Dias on 29/04/18.
//  Copyright © 2018 Tiago Novaes Dias. All rights reserved.
//

import UIKit
import CoreData

class TotalComprasViewController: UIViewController {

    @IBOutlet weak var totalUS: UILabel!
    @IBOutlet weak var totalBRL: UILabel!
    
    var cotacao: Double = 0.0
    var iof: Double = 0.0
    
    var compras: [Compra] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "refresh"), object: nil, queue: nil, using: {(notification) in
            self.cotacao = UserDefaults.standard.double(forKey: "cotacao")
            self.iof = UserDefaults.standard.double(forKey: "IOF")
        })
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cotacao = UserDefaults.standard.double(forKey: "cotacao")
        iof = UserDefaults.standard.double(forKey: "IOF")
        load()
        calcularTotais()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    func calcularTotais() {
        var totalDolar: Double = 0.0
        var totalReal: Double = 0.0
        var totalBrutoDolar: Double = 0.0
        
        for compra in compras {
            var valorCompra: Double = compra.valor
            totalBrutoDolar += valorCompra
            if let imposto = compra.estado?.imposto, imposto > 0.0 {
                valorCompra += ((valorCompra * imposto) / 100)
            }
            
            if compra.cartao {
                valorCompra += ((valorCompra * iof) / 100)
            }
            
            totalDolar += valorCompra
        }
        totalReal = (totalDolar * cotacao)
        totalUS.text = String(format: "%.3f", totalBrutoDolar)
        totalBRL.text = String(format: "%.3f", totalReal)
    }
    
    
    func load() {
        let fetchRequest: NSFetchRequest<Compra> = Compra.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "nome", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            compras = try context.fetch(fetchRequest)
        } catch {
            print(error.localizedDescription)
        }
    }
}
