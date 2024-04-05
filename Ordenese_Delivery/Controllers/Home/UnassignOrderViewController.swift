//
//  UnassignOrderViewController.swift
//  FMdelivery
//
//  Created by Adyas infotech on 07/09/22.
//  Copyright © 2022 Adyas Iinfotech. All rights reserved.
//

import UIKit
import Alamofire

class UnassignOrderViewController: UIViewController {

    @IBOutlet weak var tblUnassignOrder: UITableView!
    @IBOutlet weak var viewEmpty: UIView!
    var orderArr = NSMutableArray()
    var isScrolledOnce : Bool = false
    var page:Int = 1
    var pageCount = Double()
    var limit:String = "15"
    var fromNotification = false
    var window: UIWindow?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getUnAssignedOrder()
    }
    
    func setupUI(){
        if fromNotification{
            let barView = UIView()
            barView.frame = CGRect(x: 0, y: 0, width: 80, height: 40)
            
            let img = UIImageView()
            img.image = UIImage (named: "left-arrow-back")
            img.frame = CGRect(x: 0, y: 10, width: 15, height: 20)
            img.contentMode = .scaleAspectFit
            
            let myBackButton:UIButton = UIButton.init(type: .custom)
            myBackButton.addTarget(self, action: #selector(self.clickBack(sender:)), for: .touchUpInside)
            myBackButton.setTitle(NSLocalizedString("Back", comment: ""), for: .normal)
            myBackButton.setTitleColor(.white, for: .normal)
            myBackButton.sizeToFit()
            myBackButton.frame = CGRect(x: 12, y: 5, width: 55, height: 30)
    //RTL
    //        img.transform = CGAffineTransform(scaleX: -1, y: 1)
    //        img.frame = CGRect(x: 60, y: 10, width: 15, height: 20)
    //        myBackButton.frame = CGRect(x: 18, y: 5, width: 42, height: 30)
    //
            barView.addSubview(img)
            barView.addSubview(myBackButton)
            let myCustomBackButtonItem:UIBarButtonItem = UIBarButtonItem(customView: barView)
            self.navigationItem.leftBarButtonItem  = myCustomBackButtonItem
            
        }
        
        let btnUnassign = UIButton(type: UIButton.ButtonType.custom)
        btnUnassign.addTarget(self, action:#selector(getUnAssignedOrder), for: .touchUpInside)
        btnUnassign.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let imgUnassign = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        imgUnassign.image = UIImage(named: "ic_refresh")
        imgUnassign.image = imgUnassign.image!.withRenderingMode(.alwaysTemplate)
        imgUnassign.tintColor = .white
        let viewUnassign = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        viewUnassign.addSubview(imgUnassign)
        viewUnassign.addSubview(btnUnassign)
        let barButton = UIBarButtonItem(customView: viewUnassign)
        self.navigationItem.rightBarButtonItems = [barButton]
    }
    
    @objc func clickBack(sender:UIBarButtonItem)
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let viewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController")
        let navigationController = UINavigationController.init(rootViewController: viewController)
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
    }
    
    @objc func getUnAssignedOrder()
    {
        SharedManager.showHUD(viewController: self)
        page = 1
        self.view.endEditing(true)
        let params = [
            "page": page, 
            "page_per_unit": limit
        ] as [String: Any]
        let urlStr = "\(ConfigUrl.baseUrl)order-unassigned"
        let setFinalURl = urlStr.addingPercentEncoding (withAllowedCharacters: .urlQueryAllowed)!
        var request = URLRequest(url: URL(string: setFinalURl)!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(userIDStr, forHTTPHeaderField: "Driver-Authorization")
        if let jsonData: Data = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted) {
            let jsonString = String(data: jsonData , encoding: .utf8)
            print(jsonString as Any)
            request.httpBody = jsonData
        }
        Alamofire.request(request).responseJSON { (responseObject) -> Void in
            if responseObject.result.isSuccess
            {
                let result = responseObject.result.value! as AnyObject
                print(result)
                if let code = result.value(forKeyPath: "success.status")
                {
                    if code as! String == "200"
                    {
                        self.orderArr = (result.value(forKey: "order") as! NSArray).mutableCopy() as! NSMutableArray
                        if self.orderArr.count != 0{
                            self.tblUnassignOrder.isHidden = false
                            self.viewEmpty.isHidden = true
                        }else{
                            self.tblUnassignOrder.isHidden = true
                            self.viewEmpty.isHidden = false
                        }
                        let total = "\(result.value(forKey: "total")!)"
                        self.pageCount = Double(Int(total)!/Int(self.limit)!)
                        self.tblUnassignOrder.dataSource = self
                        self.tblUnassignOrder.delegate = self
                        self.tblUnassignOrder.reloadData()
                        SharedManager.dismissHUD(viewController: self)
                    }
                }else{
                    SharedManager.dismissHUD(viewController: self)
                    SharedManager.showAlertWithMessage(title: "", alertMessage: ((responseObject.result.value!) as AnyObject).value(forKeyPath: "error.message") as! String, viewController: self)
                }
            }
            if responseObject.result.isFailure
            {
                let error : Error = responseObject.result.error!
                print(error.localizedDescription)
            }
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
            let urlStr = "\(ConfigUrl.baseUrl)order-unassigned"
            let setFinalURl = urlStr.addingPercentEncoding (withAllowedCharacters: .urlQueryAllowed)!
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
                                    self.tblUnassignOrder.reloadData()
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
}

extension UnassignOrderViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return orderArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:OrderTableViewCell = self.tblUnassignOrder.dequeueReusableCell(withIdentifier: "orderCell") as! OrderTableViewCell
        cell.baseView.dropShadow(cornerRadius: 8, opacity: 0.2, radius: 8)
        //let normalText = NSLocalizedString("Order Status", comment: "")
        //let attributedStringColor = [NSAttributedString.Key.foregroundColor : positiveBtnColor];
        //let attributedString = NSAttributedString(string: "\((orderArr.object(at: indexPath.row) as AnyObject).value(forKey: "order_status")!)", attributes: attributedStringColor)
        //let normalString = NSMutableAttributedString(string:"\(normalText) : ")
        //normalString.append(attributedString)
        //cell.lblStatus.attributedText = normalString
        cell.lblOrderId.textAlignment = isRTLenabled == true ? .right : .left
        //cell.lblTotal.textAlignment = isRTLenabled == true ? .left : .right
        cell.lblOrderId.text = "\(NSLocalizedString("Order ID : ", comment: ""))\((orderArr.object(at: indexPath.row) as AnyObject).value(forKey: "order_id")!)"
        //cell.lblTotal.text = "\(NSLocalizedString("Order Total : ", comment: ""))\((orderArr.object(at: indexPath.row) as AnyObject).value(forKey: "total")!)"
        cell.lblRestroName.text = "\(NSLocalizedString("Seller Name : ", comment: ""))\((orderArr.object(at: indexPath.row) as AnyObject).value(forKey: "vendor")!)"
        //cell.lblDate.text = "\(NSLocalizedString("Delivery Date : ", comment: ""))\((orderArr.object(at: indexPath.row) as AnyObject).value(forKey: "task_date_added")!)"
        cell.lblPickupAddress.text = "\((orderArr.object(at: indexPath.row) as AnyObject).value(forKey: "pickup_address")!)"
        cell.lblDeliveryAddress.text = "\((orderArr.object(at: indexPath.row) as AnyObject).value(forKey: "delivery_address")!)"
        let contactless_delivery = "\((orderArr.object(at: indexPath.row) as AnyObject).value(forKey: "contactless_delivery")!)"
        if contactless_delivery == "1" {
            cell.lblContactless.isHidden = false
            let stringAttribute = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16), NSAttributedString.Key.foregroundColor : UIColor(red: 67/255, green: 164/255, blue: 34/255, alpha: 1.0)]
            let attributedString1 = NSMutableAttributedString(string: (NSLocalizedString("Delivery Type : ", comment: "")))
            let attributedString2 = NSMutableAttributedString(string:"Contactless Delivery", attributes:stringAttribute)
            attributedString1.append(attributedString2)
            cell.lblContactless.attributedText = attributedString1
        }else {
            cell.lblContactless.isHidden = true
        }
        cell.btnAccept.addTarget(self, action: #selector(clickAccept(_:)), for: .touchUpInside)
        cell.btnAccept.tag = indexPath.row
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 330
    }
    
    @objc func clickAccept(_ sender : UIButton){
        SharedManager.showHUD(viewController: self)
        let orderId = "\((self.orderArr.object(at: sender.tag) as AnyObject).value(forKey: "order_id")!)"
        let params = [
            "order_id": orderId
        ] as [String: Any]
        let urlStr = "\(ConfigUrl.baseUrl)order-accept"
        let setFinalURl = urlStr.addingPercentEncoding (withAllowedCharacters: .urlQueryAllowed)!
        var request = URLRequest(url: URL(string: setFinalURl)!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue(userIDStr, forHTTPHeaderField: "Driver-Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let jsonData: Data = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted) {
            let jsonString = String(data: jsonData , encoding: .utf8)
            print(jsonString as Any)
            request.httpBody = jsonData
        }
        Alamofire.request(request).responseJSON { (responseObject) -> Void in
            if responseObject.result.isSuccess
            {
                let result = responseObject.result.value! as AnyObject
                if let code = result.value(forKeyPath: "success.status")
                {
                    if code as! String == "200"
                    {
                        SharedManager.dismissHUD(viewController: self)
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let viewController = storyboard.instantiateViewController(withIdentifier: "DeliveryDetailViewController")
                            as! DeliveryDetailViewController
                        viewController.orderId = orderId
                        self.navigationController?.pushViewController(viewController, animated: true)
                    }
                }else{
                    SharedManager.showAlertWithMessage(title: "", alertMessage: ((responseObject.result.value!) as AnyObject).value(forKeyPath: "error.message") as! String, viewController: self)
                    SharedManager.dismissHUD(viewController: self)
                    self.getUnAssignedOrder()
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
    
    @objc func clickReject(_ sender : UIButton){
        SharedManager.showHUD(viewController: self)
        userIDStr = UserDefaults.standard.string(forKey: "USER_ID")!
        let orderId = "\((self.orderArr.object(at: sender.tag) as AnyObject).value(forKey: "order_id")!)"
            let params = "order_id=\(orderId)"
            print(params)
            let testData = (params as NSString).data(using: String.Encoding.utf8.rawValue)
            let urlStr = "\(ConfigUrl.baseUrl)delivery/feed/reject_order"
            let setFinalURl = urlStr.addingPercentEncoding (withAllowedCharacters: .urlQueryAllowed)!
            var request = URLRequest(url: URL(string: setFinalURl)!)
            request.httpMethod = HTTPMethod.post.rawValue
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.setValue(userIDStr, forHTTPHeaderField: "Driver-Authorization")
            request.httpBody = testData
        
            Alamofire.request(request).responseJSON { (responseObject) -> Void in
                
                if responseObject.result.isSuccess
                {
                    let result = responseObject.result.value! as AnyObject
                    if let code = result.value(forKeyPath: "success.status")
                    {
                        if code as! String == "200"
                        {
                            SharedManager.dismissHUD(viewController: self)
                            self.getUnAssignedOrder()
                        }else{
                            SharedManager.dismissHUD(viewController: self)
                            SharedManager.showAlertWithMessage(title: "", alertMessage: ((responseObject.result.value!) as AnyObject).value(forKeyPath: "success.message") as! String, viewController: self)
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
}
