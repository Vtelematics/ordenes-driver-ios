//
//  PopViewController.swift
//  Exlcart
//
//  Created by Adyas on 31/03/16.
//  Copyright © 2016 iPhone. All rights reserved.

import UIKit

class PopViewController: ParentViewController, UITabBarControllerDelegate
{
    //var flagAry:NSArray = [UIImage(named: "Flag_of_USA.png")!, UIImage(named: "Flag_of_Kuwait.png")!]
    var countArr:NSArray = []
    
    var popType = String()
    
    @IBOutlet var tableView: UITableView!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.countArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "MenuCell") as! PopViewCell
        cell.title?.text = self.countArr.object(at: indexPath.row) as? String
        // cell.title?.font = UIFont(withSize(8))
        cell.layoutMargins = .zero
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        UserDefaults.standard.set("\(self.countArr.object(at: indexPath.row))", forKey: "quantity")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 35
    }
}
