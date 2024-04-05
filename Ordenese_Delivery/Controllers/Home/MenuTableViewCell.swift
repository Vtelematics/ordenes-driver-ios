//
//  MenuTableViewCell.swift
//  FoodDelivery
//
//  Created by Apple on 31/05/18.
//  Copyright © 2018 Adyas Iinfotech. All rights reserved.
//

import UIKit

class MenuTableViewCell: UITableViewCell {
    
    //Menu
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var imgIcon: UIImageView!
    
    //Menu
    @IBOutlet var lblOrderId: UILabel!
    @IBOutlet var lblRestaurantName: UILabel!
    @IBOutlet var lblDeliveryData: UILabel!
    @IBOutlet var lblCommissionAmt: UILabel!
    @IBOutlet var lblProductCount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
