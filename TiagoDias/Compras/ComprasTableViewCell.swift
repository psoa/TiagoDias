//
//  ComprasTableViewCell.swift
//  TiagoDias
//
//  Created by Tiago Novaes Dias on 29/04/18.
//  Copyright © 2018 Tiago Novaes Dias. All rights reserved.
//

import UIKit

class ComprasTableViewCell: UITableViewCell {

    
    @IBOutlet weak var ivPoster: UIImageView!
    @IBOutlet weak var lbNome: UILabel!
    @IBOutlet weak var lbValor: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func prepare(with compra: Compra) {
        
        lbNome.text = compra.nome
        lbValor.text = String(compra.valor)
        
        if let image = compra.poster as? UIImage {
            ivPoster.image = image
        } else {
            ivPoster.image = UIImage(named: "red-shopping-bag-md")
        }
    }
}
