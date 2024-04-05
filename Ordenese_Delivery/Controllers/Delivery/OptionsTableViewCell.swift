//
//  OptionsTableViewCell.swift
//  FoodDelivery
//
//  Created by Apple on 07/06/18.
//  Copyright © 2018 Adyas Iinfotech. All rights reserved.
//

import UIKit

class OptionsTableViewCell: UITableViewCell {

    @IBOutlet weak var lblOption: UILabel!
    @IBOutlet weak var lblReason: UILabel!
    @IBOutlet weak var imgCheckbox: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
