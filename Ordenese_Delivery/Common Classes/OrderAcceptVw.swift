//
//  OrderAcceptVw.swift
//  Chillaxdriver
//
//  Created by Apple on 07/10/20.
//  Copyright © 2020 Adyas Iinfotech. All rights reserved.
//

import UIKit

class OrderAcceptVw: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet var lblOrderId: UILabel!
    @IBOutlet var lblPickup: UILabel!
    @IBOutlet var lblDelivery: UILabel!
    @IBOutlet var lblPaymentType: UILabel!
    @IBOutlet var lblOrderCount: UILabel!
    @IBOutlet var btnAccept: UIButton!
    @IBOutlet var btnReject: UIButton!
    @IBOutlet var lblRestaurantName: UILabel!
    
    @IBOutlet var lblTxtTitle: UILabel!
    @IBOutlet var lblHeaderRestaurantName: UILabel!
    @IBOutlet var lblHeaderPickup: UILabel!
    @IBOutlet var lblHeaderDelivery: UILabel!
    @IBOutlet var lblHeaderPaymentType: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("OrderAcceptView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        self.lblTxtTitle.text = NSLocalizedString("There is an order near you. Can you deliver?", comment: "")
        self.lblHeaderRestaurantName.text = NSLocalizedString("Seller Name", comment: "")
        self.lblHeaderPickup.text = NSLocalizedString("Pickup", comment: "")
        self.lblHeaderDelivery.text = NSLocalizedString("Delivery", comment: "")
        self.lblHeaderPaymentType.text = NSLocalizedString("Payment Type", comment: "")
    }

}
