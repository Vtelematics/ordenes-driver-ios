//
//  ViewController.swift
//  FoodDelivery
//
//  Created by Adyas Iinfotech on 16/03/18.
//  Copyright © 2018 Adyas Iinfotech. All rights reserved.
//

import UIKit
import Alamofire
import Reachability
import Firebase
import CoreLocation

class HomeViewController: ParentViewController, CLLocationManagerDelegate
{
    @IBOutlet var switchObj: UISwitch!
    @IBOutlet var vwSwitch: UIView!
    @IBOutlet var vwSideMenu: UIView!
    @IBOutlet var vwTblMenu: UIView!
    @IBOutlet var tblMenu: UITableView!
    @IBOutlet var tblDelivery: UITableView!
    @IBOutlet var lblDriverName: UILabel!
    @IBOutlet var imgDriver: UIImageView!
    @IBOutlet var lblMobileNumber: UILabel!
    @IBOutlet var viewEmpty: UIView!
    @IBOutlet var imgEmpty: UIImageView!
    
    // language
    @IBOutlet weak var viewLanguage: UIView!
    @IBOutlet weak var btnLanguage: UIButton!
    @IBOutlet weak var lblArabic: UILabel!
    @IBOutlet weak var imgArabic: UIImageView!
    @IBOutlet weak var lblEnglish: UILabel!
    @IBOutlet weak var imgEnglish: UIImageView!
    @IBOutlet weak var viewBlur: UIView!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var tblLanguage: UITableView!
    @IBOutlet weak var btnCancelLanugae: UIButton!
    @IBOutlet weak var btnChangeLanguage: UIButton!
    
    var alertView = UIView()
    var isFromNotification = Bool()
    var refreshControl: UIRefreshControl!
    var isRefreshing : Bool = false
    var languageArr = NSArray()
    var orderArr = NSMutableArray()
    var ref: DatabaseReference!
    var appStoreVersion = ""
    
    var locationManager = CLLocationManager()
    var currentLat = ""
    var currentLong = ""
    var timer = Timer()
    
    //Language
//    var menuArr = [NSLocalizedString("Delivery History", comment: ""), NSLocalizedString("Earning History", comment: ""), NSLocalizedString("Profile", comment: ""), NSLocalizedString("Change Language", comment: ""), NSLocalizedString("App Logout", comment: "")]
//    var iconsArr = ["all_history", "dollar","ic_profile", "ic_lang", "ic_logout"]
//
    var menuArr = [NSLocalizedString("Delivery History", comment: ""), NSLocalizedString("Earning History", comment: ""), NSLocalizedString("Profile", comment: ""), NSLocalizedString("App Logout", comment: "")]
    var iconsArr = ["all_history", "dollar","ic_profile", "ic_logout"]

    var isScrolledOnce : Bool = false
    var page:Int = 1
    var pageCount = Double()
    var limit:String = "15"
    var selectedLanguage = ""
    
    //push noti view
    var isOrderId : String = ""
    var isPickupAddress : String = ""
    var isDeliveryAddress : String = ""
    var isPaymentMethod : String = ""
    
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat
    {
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.frame.height
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        userIDStr = UserDefaults.standard.string(forKey: "USER_ID")!
        self.getUnAssignedOrder()
        if let data = UserDefaults.standard.value(forKey: kUserDetails)
        {
            let userdetails = NSKeyedUnarchiver.unarchiveObject(with: data as! Data)
            lblDriverName.text = "\((userdetails as AnyObject).value(forKey: "name")!)"
            lblMobileNumber.text = "\((userdetails as AnyObject).value(forKey: "telephone")!)"
            if let imageUrl = (userdetails as AnyObject).value(forKey: "driver_pic"), "\(imageUrl)" != "<null>", "\(imageUrl)" != ""
            {
                let trimmedUrl = (imageUrl as AnyObject).trimmingCharacters(in: CharacterSet(charactersIn: "")).replacingOccurrences(of: " ", with: "%20") as String
                self.imgDriver.sd_setImage(with: URL(string: trimmedUrl))
            }
        }
        
        let driverID = "\(UserDefaults.standard.string(forKey: "DRIVER_ID")!)"
        self.ref = Database.database().reference()
        self.ref.child("drivers").child(driverID).observeSingleEvent(of: .value, with: { (snapshot) in
            let result = snapshot.value as? NSDictionary
            if result != nil{
                if result!.value(forKey: "shift") != nil{
                    if "\(String(describing: result!.value(forKey: "shift")!))" == "1"{
                        self.switchObj.isOn = true
                        self.switchObj.onTintColor = themeColor
                        self.locationManager.startUpdatingLocation()
                        UserDefaults.standard.set("1", forKey: "SHIFT_STATUS")
                    }else{
                        self.switchObj.isOn = false
                        self.locationManager.stopUpdatingLocation()
                        UserDefaults.standard.set("0", forKey: "SHIFT_STATUS")
                    }
                }
            }
        })
        
        self.orderArr.removeAllObjects()
        getTask()
        let locStatus = CLLocationManager.authorizationStatus()
        switch locStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            return
        case .denied, .restricted:
            let alert = UIAlertController(title: "Location Services are disabled", message: "Please enable Location Services in your Settings", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
            return
        case .authorizedAlways, .authorizedWhenInUse:
            break
        @unknown default:
            break
        }
    }
    
    @objc func clickUnassignedOrders(_ sender : UIButton){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "UnassignOrderViewController")
            as! UnassignOrderViewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    //MARK: Button action
    @IBAction func clickCancelLang(_ sender: Any)
    {
        self.viewBlur.isHidden = true
        self.viewLanguage.removeFromSuperview()
    }
    
    @IBAction func clickSaveLang(_ sender: Any)
    {
        languageID = self.selectedLanguage
        if languageID == "1"{
            languageCode = "en"
            isRTLenabled = false
        }else{
            languageCode = "ar"
            isRTLenabled = true
        }
        UserDefaults.standard.set(languageID, forKey: "language_id")
        UserDefaults.standard.set(languageCode, forKey: "language_code")
        let selectedLanguage:Languages = Int(languageID) == 1 ? .en : .ar
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        // change the language
        if #available(iOS 9.0, *)
        {
            LanguageManger.shared.setLanguage(language: selectedLanguage)
        }
        else
        {
            // Fallback on earlier versions
        }
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window = UIWindow(frame: UIScreen.main.bounds)
        let navigationController = UINavigationController.init(rootViewController: viewController)
        appDelegate.window?.rootViewController = navigationController
        appDelegate.window?.makeKeyAndVisible()
    }
    
    @IBAction func clickMenu(sender: AnyObject!)
    {
        if (vwTblMenu.isDescendant(of: vwSideMenu))
        {
            self.closeMenu()
        }else{
            self.vwSideMenu.isHidden = false
            vwSideMenu.addSubview(self.vwTblMenu)
            self.tblMenu.reloadData()
            if isRTLenabled{
                UIView.animate(withDuration: 0.50, animations: {
                    let width = UIScreen.main.bounds.size.width-100
                    let x = UIScreen.main.bounds.size.width - width
                    self.vwTblMenu.frame = CGRect(x: x, y: 0, width: width, height: self.vwSideMenu.frame.height)
                })
            }else{
                UIView.animate(withDuration: 0.50, animations: {
                    self.vwTblMenu.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width-100, height: self.vwSideMenu.frame.height)
                })
            }
            self.vwTblMenu.translatesAutoresizingMaskIntoConstraints = true
        }
    }
    
    @objc func closeMenu()
    {
        UIView.animate(withDuration: 0.50, animations: { () -> Void in
            if isRTLenabled{
                self.vwTblMenu.frame = CGRect(x: UIScreen.main.bounds.size.width, y: 0, width: UIScreen.main.bounds.size.width-100, height: self.vwSideMenu.frame.height)
            }else{
                self.vwTblMenu.frame = CGRect(x: -(UIScreen.main.bounds.size.width-100), y: 0, width: UIScreen.main.bounds.size.width-100, height: self.vwSideMenu.frame.height)
            }
        }, completion: { (bol) -> Void in
            self.vwSideMenu.isHidden = true
            self.vwTblMenu.removeFromSuperview()
        })
    }
    
    @IBAction func switchValueDidChange(sender: AnyObject!)
    {
        
        if switchObj.isOn
        {
            self.shiftApi(status: "1")
            self.switchObj.onTintColor = themeColor
            
        }
        else
        {
            self.shiftApi(status: "0")
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: LocationManager delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.last != nil {
            print("location update")
            if let userId = UserDefaults.standard.string(forKey: "USER_ID"), userId != "" {
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                let locValue: CLLocationCoordinate2D = manager.location!.coordinate
                driverLatitude = locValue.latitude
                driverLongitude = locValue.longitude
                var status = "0"
                if switchObj.isOn
                {
                    status = "1"
                }
                var busyStatus = "0"
                if orderArr.count != 0{
                    busyStatus = "1"
                }
                UserDefaults.standard.set(status, forKey: "SHIFT_STATUS")
                var driverImg = ""
                if let data = UserDefaults.standard.value(forKey: kUserDetails)
                {
                    let userdetails = NSKeyedUnarchiver.unarchiveObject(with: data as! Data)
                    if let imageUrl = (userdetails as AnyObject).value(forKey: "driver_pic"), "\(imageUrl)" != "<null>", "\(imageUrl)" != ""
                    {
                        let trimmedUrl = (imageUrl as AnyObject).trimmingCharacters(in: CharacterSet(charactersIn: "")).replacingOccurrences(of: " ", with: "%20") as String
                        driverImg = trimmedUrl
                    }
                }
                
                self.ref = Database.database().reference()
                if let driverID = UserDefaults.standard.string(forKey: "DRIVER_ID"), driverID != "" {
                    if status == "1"{
                        ref.child("drivers").child(driverID).setValue(["latitude": "\(driverLatitude)", "longitude": "\(driverLongitude)", "name": lblDriverName.text!, "shift": status, "image": driverImg, "busy": busyStatus, "telephone": lblMobileNumber.text!]) {
                            (error:Error?, ref:DatabaseReference) in
                        }
                    }else{
                        self.locationManager.stopUpdatingLocation()
                    }
                }else{
                    self.locationManager.stopUpdatingLocation()
                }
            }else{
                self.locationManager.stopUpdatingLocation()
            }
        }
    }
    
    //MARK: Functions
    func setupUI(){
        if let userId = UserDefaults.standard.string(forKey: "USER_ID"), userId != "" {
            userIDStr = userId
        }
//        if isUpdateTheApp == true{
//        DispatchQueue.global().async {
//            do {
//                let update = try self.isUpdateAvailable()
//
//                print("update",update)
//                DispatchQueue.main.async {
//                    if update{
//                        self.popupUpdateDialogue();
//                        isUpdateTheApp = false
//                        }
//                    }
//                } catch {
//                    print(error)
//                }
//            }
//        }
        self.tblDelivery.isHidden = true
        self.locationManager.distanceFilter = 5
        self.locationManager.allowsBackgroundLocationUpdates = true
        self.locationManager.delegate = self
        
        self.navigationController?.navigationBar.isHidden = false
        var image = UIImage(named: "menu")
        image = image?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.clickMenu(sender:)))
        if isRTLenabled{
            let width = UIScreen.main.bounds.size.width-100
            let x = UIScreen.main.bounds.size.width - width
            self.vwTblMenu.frame = CGRect(x: x, y: 0, width: width, height: self.vwSideMenu.frame.height)
        }else{
            self.vwTblMenu.frame = CGRect(x: -(UIScreen.main.bounds.size.width-100), y: 0, width: UIScreen.main.bounds.size.width-100, height: self.vwSideMenu.frame.height)
        }
        self.vwTblMenu.removeFromSuperview()
        self.btnClose.addTarget(self, action: #selector(self.closeMenu), for: UIControl.Event.touchUpInside)
        NotificationCenter.default.addObserver(self, selector: #selector(updateLocationOnBackground(_:)), name: .enableBackgroundMode, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopLocationUpdate(_:)), name: .disableBackgroundMode, object: nil)
        let btnUnassign = UIButton(type: UIButton.ButtonType.custom)
        btnUnassign.addTarget(self, action:#selector(clickUnassignedOrders(_:)), for: .touchUpInside)
        btnUnassign.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let imgUnassign = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        imgUnassign.image = UIImage(named: "ic_alert")
        alertView.frame = CGRect(x: 17, y: 0, width: 10, height: 10)
        alertView.layer.cornerRadius = 5
        let viewUnassign = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        viewUnassign.addSubview(imgUnassign)
        viewUnassign.addSubview(alertView)
        viewUnassign.addSubview(btnUnassign)
        let barButton = UIBarButtonItem(customView: viewUnassign)
        self.navigationItem.rightBarButtonItems = [barButton]
        //getLanguage()
    }
    
    func isUpdateAvailable() throws -> Bool {
        guard let info = Bundle.main.infoDictionary,
            let currentVersion = info["CFBundleShortVersionString"] as? String,
            let identifier = info["CFBundleIdentifier"] as? String,
            let url = URL(string: "http://itunes.apple.com/lookup?bundleId=\(identifier)") else {
                throw VersionError.invalidBundleInfo
        }
        let data = try Data(contentsOf: url)
        guard let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String: Any] else {
            throw VersionError.invalidResponse
        }

        if let result = (json["results"] as? [Any])?.first as? [String: Any], let version = result["version"] as? String {
            print("version in app store", version,currentVersion);
            appStoreVersion = version
            return version != currentVersion
        }
        throw VersionError.invalidResponse
    }
    
    func popupUpdateDialogue(){
        
        let alertMessage = NSLocalizedString("A new version of FMdelivery Application is available,Please update to version ", comment: "")+appStoreVersion;
        let alert = UIAlertController(title: NSLocalizedString("New Version Available", comment: ""), message: alertMessage, preferredStyle: UIAlertController.Style.alert)
        
        let okBtn = UIAlertAction(title: NSLocalizedString("Update", comment: ""), style: .default, handler: {(_ action: UIAlertAction) -> Void in
            if let url = URL(string: "itms-apps://itunes.apple.com/us/app/fmdelivery/id1604531083"),
                UIApplication.shared.canOpenURL(url){
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        })
        let noBtn = UIAlertAction(title: NSLocalizedString("Skip this Version", comment: "") , style: .destructive, handler: {(_ action: UIAlertAction) -> Void in
        })
        alert.addAction(okBtn)
        alert.addAction(noBtn)
        self.present(alert, animated: true, completion: nil)
    }
    
    func getTask(){
        SharedManager.showHUD(viewController: self)
        self.tblDelivery.delegate = self
        self.tblDelivery.dataSource = self
        self.ref = Database.database().reference()
        if let driverID = UserDefaults.standard.string(forKey: "DRIVER_ID"), driverID != "" {
            self.ref.child("tasks").observe(.childAdded, with: {(snapshot) in
                let result = snapshot.value as? NSDictionary
                
                if result!.value(forKey: "driver_id") != nil{
                    if let status = result!.value(forKey: "status"), status as! String == "1"{
                        let id = "\(result!.value(forKey: "driver_id")!)"
                        if id == driverID{
                            let keyVal = snapshot.key as String
                            result?.setValue(keyVal, forKey: "order_id")
                            self.orderArr.add(result as Any)
                            self.tblDelivery.reloadData()
                            self.postBusyStatus()
                        }
                    }
                }
            })
            self.ref.child("tasks").observe(.childChanged, with: {(snapshot) in
                let result = snapshot.value as? NSDictionary
                let keyVal = snapshot.key as String
                let tempArr = NSMutableArray()
                tempArr.addObjects(from: self.orderArr as! [Any])
                
                if result!.value(forKey: "driver_id") != nil{
                    for i in 0..<self.orderArr.count{
                        let orderId = (self.orderArr.object(at: i) as AnyObject).value(forKey: "order_id") as! String
                        if keyVal == orderId{
                            let id = "\(result!.value(forKey: "driver_id")!)"
                            if id == driverID{
                    
                                result?.setValue(keyVal, forKey: "order_id")
                                self.orderArr.removeObject(at: i)
                                self.postBusyStatus()
                                self.tblDelivery.reloadData()
                                break
                            }
                        }
                    }
                    
                    if let status = result!.value(forKey: "status"), status as! String == "1"{
                    let id = "\(result!.value(forKey: "driver_id")!)"
                    if id == driverID{
                        let keyVal = snapshot.key as String
                        result?.setValue(keyVal, forKey: "order_id")
                        self.orderArr.add(result as Any)
                        self.tblDelivery.reloadData()
                        self.postBusyStatus()
                        }
                    }
                }
            })
            
            self.ref.child("tasks").observe(.childRemoved, with: {(snapshot) in
                let keyVal = snapshot.key as String
                for i in 0..<self.orderArr.count{
                    let orderId = (self.orderArr.object(at: i) as AnyObject).value(forKey: "order_id") as! String
                    if keyVal == orderId{
                        self.orderArr.removeObject(at: i)
                        self.postBusyStatus()
                        break
                    }
                }
                self.tblDelivery.reloadData()
            })
        }
        SharedManager.dismissHUD(viewController: self)
    }
    
    func postBusyStatus(){
        let driverID = "\(UserDefaults.standard.string(forKey: "DRIVER_ID")!)"
        var busyStatus = "0"
        if orderArr.count != 0{
            busyStatus = "1"
        }
        self.ref = Database.database().reference()
        ref.child("drivers").child(driverID).updateChildValues(["busy": busyStatus]) {
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                print(error)
            }else{
            }
        }
    }
    
    func getLanguage(){
        if Connectivity.isConnectedToInternet()
        {
            let urlStr = "\(ConfigUrl.baseUrl)delivery/local/language"
            
            let setFinalURl = urlStr.addingPercentEncoding (withAllowedCharacters: .urlQueryAllowed)!
            var request = URLRequest(url: URL(string: setFinalURl)!)
            request.httpMethod = HTTPMethod.get.rawValue
            
            Alamofire.request(request).responseJSON
                { (responseObject) -> Void in
                    
                    if responseObject.result.isSuccess
                    {
                        print(responseObject.result.value!)
                        
                        let result = responseObject.result.value! as AnyObject
                        print(result)
                        if let code = result.value(forKeyPath: "success.status")
                        {
                            SharedManager.dismissHUD(viewController: self)
                            if code as! String == "200"
                            {
                                let result = responseObject.result.value! as AnyObject
                                self.languageArr = result.value(forKey: "languages") as! NSArray
                                self.tblLanguage.reloadData()
                                self.tblLanguage.frame.size.height = CGFloat(self.languageArr.count * 45)
                                self.tblLanguage.translatesAutoresizingMaskIntoConstraints = true
                                self.btnCancelLanugae.frame.origin.y = self.tblLanguage.frame.origin.y + self.tblLanguage.frame.size.height + 8
                                self.btnChangeLanguage.frame.origin.y = self.tblLanguage.frame.origin.y + self.tblLanguage.frame.size.height + 8
                                self.btnChangeLanguage.translatesAutoresizingMaskIntoConstraints = true
                                self.btnCancelLanugae.translatesAutoresizingMaskIntoConstraints = true
                                self.viewLanguage.frame.size.height = self.btnChangeLanguage.frame.origin.y + self.btnChangeLanguage.frame.size.height + 8
                                self.viewLanguage.translatesAutoresizingMaskIntoConstraints = true
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
        else
        {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "ErrorViewController")
                as! ErrorViewController
            self.present(viewController, animated: true, completion: { () -> Void in
            })
        }
    }
    
    func shiftApi(status: String)
    {
        self.view.endEditing(true)
        SharedManager.showHUD(viewController: self)
        userIDStr = UserDefaults.standard.string(forKey: "USER_ID")!
        let params = [
            "shift_status": status
        ] as [String: Any]
        let urlStr = "\(ConfigUrl.baseUrl)shift-change"
        let setFinalURl = urlStr.addingPercentEncoding (withAllowedCharacters: .urlQueryAllowed)!
        var request = URLRequest(url: URL(string: setFinalURl)!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(userIDStr, forHTTPHeaderField: "Driver-Authorization")
        let setTemp: [String : Any] = params
        if let jsonData: Data = try? JSONSerialization.data(withJSONObject: setTemp, options: .prettyPrinted) {
            let jsonString = String(data: jsonData , encoding: .utf8)
            print(jsonString as Any)
            request.httpBody = jsonData
        }
        if Connectivity.isConnectedToInternet()
        {
            Alamofire.request(request).responseJSON { (responseObject) -> Void in
                if responseObject.result.isSuccess
                {
                    let result = responseObject.result.value! as AnyObject
                    if let code = result.value(forKeyPath: "success.status")
                    {
                        if code as! String == "200"
                        {
                            UserDefaults.standard.set(status, forKey: "SHIFT_STATUS")
                            let driverID = "\(UserDefaults.standard.string(forKey: "DRIVER_ID")!)"
                            if status == "1"
                            {
                                self.ref = Database.database().reference()
                                self.ref.child("drivers").child(driverID).updateChildValues(["shift": "1"]) {
                                    (error:Error?, ref:DatabaseReference) in
                                    if let error = error {
                                        print(error)
                                    }else{
                                        self.locationManager.startUpdatingLocation()
                                    }
                                }
                                SharedManager.showAlertWithMessage(title: "", alertMessage: NSLocalizedString("Logged-in Successfully", comment: ""), viewController: self)
                            }
                            else
                            {
                                self.ref = Database.database().reference()
                                self.ref.child("drivers").child(driverID).updateChildValues(["shift": "0"]) {
                                    (error:Error?, ref:DatabaseReference) in
                                    if let error = error {
                                        print(error)
                                    }else{
                                        self.locationManager.stopUpdatingLocation()
                                    }
                                }
                                SharedManager.showAlertWithMessage(title: "", alertMessage: NSLocalizedString("Logged-out Successfully", comment: ""), viewController: self)
                            }
                        }
                        SharedManager.dismissHUD(viewController: self)
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
    
    @objc func getUnAssignedOrder()
    {
        //SharedManager.showHUD(viewController: self)
        self.view.endEditing(true)
        let params = [
            "page": "1",
            "page_per_unit": "10"
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
            Alamofire.request(request).responseJSON { (responseObject) -> Void in
                if responseObject.result.isSuccess
                {
                    let result = responseObject.result.value! as AnyObject
                    if let code = result.value(forKeyPath: "success.status")
                    {
                        if code as! String == "200"
                        {
                            let unAssignedOrder = (result.value(forKey: "order") as! NSArray).mutableCopy() as! NSMutableArray
                            if unAssignedOrder.count != 0{
                                self.alertView.backgroundColor = UIColor(red: 8/255, green: 138/255, blue: 8/255, alpha: 1)
                            }else{
                                self.alertView.backgroundColor = .clear
                            }
                        }
                    }else{
                        
                        SharedManager.showAlertWithMessage(title: "", alertMessage: ((responseObject.result.value!) as AnyObject).value(forKeyPath: "error.message") as! String, viewController: self)
                    }
                    //SharedManager.dismissHUD(viewController: self)
                }
                if responseObject.result.isFailure
                {
                    //SharedManager.dismissHUD(viewController: self)
                    let error : Error = responseObject.result.error!
                    print(error.localizedDescription)
                }
            }
        }else
        {
            //SharedManager.dismissHUD(viewController: self)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "ErrorViewController")
                as! ErrorViewController
            self.present(viewController, animated: true, completion: { () -> Void in
            })
        }
    }
    
    @objc func updateLocationOnBackground(_ notification: Notification) {
        print("updateLocationOnBackground")
        self.locationManager.startUpdatingLocation()
    }
    
    @objc func stopLocationUpdate(_ notification: Notification) {
        self.locationManager.stopUpdatingLocation()
    }
}

extension HomeViewController : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if tableView == self.tblMenu
        {
            return menuArr.count
        }
        else if tableView == self.tblLanguage
        {
            return languageArr.count
        }
        else
        {
            if orderArr.count != 0{
                return orderArr.count
            }else{
                return 1
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if tableView == self.tblMenu
        {
            let cell:MenuTableViewCell = self.tblMenu.dequeueReusableCell(withIdentifier: "menuCell") as! MenuTableViewCell
            
            cell.lblTitle.text = self.menuArr[indexPath.row]
            cell.imgIcon.image = UIImage (named: self.iconsArr[indexPath.row])
            
            return cell
        }
        else if tableView == self.tblLanguage
        {
            let cell:OrderTableViewCell = self.tblLanguage.dequeueReusableCell(withIdentifier: "languageCell") as! OrderTableViewCell
            cell.lblLanguage.text = "\((self.languageArr.object(at: indexPath.row) as AnyObject).value(forKey: "name")!)"
            let id = "\((self.languageArr.object(at: indexPath.row) as AnyObject).value(forKey: "language_id")!)"
            if selectedLanguage == id{
                cell.imgLanguage.image = UIImage (named: "ic_radio_check")
            }else{
                cell.imgLanguage.image = UIImage (named: "ic_radio_uncheck")
            }
            return cell
        }else
        {
            if orderArr.count != 0{
                if tblDelivery.isHidden == true{
                    tblDelivery.isHidden = false
                }
                print(orderArr.object(at: indexPath.row) as AnyObject)
                let cell:OrderTableViewCell = self.tblDelivery.dequeueReusableCell(withIdentifier: "orderCell") as! OrderTableViewCell
                cell.baseView.dropShadow(cornerRadius: 8, opacity: 0.2, radius: 8)
                let normalText = NSLocalizedString("Order Status", comment: "")
                let attributedStringColor = [NSAttributedString.Key.foregroundColor : positiveBtnColor];
                let attributedString = NSAttributedString(string: "\((orderArr.object(at: indexPath.row) as AnyObject).value(forKey: "order_status")!)", attributes: attributedStringColor)
                let normalString = NSMutableAttributedString(string:"\(normalText) : ")
                normalString.append(attributedString)
                cell.lblStatus.attributedText = normalString
                cell.lblOrderId.textAlignment = isRTLenabled == true ? .right : .left
                cell.lblTotal.textAlignment = isRTLenabled == true ? .left : .right
                cell.lblOrderId.text = "\(NSLocalizedString("Order ID : ", comment: ""))\((orderArr.object(at: indexPath.row) as AnyObject).value(forKey: "order_id")!)"
                cell.lblTotal.text = "\(NSLocalizedString("Order Total : ", comment: ""))\((orderArr.object(at: indexPath.row) as AnyObject).value(forKey: "total")!)"
                cell.lblRestroName.text = "\(NSLocalizedString("Seller Name : ", comment: ""))\((orderArr.object(at: indexPath.row) as AnyObject).value(forKey: "vendor_name")!)"
                if (orderArr.object(at: indexPath.row) as AnyObject).value(forKey: "task_date_added") != nil{
                    cell.lblDate.text = "\(NSLocalizedString("Delivery Date : ", comment: ""))\((orderArr.object(at: indexPath.row) as AnyObject).value(forKey: "task_date_added")!)"
                }
                if (orderArr.object(at: indexPath.row) as AnyObject).value(forKey: "marker_p_address") != nil{
                    cell.lblPickupAddress.text = "\((orderArr.object(at: indexPath.row) as AnyObject).value(forKey: "marker_p_address")!)"
                }
                if (orderArr.object(at: indexPath.row) as AnyObject).value(forKey: "marker_d_address") != nil{
                    cell.lblDeliveryAddress.text = "\((orderArr.object(at: indexPath.row) as AnyObject).value(forKey: "marker_d_address")!)"
                }
                if let contactlessDelivery = (orderArr.object(at: indexPath.row) as AnyObject).value(forKey: "contactless_delivery"), contactlessDelivery as! String == "1"{
                    cell.lblContactless.isHidden = false
                    let stringAttribute = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16), NSAttributedString.Key.foregroundColor : UIColor(red: 67/255, green: 164/255, blue: 34/255, alpha: 1.0)]
                    let attributedString1 = NSMutableAttributedString(string: (NSLocalizedString("Delivery Type : ", comment: "")))
                    let attributedString2 = NSMutableAttributedString(string:"Contactless Delivery", attributes:stringAttribute)
                    attributedString1.append(attributedString2)
                    cell.lblContactless.attributedText = attributedString1
                }else{
                    cell.lblContactless.isHidden = true
                }
                return cell
                
            }else{
                let cell:OrderTableViewCell = self.tblDelivery.dequeueReusableCell(withIdentifier: "orderCell") as! OrderTableViewCell
                tblDelivery.isHidden = true
                viewEmpty.isHidden = false
                imgEmpty.image = imgEmpty.image!.withRenderingMode(.alwaysTemplate)
                imgEmpty.tintColor = themeColor
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if tableView == self.tblMenu
        {
            return 50
        }
        else if tableView == self.tblLanguage
            {
                return 44
            }
            else
        {
            return 321
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if tableView == self.tblMenu
        {
            if indexPath.row != menuArr.count - 1
            {
                if menuArr[indexPath.row].contains(NSLocalizedString("Earning History", comment: ""))
                {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier: "EarningHistoryVC")
                        as! EarningHistoryVC
                    self.navigationController?.pushViewController(viewController, animated: true)
                }
                else if menuArr[indexPath.row] == NSLocalizedString("Delivery History", comment: "")
                {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier: "HistoryViewController")
                        as! HistoryViewController
                    self.navigationController?.pushViewController(viewController, animated: true)
                }
                else if menuArr[indexPath.row].contains(NSLocalizedString("Change Language", comment: ""))
                {
                    self.closeMenu()
                    self.viewLanguage.frame = CGRect(x: ((self.view.bounds.size.width/2) - self.viewLanguage.frame.size.width/2), y: ((self.view.bounds.size.height/2) - self.viewLanguage.frame.size.height/2), width: self.viewLanguage.frame.size.width, height: self.viewLanguage.frame.size.height)
                    self.viewLanguage.translatesAutoresizingMaskIntoConstraints = true
                    self.viewBlur.isHidden = false
                    self.view.addSubview(self.viewLanguage)
                    selectedLanguage = languageID
                    tblLanguage.reloadData()
                }
                else if menuArr[indexPath.row].contains(NSLocalizedString("Profile", comment: ""))
                {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier: "SettingsViewController")
                        as! SettingsViewController
                    self.navigationController?.pushViewController(viewController, animated: true)
                }
            }
            else
            {
                self.view.endEditing(true)
                SharedManager.showHUD(viewController: self)
                userIDStr = UserDefaults.standard.string(forKey: "USER_ID")!
                let params = [
                    "shift_status": "0"
                ] as [String: Any]
                let urlStr = "\(ConfigUrl.baseUrl)shift-change"
                let setFinalURl = urlStr.addingPercentEncoding (withAllowedCharacters: .urlQueryAllowed)!
                var request = URLRequest(url: URL(string: setFinalURl)!)
                request.httpMethod = HTTPMethod.post.rawValue
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue(userIDStr, forHTTPHeaderField: "Driver-Authorization")
                let setTemp: [String : Any] = params
                if let jsonData: Data = try? JSONSerialization.data(withJSONObject: setTemp, options: .prettyPrinted) {
                    let jsonString = String(data: jsonData , encoding: .utf8)
                    print(jsonString as Any)
                    request.httpBody = jsonData
                }
                if Connectivity.isConnectedToInternet()
                {
                    Alamofire.request(request).responseJSON { (responseObject) -> Void in
                        if responseObject.result.isSuccess
                        {
                            let result = responseObject.result.value! as AnyObject
                            if let code = result.value(forKeyPath: "success.status")
                            {
                                if code as! String == "200"
                                {
                                    let driverID = "\(UserDefaults.standard.string(forKey: "DRIVER_ID")!)"
                                    self.ref = Database.database().reference()
                                    self.ref.child("drivers").child(driverID).updateChildValues(["shift": "0"]) {
                                        (error:Error?, ref:DatabaseReference) in
                                        if let error = error {
                                            print(error)
                                        }else{
                                            self.locationManager.startUpdatingLocation()
                                        }
                                        UserDefaults.standard.removeObject(forKey: kUserDetails)
                                        UserDefaults.standard.removeObject(forKey: "USER_ID")
                                        UserDefaults.standard.removeObject(forKey: "DRIVER_ID")
                                        UserDefaults.standard.removeObject(forKey: "SHIFT_STATUS")
                                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                        let viewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
                                            as! LoginViewController
                                        self.navigationController?.pushViewController(viewController, animated: true)
                                    }
                                }
                                SharedManager.dismissHUD(viewController: self)
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
        }else if tableView == self.tblLanguage
        {
            selectedLanguage = (languageArr.object(at: indexPath.row) as AnyObject).value(forKey: "language_id") as! String
            tblLanguage.reloadData()
        }
        else
        {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "DeliveryDetailViewController")
                as! DeliveryDetailViewController
            viewController.orderId = "\((orderArr.object(at: indexPath.row) as AnyObject).value(forKey: "order_id")!)"
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
}

