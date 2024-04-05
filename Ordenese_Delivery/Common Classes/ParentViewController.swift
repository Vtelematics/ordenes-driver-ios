//
//  ParentViewController.swift
//  Restaurant
//
//  Created by Adyas Iinfotech on 02/06/17.
//  Copyright © 2017 Adyas Iinfotech. All rights reserved.
//

import UIKit
import Alamofire
import AVFoundation

//var languageID:String = "1"
var countryID: NSString = ""
var stateID:NSString = ""
var countryName:String = ""
var stateName:String = ""
var categoryID:String = ""
var subCategoryID:NSString = ""
var mainCategoryID:String = ""
var creditTypeStr:NSString = ""
var catID = NSMutableArray()
var cartTotalAmount:String = ""
var dealsID : String = ""
var countryArr = NSMutableArray()
var stateArr = NSMutableArray()

extension UIViewController {
    
    func showToast(message : String) {
        
        let toastLabel = UILabel(frame: CGRect(x: 10, y: self.view.frame.size.height-100, width: self.view.bounds.width - 20, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    } }

@objc class ParentViewController: UIViewController, UIGestureRecognizerDelegate
{
    //Order accept
    var orderAcceptVw = OrderAcceptVw()
    var orderAcceptContainerVw = UIView()
    var orderAcceptContainerBlurVw = UIView()
    var unAssignedOrdersArr = NSMutableArray()
    //Side menu
    var mainTableView = UITableView()
    var categoryTableView = UITableView()
    var categoryDict = NSMutableArray()
    var index = NSIndexPath()
    var menuView = UIView()
    var sideMenu = SideView()
    var deliverTypeStr = ""
    var sidemenuTypeStr = String()
    var countryIDStr:String = ""
    var languageID:String = "1"
    var countryName:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        
    }
    
    @objc func clickOrderAccept(_ sender : UIButton)
    {
        SharedManager.showHUD(viewController: self)
        userIDStr = UserDefaults.standard.string(forKey: "USER_ID")!
        let orderId = "\((self.unAssignedOrdersArr.object(at: 0) as AnyObject).value(forKey: "order_id")!)"
        let params = "order_id=\(orderId)"
        let testData = (params as NSString).data(using: String.Encoding.utf8.rawValue)
        let urlStr = "\(ConfigUrl.baseUrl)delivery/order/accept_delivery"
        print(userIDStr)
        print(params)
        print(urlStr)
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
                //print(result)
                if let code = result.value(forKeyPath: "success.status")
                {
                    
                    if code as! String == "200"
                    {
                        self.unAssignedOrdersArr.removeObject(at: 0)
                        if self.unAssignedOrdersArr.count == 0
                        {
                            if (self.orderAcceptVw.isDescendant(of: self.orderAcceptContainerVw))
                            {
                                self.orderAcceptVw.removeFromSuperview()
                                self.orderAcceptContainerBlurVw.removeFromSuperview()
                                self.orderAcceptContainerVw.removeFromSuperview()
                            }
                        }else{
                            self.orderAcceptVw.lblOrderId.text = "Order-Id: \((self.unAssignedOrdersArr.object(at: 0) as AnyObject).value(forKey: "order_id")!)"
                            self.orderAcceptVw.lblRestaurantName.text = "\((self.unAssignedOrdersArr.object(at: 0) as AnyObject).value(forKey: "restaurant_name")!)"
                            self.orderAcceptVw.lblDelivery.text = "\((self.unAssignedOrdersArr.object(at: 0) as AnyObject).value(forKey: "delivery_address")!)"
                            self.orderAcceptVw.lblPickup.text = "\((self.unAssignedOrdersArr.object(at: 0) as AnyObject).value(forKey: "pickup_address")!)"
                            self.orderAcceptVw.lblPaymentType.text = "\((self.unAssignedOrdersArr.object(at: 0) as AnyObject).value(forKey: "payment_method")!)"
                            self.orderAcceptVw.lblOrderCount.text = "1/\(self.unAssignedOrdersArr.count)"
                        }
                        SharedManager.dismissHUD(viewController: self)
                    }else
                    {
                        
                        self.unAssignedOrdersArr.removeObject(at: 0)
                        if self.unAssignedOrdersArr.count == 0
                        {
                            if (self.orderAcceptVw.isDescendant(of: self.orderAcceptContainerVw))
                            {
                                self.orderAcceptVw.removeFromSuperview()
                                self.orderAcceptContainerBlurVw.removeFromSuperview()
                                self.orderAcceptContainerVw.removeFromSuperview()
                            }
                        }else{
                            self.orderAcceptVw.lblOrderId.text = "Order-Id: \((self.unAssignedOrdersArr.object(at: 0) as AnyObject).value(forKey: "order_id")!)"
                            self.orderAcceptVw.lblRestaurantName.text = "\((self.unAssignedOrdersArr.object(at: 0) as AnyObject).value(forKey: "restaurant_name")!)"
                            self.orderAcceptVw.lblDelivery.text = "\((self.unAssignedOrdersArr.object(at: 0) as AnyObject).value(forKey: "delivery_address")!)"
                            self.orderAcceptVw.lblPickup.text = "\((self.unAssignedOrdersArr.object(at: 0) as AnyObject).value(forKey: "pickup_address")!)"
                            self.orderAcceptVw.lblPaymentType.text = "\((self.unAssignedOrdersArr.object(at: 0) as AnyObject).value(forKey: "payment_method")!)"
                            self.orderAcceptVw.lblOrderCount.text = "1/\(self.unAssignedOrdersArr.count)"
                        }
                        SharedManager.showAlertWithMessage(title: "", alertMessage: ((responseObject.result.value!) as AnyObject).value(forKeyPath: "success.message") as! String, viewController: self)
                        SharedManager.dismissHUD(viewController: self)
                    }
                }else{
                    self.unAssignedOrdersArr.removeObject(at: 0)
                    if self.unAssignedOrdersArr.count == 0
                    {
                        if (self.orderAcceptVw.isDescendant(of: self.orderAcceptContainerVw))
                        {
                            self.orderAcceptVw.removeFromSuperview()
                            self.orderAcceptContainerBlurVw.removeFromSuperview()
                            self.orderAcceptContainerVw.removeFromSuperview()
                        }
                    }else{
                        self.orderAcceptVw.lblOrderId.text = "Order-Id: \((self.unAssignedOrdersArr.object(at: 0) as AnyObject).value(forKey: "order_id")!)"
                        self.orderAcceptVw.lblRestaurantName.text = "\((self.unAssignedOrdersArr.object(at: 0) as AnyObject).value(forKey: "restaurant_name")!)"
                        self.orderAcceptVw.lblDelivery.text = "\((self.unAssignedOrdersArr.object(at: 0) as AnyObject).value(forKey: "delivery_address")!)"
                        self.orderAcceptVw.lblPickup.text = "\((self.unAssignedOrdersArr.object(at: 0) as AnyObject).value(forKey: "pickup_address")!)"
                        self.orderAcceptVw.lblPaymentType.text = "\((self.unAssignedOrdersArr.object(at: 0) as AnyObject).value(forKey: "payment_method")!)"
                        self.orderAcceptVw.lblOrderCount.text = "1/\(self.unAssignedOrdersArr.count)"
                    }
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
    
    @objc func clickOrderReject(_ sender : UIButton)
    {
        SharedManager.showHUD(viewController: self)
        userIDStr = UserDefaults.standard.string(forKey: "USER_ID")!
        let orderId = "\((self.unAssignedOrdersArr.object(at: 0) as AnyObject).value(forKey: "order_id")!)"
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
                    //SharedManager.dismissHUD(viewController: self)
                    let result = responseObject.result.value! as AnyObject
                    if let code = result.value(forKeyPath: "success.status")
                    {
                        if code as! String == "200"
                        {
                            SharedManager.dismissHUD(viewController: self)
                            self.unAssignedOrdersArr.removeObject(at: 0)
                            if self.unAssignedOrdersArr.count == 0
                            {
                                if (self.orderAcceptVw.isDescendant(of: self.orderAcceptContainerVw))
                                {
                                    self.orderAcceptVw.removeFromSuperview()
                                    self.orderAcceptContainerBlurVw.removeFromSuperview()
                                    self.orderAcceptContainerVw.removeFromSuperview()
                                }

                            }else{
                                self.orderAcceptVw.lblOrderId.text = "Order-Id: \((self.unAssignedOrdersArr.object(at: 0) as AnyObject).value(forKey: "order_id")!)"
                                self.orderAcceptVw.lblRestaurantName.text = "\((self.unAssignedOrdersArr.object(at: 0) as AnyObject).value(forKey: "restaurant_name")!)"
                                self.orderAcceptVw.lblDelivery.text = "\((self.unAssignedOrdersArr.object(at: 0) as AnyObject).value(forKey: "delivery_address")!)"
                                self.orderAcceptVw.lblPickup.text = "\((self.unAssignedOrdersArr.object(at: 0) as AnyObject).value(forKey: "pickup_address")!)"
                                self.orderAcceptVw.lblPaymentType.text = "\((self.unAssignedOrdersArr.object(at: 0) as AnyObject).value(forKey: "payment_method")!)"
                                self.orderAcceptVw.lblOrderCount.text = "1/\(self.unAssignedOrdersArr.count)"
                            }
                        }else{
                            SharedManager.dismissHUD(viewController: self)
                            self.unAssignedOrdersArr.removeObject(at: 0)
                            if self.unAssignedOrdersArr.count == 0
                            {
                                if (self.orderAcceptVw.isDescendant(of: self.orderAcceptContainerVw))
                                {
                                    self.orderAcceptVw.removeFromSuperview()
                                    self.orderAcceptContainerBlurVw.removeFromSuperview()
                                    self.orderAcceptContainerVw.removeFromSuperview()
                                }
                            }else{
                                self.orderAcceptVw.lblOrderId.text = "Order-Id: \((self.unAssignedOrdersArr.object(at: 0) as AnyObject).value(forKey: "order_id")!)"
                                self.orderAcceptVw.lblRestaurantName.text = "\((self.unAssignedOrdersArr.object(at: 0) as AnyObject).value(forKey: "restaurant_name")!)"
                                self.orderAcceptVw.lblDelivery.text = "\((self.unAssignedOrdersArr.object(at: 0) as AnyObject).value(forKey: "delivery_address")!)"
                                self.orderAcceptVw.lblPickup.text = "\((self.unAssignedOrdersArr.object(at: 0) as AnyObject).value(forKey: "pickup_address")!)"
                                self.orderAcceptVw.lblPaymentType.text = "\((self.unAssignedOrdersArr.object(at: 0) as AnyObject).value(forKey: "payment_method")!)"
                                self.orderAcceptVw.lblOrderCount.text = "1/\(self.unAssignedOrdersArr.count)"
                            }
                            SharedManager.showAlertWithMessage(title: "", alertMessage: ((responseObject.result.value!) as AnyObject).value(forKeyPath: "success.message") as! String, viewController: self)
                        }
                    }else{
                        SharedManager.dismissHUD(viewController: self)
                        self.unAssignedOrdersArr.removeObject(at: 0)
                        if self.unAssignedOrdersArr.count == 0
                        {
                            if (self.orderAcceptVw.isDescendant(of: self.orderAcceptContainerVw))
                            {
                                self.orderAcceptVw.removeFromSuperview()
                                self.orderAcceptContainerBlurVw.removeFromSuperview()
                                self.orderAcceptContainerVw.removeFromSuperview()
                            }
                        }else{
                            self.orderAcceptVw.lblOrderId.text = "Order-Id: \((self.unAssignedOrdersArr.object(at: 0) as AnyObject).value(forKey: "order_id")!)"
                            self.orderAcceptVw.lblRestaurantName.text = "\((self.unAssignedOrdersArr.object(at: 0) as AnyObject).value(forKey: "restaurant_name")!)"
                            self.orderAcceptVw.lblDelivery.text = "\((self.unAssignedOrdersArr.object(at: 0) as AnyObject).value(forKey: "delivery_address")!)"
                            self.orderAcceptVw.lblPickup.text = "\((self.unAssignedOrdersArr.object(at: 0) as AnyObject).value(forKey: "pickup_address")!)"
                            self.orderAcceptVw.lblPaymentType.text = "\((self.unAssignedOrdersArr.object(at: 0) as AnyObject).value(forKey: "payment_method")!)"
                            self.orderAcceptVw.lblOrderCount.text = "1/\(self.unAssignedOrdersArr.count)"
                        }
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
    
    func changeIcon(imageVw: UIImageView, color: UIColor)
    {
        imageVw.image = imageVw.image!.withRenderingMode(.alwaysTemplate)
        imageVw.tintColor = color
    }
    
    /*
    //MARK: Navigation Bar Buttons
    
    @objc func closeMenu()
    {
        UIView.animate(withDuration: 0.50, animations: { () -> Void in
            
            self.mainTableView.frame = CGRect(x: -(UIScreen.main.bounds.size.width-120), y: 0, width: UIScreen.main.bounds.size.width-120, height: self.menuView.frame.height)
            
        }, completion: { (bol) -> Void in
            self.menuView.removeFromSuperview()
            self.mainTableView.removeFromSuperview()
        })
    }
    
    func setTitle()
    {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 25))
        imageView.contentMode = .scaleAspectFit
        let image = UIImage(named: "balleh")
        imageView.image = image
      //  navigationItem.titleView = imageView
        
        let button =  UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 50, height: 25)
      //  button.setTitle("Button", for: .normal)
        button.setBackgroundImage(image, for: .normal)
        button.addTarget(self, action: #selector(self.clickTitle), for: .touchUpInside)
        self.navigationItem.titleView = button
    }
    
    @objc func clickTitle()
    {
        self.gotoRootViewController()
    }
    
    func getCurrency()
    {
        SharedManager.showHUD(viewController: self)
        
        let urlStr = "\(ConfigUrl.baseUrl)delivery/local/currency"
        
        let setFinalURl = urlStr.addingPercentEncoding (withAllowedCharacters: .urlQueryAllowed)!
        var request = URLRequest(url: URL(string: setFinalURl)!)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        //  request.setValue("Bearer \(baseToken)", forHTTPHeaderField: "Authorization")
        
        Alamofire.request(request).responseJSON
            { (responseObject) -> Void in
                SharedManager.dismissHUD(viewController: self)
                if responseObject.result.isSuccess
                {
                    let result = responseObject.result.value! as AnyObject
                    print(result)
                    if let code = result.value(forKeyPath: "success.status")
                    {
                        SharedManager.dismissHUD(viewController: self)
                        if code as! String == "200"
                        {
                            
                            print(responseObject.result.value!)
                        }else
                        {
                            SharedManager.dismissHUD(viewController: self)
                            SharedManager.showAlertWithMessage(title: "", alertMessage: ((responseObject.result.value!) as AnyObject).value(forKeyPath: "message") as! String, viewController: self)
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
    
    func setLeftNavigationButton()
    {
        setTitle()
        setupSwipeGestureRecognizer()
        
        var image = UIImage(named: "ico-menu")
        image = image?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        
      //  self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.clickMenu(sender:)))
        
        let btn1 = UIButton(type: .custom)
        btn1.setImage(image, for: .normal)
        btn1.frame = CGRect(x: 0, y: 0, width: 40, height: 30)
        btn1.addTarget(self, action: #selector(self.clickMenu(sender:)), for: .touchUpInside)
        btn1.tag = 1
        
        image = UIImage(named: "right-arrow")
       // image = image?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        
        let btn2 = UIButton(type: .custom)
        btn2.setBackgroundImage(image, for: .normal)
        btn2.frame = CGRect(x: 0, y: 0, width: 20, height: 25)
        btn2.addTarget(self, action: #selector(self.clickClose(sender:)), for: .touchUpInside)
        btn2.tag = 2
        
        let item2 = UIBarButtonItem(customView: btn1)
        let item1 = UIBarButtonItem(customView: btn2)
      //  self.navigationItem.hid
        
        self.navigationItem.setLeftBarButtonItems([item1, item2], animated: true)
    }
    
    func setupSwipeGestureRecognizer()
    {
        //For left swipe
        let swipeGestureLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.swipedScreen))
        swipeGestureLeft.direction = .left
        self.view.addGestureRecognizer(swipeGestureLeft)
        
        //For right swipe
        let swipeGestureRight = UISwipeGestureRecognizer(target: self, action: #selector(self.swipedScreen))
        swipeGestureRight.direction = .right
        self.view.addGestureRecognizer(swipeGestureRight)
        
    }
    
    @objc func swipedScreen(gesture: UISwipeGestureRecognizer)
    {
        if gesture.direction == .left
        {
            self.closeMenu()
        }
        else if gesture.direction == .right
        {
            menuView.addSubview(self.mainTableView)
            self.view.addSubview(menuView)
            
            self.mainTableView.reloadData()
            
            UIView.animate(withDuration: 0.50, animations: {
                self.mainTableView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width-120, height: self.menuView.frame.height)
            })
        }
    }
    
    @objc func clickMenu(sender:UIBarButtonItem)
    {
        if self.mainTableView.frame.origin.x != 0
        {
            menuView.addSubview(self.mainTableView)
            self.view.addSubview(menuView)
            
            self.mainTableView.reloadData()
            
            UIView.animate(withDuration: 0.50, animations: {
                self.mainTableView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width-120, height: self.menuView.frame.height)
            })
        }
        else
        {
            self.closeMenu()
        }
        
        /*sideMenu.delegate = self
        sideMenu.frame = CGRect(x: 0, y: 64, width: self.view.bounds.size.width, height: self.view.bounds.size.height)
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {() -> Void in
            
            self.sideMenu.frame = CGRect(x: 0, y: 64, width: self.view.bounds.size.width, height: self.view.bounds.size.height)
            // basketBottom.frame = basketBottomFrame;
        }, completion: {(_ finished: Bool) -> Void in
            
            self.view.addSubview(self.sideMenu)
        })*/
    }
    
   /* @objc func clickCart(sender:UIBarButtonItem)
    {
        let next = self.storyboard?.instantiateViewController(withIdentifier: "CartVC") as! CartVC
        self.navigationController?.pushViewController(next, animated: true)
    }*/
    
    @objc func clickClose(sender:UIBarButtonItem)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Country List
    
    func getCountryList()
    {
        SharedManager.showHUD(viewController: self)
        
        let urlStr = "\(ConfigUrl.baseUrl)directory/countries"
        
        let setFinalURl = urlStr.addingPercentEncoding (withAllowedCharacters: .urlQueryAllowed)!
        var request = URLRequest(url: URL(string: setFinalURl)!)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer ", forHTTPHeaderField: "Authorization")
        
        Alamofire.request(request).responseJSON
            { (responseObject) -> Void in
                SharedManager.dismissHUD(viewController: self)
                if responseObject.result.isSuccess
                {
                    let result = responseObject.result.value! as AnyObject
                    print(result)
                    if let code = result.value(forKeyPath: "success.status")
                    {
                        if code as! String == "200"
                        {
                            print(responseObject.result.value!)
                            let result = responseObject.result.value! as! NSArray
                            countryArr = result.mutableCopy() as! NSMutableArray
                            stateArr = ((countryArr.object(at: 0) as AnyObject).value(forKey: "available_regions") as! NSArray).mutableCopy() as! NSMutableArray
                            self.countryIDStr = (((responseObject.result.value!) as AnyObject).object(at: 0) as AnyObject).value(forKeyPath: "id") as! String
                        }else
                        {
                            SharedManager.showAlertWithMessage(title: "", alertMessage: ((responseObject.result.value!) as AnyObject).value(forKeyPath: "message") as! String, viewController: self)
                        }
                    }
                    else
                    {
                        SharedManager.showAlertWithMessage(title: "", alertMessage: ((responseObject.result.value) as AnyObject).value(forKeyPath: "error.message") as! String, viewController: self)
                    }
                }
                if responseObject.result.isFailure
                {
                    let error : Error = responseObject.result.error!
                    print(error.localizedDescription)
                }
        }
    }
    
    //MARK: Bar Buttons
    
    func clickBarButtonBack()
    {
        self.dismiss(animated: true, completion: {})
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func fitTableFrame(table: UITableView)//, container: UIView, addHeight: CFloat)
    {
        table.frame.size.height = table.contentSize.height
    }
    
    func converToJSon(values: AnyObject) -> AnyObject
    {
        var jsonStr:String = ""
        do
        {
            let jsonData: Data = try JSONSerialization.data(withJSONObject: values, options: JSONSerialization.WritingOptions.prettyPrinted)
            
            jsonStr = NSString.init(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
        }
            
        catch {
            print("error")
        }
        
        return jsonStr as AnyObject
    }
    
    func isValidEmail(_ testStr:String) -> Bool {
        
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func formatCurrency(value: Double) -> String
    {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2;
        formatter.locale = Locale(identifier: Locale.current.identifier)
        let result = formatter.string(from: value as NSNumber);
        return result!;
    }
    
    func gotoRootViewController()
    {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "tabBarcontroller") as! UITabBarController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window = UIWindow(frame: UIScreen.main.bounds)
        appDelegate.window?.rootViewController = viewController
        appDelegate.window?.makeKeyAndVisible()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: TableView Methods
    func numberOfSections(in tableView: UITableView) -> Int
    {
        if tableView == mainTableView
        {
            return 0
        }
        else
        {
            if categoryDict.count != 0
            {
                return 0
            }
            else
            {
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if tableView == mainTableView
        {
            return 0
        }
        else
        {
            if categoryDict.count != 0
            {
                return 0
            }
            else
            {
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if tableView == mainTableView
        {
            if indexPath.section != 1
            {
                let cell1 = tableView.dequeueReusableCell(withIdentifier: "cell") as! UITableViewCell
                
                /* if cell1 == nil {
                 var views = Bundle.main.loadNibNamed("DetailCell", owner: nil, options: nil)
                 for view: UIView in views {
                 if (view is UITableViewCell) {
                 cell1 = view as? DetailCell
                 }
                 }
                 }*/
                
               
                cell1.selectionStyle = .none
                
                return cell1
            }
            else
            {
                let cell1 = tableView.dequeueReusableCell(withIdentifier: "cell") as! UITableViewCell
                
//                cell1.insideTableView.dataSource = self
//                cell1.insideTableView.delegate = self
//                cell1.insideTableView.reloadData()
//                cell1.selectionStyle = .none
                
                return cell1
            }
        }
        else
        {
            var cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "Cell")
            if cell == nil
            {
                cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "Cell")
            }
            
            cell?.textLabel?.font = UIFont.systemFont(ofSize: 15)
            cell?.textLabel?.textColor = .darkGray
            cell?.textLabel?.frame.origin.x = 20
            
            cell?.textLabel?.text = (((categoryDict[indexPath.section] as AnyObject).value(forKeyPath: "children_data") as AnyObject).object(at: indexPath.row) as AnyObject).value(forKeyPath: "name") as? String
            cell?.selectionStyle = .none
            
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        if tableView == mainTableView
        {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 18))
            let label = UILabel(frame: CGRect(x: 10, y: 5, width: tableView.frame.size.width - 10, height: 25))
            label.font = UIFont.boldSystemFont(ofSize: 16)
            label.textColor = UIColor.white
         //   let string = "\(titleArr[section])"
            label.text = "string"
            view.addSubview(label)
            view.backgroundColor = .lightGray
            return view
            
            /* let view = DetailCell ()
             view.frame = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 44)
             view.backgroundColor = .green
             // view.imgArrow.image = UIImage (named: "left-arrow.png")
             // view.title.text = "Main category"
             // view.imgIcon.image = UIImage (named: "ic_favorite.png")
             
             return view*/
        }
        else
        {
           /* let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? CollapsibleTableViewHeader ?? CollapsibleTableViewHeader(reuseIdentifier: "header")
            
            header.frame = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 44)
            header.titleLabel.text = (categoryDict[section] as AnyObject).value(forKeyPath: "name") as? String
            header.titleLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
            header.arrowImage.image = UIImage (named: "left-arrow")
            header.setCollapsed((categoryDict[section] as AnyObject).value(forKeyPath: "isCollapsed") as! Bool)
            
            header.section = section
            header.delegate = self*/
            
            let header = UIView()
            
            return header
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        if tableView == mainTableView
        {
            if section == 0
            {
                return 0
            }
            else
            {
                return 0
            }
        }
        else
        {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if tableView == mainTableView
        {
            return 0
        }
        else
        {
            let collapsed = ((categoryDict[indexPath.section] as AnyObject).value(forKeyPath: "isCollapsed") as! Bool)
            
            if collapsed
            {
                return 0
            }
            else
            {
                return 0
            }
          //  return !((categoryDict[indexPath.section] as AnyObject).value(forKeyPath: "isCollapsed") as! Bool) ? 0 : 40.0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
       /* if tableView == mainTableView
        {
            let action = mainTblArray[indexPath.section][indexPath.row] as! String
            
            if action == "Home"
            {
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
                self.navigationController?.pushViewController(viewController, animated: true)
            }
            else if action == "Login"
            {
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                self.navigationController?.pushViewController(viewController, animated: true)
            }
            else if action == "Deals"
            {
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: "DealsVC") as! DealsVC
                self.navigationController?.pushViewController(viewController, animated: true)
            }
            else if action == "Live Chat"
            {
                Intercom.presentMessenger()
            }
            else if action == "Track Order"
            {
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: "TrackOrderVC") as! TrackOrderVC
                self.navigationController?.pushViewController(viewController, animated: true)
            }
            else if action == "Share"
            {
                // text to share
                let text = "https://balleh.com/"
                
                let textToShare = [ text ]
                let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
                activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook ]
                
                self.present(activityViewController, animated: true, completion: nil)
            }
        }
        else
        {
            let id = "\(String(describing: (((categoryDict[indexPath.section] as AnyObject).value(forKeyPath: "children_data") as AnyObject).object(at: indexPath.row) as AnyObject).value(forKeyPath: "id")!))"
            let name = "\(String(describing: (((categoryDict[indexPath.section] as AnyObject).value(forKeyPath: "children_data") as AnyObject).object(at: indexPath.row) as AnyObject).value(forKeyPath: "name")!))"
            
            print("Category ID: \(id)")
            categoryID = id
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "SubCategoryVC") as! SubCategoryVC
            viewController.categoryID = id
            viewController.isFromHome = true
            viewController.catTitle = name
            self.navigationController?.pushViewController(viewController, animated: true)
        }*/
    }*/
    
   /* func toggleSection(_ header: CollapsibleTableViewHeader, section: Int)
    {
        let cell1 = mainTableView.dequeueReusableCell(withIdentifier: "CatCell") as! categoryTCell
        
        cell1.insideTableView.dataSource = self
        cell1.insideTableView.delegate = self
        
        var collapsed = ((categoryDict[section] as AnyObject).value(forKeyPath: "isCollapsed") as! Bool)
        
        if collapsed
        {
            collapsed = false
        }
        else
        {
            collapsed = true
        }
        
        // Toggle collapse
        (categoryDict[section] as AnyObject).setValue(collapsed, forKey: "isCollapsed")
        header.setCollapsed(collapsed)
        
        // Adjust the height of the rows inside the section
        cell1.insideTableView.beginUpdates()
        for i in 0 ..< (self.categoryDict[section] as AnyObject).count
        {
            cell1.insideTableView.reloadRows(at: [IndexPath(row: i, section: section)], with: .automatic)
        }
        cell1.insideTableView.endUpdates()
        
      //  cell1.insideTableView.frame.size.height = cell1.insideTableView.contentSize.height
        
        self.mainTableView.reloadData()
        // frames()
    }*/
    
    //MARK: Check Wishlist
   /* func checkProductInWishList(_ productId:String) -> Bool
    {
        var isAleadyHave:Bool = false
        
        if UserDefaults.standard.object(forKey: kAddToWishlist) != nil
        {
            let data = UserDefaults.standard.object(forKey: kAddToWishlist) as! Data
            let favAry:NSMutableArray = NSKeyedUnarchiver.unarchiveObject(with: data) as! NSMutableArray
            
            for tempDic in favAry
            {
                let tempCart:NSDictionary = tempDic as! NSDictionary
                
                let str1 = tempCart.value(forKey: "sku") as! NSString
                print(str1, productId)
                if str1.isEqual(to: productId as String)
                {
                    isAleadyHave = true
                }
            }
        }
        return isAleadyHave
    }
    
    //MARK: Check Cart
    func checkProductInCart(_ productId:String) -> Bool
    {
        var isAleadyHave:Bool = false
        
        if UserDefaults.standard.object(forKey: kAddToCart) != nil
        {
            let data = UserDefaults.standard.object(forKey: kAddToCart) as! Data
            let cartAry:NSMutableArray = NSKeyedUnarchiver.unarchiveObject(with: data) as! NSMutableArray
            
            for tempDic in cartAry
            {
                let tempCart:NSDictionary = tempDic as! NSDictionary
                
                let str1 = tempCart.value(forKey: "id") as! NSString
                
                if str1.isEqual(to: productId as String)
                {
                    isAleadyHave = true
                }
            }
            
        }
        
        return isAleadyHave
    }*/
    
   /* func getCartDetails(cusToken: String, completionHandler:@escaping (_ result:NSMutableArray)->())
    {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
            
        var result = NSMutableArray()
        let urlStr = "\(ConfigUrl.baseUrl)carts/mine/items"
        
        let setFinalURl = urlStr.addingPercentEncoding (withAllowedCharacters: .urlQueryAllowed)!
        var request = URLRequest(url: URL(string: setFinalURl)!)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(cusToken)", forHTTPHeaderField: "Authorization")
        
        Alamofire.request(request).responseJSON
            { (responseObject) -> Void in
                
                if responseObject.result.isSuccess
                {
                    SharedManager.dismissHUD(viewController: self)
                    
                    if "\(String(describing: responseObject.response!.statusCode))" == "200"
                    {
                        result = (responseObject.result.value! as! NSArray).mutableCopy() as! NSMutableArray
                        print(responseObject.result.value!)
                        
                        var count = 0
                        
                        for i in 0..<result.count
                        {
                            let qty = "\((result[i] as AnyObject).value(forKey:"qty")!)"
                            
                            count = count + Int(qty)!
                        }
                        
                        cartCount = "\(count)"
                        
                        self.setRightNavigationButton()
                        
                     //   self.deleteCartItem(cusToken: cusToken, itemId: "\(result[0].value(forKey:"item_id")!)")
                    }
                    else if "\(String(describing: responseObject.response!.statusCode))" == "401"
                    {
                        let alert = UIAlertController(title: "Your Session Expired!", message: "Please Login to Continue", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {(alert :UIAlertAction) in
                            
                            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                            self.navigationController?.pushViewController(viewController, animated: true)
                        }))
                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(alert :UIAlertAction) in
                            isGuest = true
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                    else
                    {
                        SharedManager.showAlertWithMessage(title: "", alertMessage: ((responseObject.result.value) as AnyObject).value(forKeyPath: "message") as! String, viewController: self)
                    }
                }
                if responseObject.result.isFailure
                {
                    SharedManager.dismissHUD(viewController: self)
                    let error : Error = responseObject.result.error!
                    print(error.localizedDescription)
                }
            }
            DispatchQueue.main.async
                {
                    completionHandler(result)
            }
        }
    }*/
}

class Connectivity {
    class func isConnectedToInternet() ->Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}
