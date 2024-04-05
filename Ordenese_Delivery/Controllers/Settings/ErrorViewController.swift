//
//  ErrorViewController.swift
//  Restaurant
//
//  Created by Adyas Iinfotech on 22/01/18.
//  Copyright © 2018 Adyas Iinfotech. All rights reserved.
//

import UIKit
import Reachability

class ErrorViewController: ParentViewController {
    
    @IBOutlet weak var imageVw: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func clickRetry(_ sender: Any)
    {
        if Connectivity.isConnectedToInternet()
        {
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: {})
        }
        else
        {
            SharedManager.showAlertWithMessage(title: NSLocalizedString("Sorry", comment: ""), alertMessage: NSLocalizedString("Still there is no Connection Found", comment: ""), viewController: self)
        }
    }
}
