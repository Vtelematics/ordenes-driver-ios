//
//  ProfileTableViewCell.swift
//  FoodDelivery
//
//  Created by Apple on 13/06/18.
//  Copyright © 2018 Adyas Iinfotech. All rights reserved.
//

import UIKit

class ProfileTableViewCell: UITableViewCell
{
    @IBOutlet weak var txtFname: UITextField!
    @IBOutlet weak var txtLname: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var txtAccountName: UITextField!
    @IBOutlet weak var txtBank: UITextField!
    @IBOutlet weak var txtAccountNum: UITextField!
    @IBOutlet weak var txtIfsc: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
