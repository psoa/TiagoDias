//
//  AjustesTableViewCell.swift
//  TiagoDias
//
//  Created by Tiago Novaes Dias on 29/04/18.
//  Copyright © 2018 Tiago Novaes Dias. All rights reserved.
//

import UIKit

class AjustesTableViewCell: UITableViewCell {

    @IBOutlet weak var lbEstado: UILabel!
    @IBOutlet weak var lbImposto: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
