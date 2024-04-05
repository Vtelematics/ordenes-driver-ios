//
//  OrderTableViewCell.swift
//  FoodDelivery
//
//  Created by Apple on 01/06/18.
//  Copyright © 2018 Adyas Iinfotech. All rights reserved.
//

import UIKit

class OrderTableViewCell: UITableViewCell
{
    @IBOutlet var baseView: UIView!
    @IBOutlet var lblRestroName: UILabel!
    @IBOutlet var lblPickupAddress: UILabel!
    @IBOutlet var lblDeliveryAddress: UILabel!
    @IBOutlet var lblOrderId: UILabel!
    @IBOutlet var lblTotal: UILabel!
    @IBOutlet var lblDate: UILabel!
    @IBOutlet var lblStatus: UILabel!
    @IBOutlet var lblRestaurantName: UILabel!
    @IBOutlet var btnAccept: UIButton!
    @IBOutlet var btnReject: UIButton!
    //Language
    @IBOutlet var lblLanguage: UILabel!
    @IBOutlet var imgLanguage: UIImageView!
    
    @IBOutlet weak var test: UILabel!
    
    @IBOutlet weak var lblContactless: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
