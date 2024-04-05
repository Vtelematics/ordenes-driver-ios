//
//  HistoryViewController.swift
//  FoodDelivery
//
//  Created by Apple on 31/05/18.
//  Copyright © 2018 Adyas Iinfotech. All rights reserved.
//

import UIKit
import Alamofire
import Reachability

class HistoryViewController: ParentViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tblDelivery: UITableView!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet  var imgBack: UIImageView!
    
    var orderArr = NSMutableArray()
    
    var isScrolledOnce : Bool = false
    var page:Int = 1
    var pageCount = Double()
    var limit:String = "15"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        lblTitle.text! = NSLocalizedString("Delivery History", comment: "")
        self.orderHistory()
    }
    
    func orderHistory(){
        SharedManager.showHUD(viewController: self)
        page = 1
        let params = [
            "page": page,
            "page_per_unit": limit
        ] as [String: Any]
        let urlStr = "\(ConfigUrl.baseUrl)order-delivered"
        let setFinalURl = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        var request = URLRequest(url: URL(string: setFinalURl)!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(userIDStr, forHTTPHeaderField: "Driver-Authorization")
        if let jsonData: Data = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted) {
            let jsonString = String(data: jsonData , encoding: .utf8)
            print(jsonString as Any)
            request.httpBody = jsonData
        }
        if Connectivity.isConnectedToInternet()
        {
            Alamofire.request(request).responseJSON
                { (responseObject) -> Void in
                    if responseObject.result.isSuccess
                    {
                        let result = responseObject.result.value! as AnyObject
                        print(result)
                        if let code = result.value(forKeyPath: "success.status")
                        {
                            if code as! String == "200"
                            {
                                let result = responseObject.result.value! as AnyObject
                                self.orderArr = (result.value(forKey: "order") as! NSArray).mutableCopy() as! NSMutableArray
                                let total = "\(result.value(forKey: "total")!)"
                                self.pageCount = Double(Int(total)!/Int(self.limit)!)
                                if self.orderArr.count == 0
                                {
                                    let alert = UIAlertController(title: NSLocalizedString("Sorry", comment: ""), message: NSLocalizedString("No Order history found", comment: ""), preferredStyle: UIAlertController.Style.alert)
                                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: {(alert :UIAlertAction) in
                                        self.navigationController?.popViewController(animated: true)
                                    }))
                                    self.present(alert, animated: true, completion: nil)
                                }
                                self.tblDelivery.dataSource = self
                                self.tblDelivery.delegate = self
                                self.tblDelivery.reloadData()
                                SharedManager.dismissHUD(viewController: self)
                            }
                        }else{
                             SharedManager.dismissHUD(viewController: self)
                             SharedManager.showAlertWithMessage(title: "", alertMessage: ((responseObject.result.value!) as AnyObject).value(forKeyPath: "error.message") as! String, viewController: self)
                        }
                        
                    }
                    if responseObject.result.isFailure
                    {
                        SharedManager.dismissHUD(viewController: self)
                        let error : Error = responseObject.result.error!
                        print(error.localizedDescription)
                    }
            }
        }
        else
        {
            SharedManager.dismissHUD(viewController: self)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "ErrorViewController")
                as! ErrorViewController
            self.present(viewController, animated: true, completion: { () -> Void in
            })
        }
    }
    
    func pullToRefresh()
    {
        if (self.isScrolledOnce == true)
        {
            return
        }
        self.isScrolledOnce = true
        if page <= Int(self.pageCount)
        {
            SharedManager.showHUD(viewController: self)
            page += 1
            let params = [
                "page": page,
                "page_per_unit": limit
            ] as [String: Any]
            let urlStr = "\(ConfigUrl.baseUrl)order-delivered"
            let setFinalURl = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            var request = URLRequest(url: URL(string: setFinalURl)!)
            request.httpMethod = HTTPMethod.post.rawValue
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(userIDStr, forHTTPHeaderField: "Driver-Authorization")
            if let jsonData: Data = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted) {
                let jsonString = String(data: jsonData , encoding: .utf8)
                print(jsonString as Any)
                request.httpBody = jsonData
            }
            if Connectivity.isConnectedToInternet()
            {
                Alamofire.request(request).responseJSON
                    { (responseObject) -> Void in
                        if responseObject.result.isSuccess
                        {
                            let result = responseObject.result.value! as AnyObject
                            print(result)
                            if let code = result.value(forKeyPath: "success.status")
                            {
                                if code as! String == "200"
                                {
                                    let result = responseObject.result.value! as AnyObject
                                    print(result)
                                    let array = (result.value(forKey: "order") as! NSArray).mutableCopy() as! NSMutableArray
                                    self.orderArr.addObjects(from: array as! [Any])
                                    self.tblDelivery.reloadData()
                                    SharedManager.dismissHUD(viewController: self)
                                }
                            }else{
                                 SharedManager.dismissHUD(viewController: self)
                                 SharedManager.showAlertWithMessage(title: "", alertMessage: ((responseObject.result.value!) as AnyObject).value(forKeyPath: "error.message") as! String, viewController: self)
                            }
                            
                        }
                        if responseObject.result.isFailure
                        {
                            SharedManager.dismissHUD(viewController: self)
                            let error : Error = responseObject.result.error!
                            print(error.localizedDescription)
                            if "\(error.localizedDescription))" == "The Internet connection appears to be offline"
                            {
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                let viewController = storyboard.instantiateViewController(withIdentifier: "ErrorViewController")
                                    as! ErrorViewController
                                self.present(viewController, animated: true, completion: { () -> Void in
                                })
                            }
                        }
                        self.isScrolledOnce = false
                }
            }
            else
            {
                self.isScrolledOnce = false
                SharedManager.dismissHUD(viewController: self)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: "ErrorViewController")
                    as! ErrorViewController
                self.present(viewController, animated: true, completion: { () -> Void in
                })
            }
        }
        else
        {
            self.isScrolledOnce = false
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        let offset: CGPoint = scrollView.contentOffset
        let bounds: CGRect = scrollView.bounds
        let size: CGSize = scrollView.contentSize
        let inset: UIEdgeInsets = scrollView.contentInset
        let y = Float(offset.y + bounds.size.height - inset.bottom)
        let h = Float(size.height)
        let reload_distance: Float = 10
        if y > h + reload_distance
        {
            if isScrolledOnce == false
            {
                self.pullToRefresh()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: TableView Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return orderArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:OrderTableViewCell = self.tblDelivery.dequeueReusableCell(withIdentifier: "orderCell") as! OrderTableViewCell
        cell.baseView.dropShadow(cornerRadius: 8, opacity: 0.2, radius: 8)
        cell.lblTotal.textAlignment = isRTLenabled == true ? .left : .right
        cell.lblOrderId.text = "\(NSLocalizedString("Order ID : ", comment: ""))\((orderArr.object(at: indexPath.row) as AnyObject).value(forKey: "order_id")!)"
        cell.lblRestroName.text = "\(NSLocalizedString("Seller Name : ", comment: ""))\((orderArr.object(at: indexPath.row) as AnyObject).value(forKey: "vendor")!)"
        cell.lblTotal.text = "\(NSLocalizedString("Order Total : ", comment: ""))\((orderArr.object(at: indexPath.row) as AnyObject).value(forKey: "total")!)"
        cell.lblDate.text = "\(NSLocalizedString("Delivery Date : ", comment: ""))\((orderArr.object(at: indexPath.row) as AnyObject).value(forKey: "date_delivery")!)"
        cell.lblPickupAddress.text = "\((orderArr.object(at: indexPath.row) as AnyObject).value(forKey: "pickup_address")!)"
        cell.lblDeliveryAddress.text = "\((orderArr.object(at: indexPath.row) as AnyObject).value(forKey: "delivery_address")!)"
        let normalText = NSLocalizedString("Order Status", comment: "")
        let attributedStringColor = [NSAttributedString.Key.foregroundColor : positiveBtnColor];
        let attributedString = NSAttributedString(string: "\((orderArr.object(at: indexPath.row) as AnyObject).value(forKey: "delivery_status")!)", attributes: attributedStringColor)
        let normalString = NSMutableAttributedString(string:"\(normalText) : ")
        normalString.append(attributedString)
        cell.lblStatus.attributedText = normalString
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 292
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "DeliveryDetailViewController")
            as! DeliveryDetailViewController
        viewController.orderId = "\((orderArr.object(at: indexPath.row) as AnyObject).value(forKey: "order_id")!)"
        viewController.isHistory = true
        viewController.deliveryDict = orderArr.object(at: indexPath.row) as! NSDictionary
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
