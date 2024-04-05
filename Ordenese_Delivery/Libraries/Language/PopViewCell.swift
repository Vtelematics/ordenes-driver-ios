//
//  PopViewCell.swift
//  4Tech
//
//  Created by Adyas on 05/11/16.
//  Copyright © 2016 adyas. All rights reserved.
//

import UIKit

class PopViewCell: UITableViewCell {
    @IBOutlet var title: UILabel!
    @IBOutlet var img: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
