//
//  ProductsTableViewCell.swift
//  FoodDelivery
//
//  Created by Apple on 04/06/18.
//  Copyright © 2018 Adyas Iinfotech. All rights reserved.
//

import UIKit

class ProductsTableViewCell: UITableViewCell
{
    @IBOutlet weak var lblTotalValue: UILabel!
    @IBOutlet weak var lblTotalTitle: UILabel!
    
    @IBOutlet weak var lblTotal: UILabel!
    @IBOutlet weak var lblQuantity: UILabel!
    @IBOutlet weak var lblProductName: UILabel!
    @IBOutlet weak var imgProduct: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
