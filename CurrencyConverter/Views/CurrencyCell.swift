//
//  CurrencyCell.swift
//  CurrencyConverter
//
//  Created by Paras Navadiya on 16/04/2020.
//  Copyright © 2020 Paras Navadiya. All rights reserved.
//

import UIKit

class CurrencyCell: UITableViewCell {
   
    @IBOutlet weak var lblCountry: UILabel!
    @IBOutlet weak var lblRate: UILabel!
        
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
