//
//  DeliveryDetailViewController.swift
//  FoodDelivery
//
//  Created by Apple on 31/05/18.
//  Copyright © 2018 Adyas Iinfotech. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import SDWebImage
//import MapKit
import Alamofire
import Reachability
import Firebase

enum TravelModes: Int
{
    case driving
    case walking
    case bicycling
}

class DeliveryDetailViewController: ParentViewController, GMSMapViewDelegate, CLLocationManagerDelegate, MTSlideToOpenDelegate
{
    lazy var customizeSlideToOpen: MTSlideToOpenView = {
        let slide = MTSlideToOpenView(frame: CGRect(x: 50, y: 4, width: self.view.frame.size.width - 100, height: self.vwBottom.frame.size.height - 10))
        slide.sliderViewTopDistance = 0
        slide.thumbnailViewTopDistance = 4;
        slide.thumbnailViewStartingDistance = 4;
        slide.sliderCornerRadius = 28
        slide.thumnailImageView.backgroundColor = .darkGray
        slide.draggedView.backgroundColor = .clear
        slide.textLabel.textColor = .white
        slide.delegate = self
        slide.thumnailImageView.image = #imageLiteral(resourceName: "ic_arrow")
        slide.defaultSliderBackgroundColor = .gray
        return slide
    }()
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var vwContainer: UIView!
    @IBOutlet var tblProducts: UITableView!
    
    @IBOutlet weak var tblMoreOptions: UITableView!
    @IBOutlet weak var tblCancelReasons: UITableView!
    @IBOutlet weak var vwProductDetail: UIView!
    @IBOutlet weak var vwDeliveryDetail: UIView!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var lblOrderID: UILabel!
    
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblPaymentTotal: UILabel!
    @IBOutlet weak var lblPaymentTotalTitle: UILabel!
    @IBOutlet weak var lblDeliveryAddress: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblCustomerMobile: UILabel!
    @IBOutlet weak var lblCustomerName: UILabel!
    @IBOutlet weak var lblPickupAddress: UILabel!
    @IBOutlet weak var lblStoreName: UILabel!
    @IBOutlet weak var lblStoreMobile: UILabel!
    @IBOutlet weak var lblPaymentStatusTitle: UILabel!
    @IBOutlet weak var lblPaymentStatus: UILabel!
    @IBOutlet weak var vwOptions: UIView!
    @IBOutlet weak var vwCancelReasons: UIView!
    @IBOutlet weak var vwBottom: UIView!
    @IBOutlet weak var vwCancelOrder: UIView!
    @IBOutlet weak var imgFullSizeView: UIImageView!
    @IBOutlet weak var vwFullSize: UIView!
    @IBOutlet  var imgBack: UIImageView!
    @IBOutlet weak var lblContactless: UILabel!
    @IBOutlet weak var viewTrack: UIView!
    
    var productsArr = NSMutableArray()
    var totalsArr = NSMutableArray()
    var orderStatus = ""
    var deliveryDict = NSDictionary()
    var selectedIndex = ""
    var orderId : String = ""
    var isHistory = false
    var valSeconds = 4
    var moreOptionsArr = [NSLocalizedString("Cancel Order", comment: ""), NSLocalizedString("Close", comment: "")]
    var cancelReasonArr = NSMutableArray()
    
    // Maps
    let locationManager = CLLocationManager()
    var didFindMyLocation = false
    var mapTasks = MapTasks()
    var locationMarker: GMSMarker!
    var originMarker: GMSMarker!
    var destinationMarker: GMSMarker!
    var routePolyline: GMSPolyline!
    var waypointsArray: Array<String> = []
    
    var fetchedFormattedAddress: String!
    var fetchedAddressLongitude: Double!
    var fetchedAddressLatitude: Double!
    var polylineArray = NSMutableArray()

    var tempLat = Double()
    var tempLong = Double()
    var ref: DatabaseReference!
        
    var window: UIWindow?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.mapView.frame.size.height = (UIScreen.main.bounds.height - 150)/2
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        let driverID = "\(UserDefaults.standard.string(forKey: "DRIVER_ID")!)"
        self.ref = Database.database().reference()
        self.ref.child("drivers").child(driverID).observeSingleEvent(of: .value, with: { (snapshot) in
            let result = snapshot.value as? NSDictionary
            if result != nil{
                if result!.value(forKey: "shift") != nil{
                    if "\(String(describing: result!.value(forKey: "shift")!))" == "1"{
                        self.locationManager.startUpdatingLocation()
                        UserDefaults.standard.set("1", forKey: "SHIFT_STATUS")
                    }else{
                        self.locationManager.stopUpdatingLocation()
                        UserDefaults.standard.set("0", forKey: "SHIFT_STATUS")
                    }
                }
            }
        })
    }
    
    // MARK: Button Actions
    @IBAction func clickMore(_ sender: Any)
    {
        if self.vwOptions.isHidden == false
        {
            self.vwOptions.isHidden = true
            self.tblMoreOptions.isHidden = true
            self.vwCancelReasons.isHidden = true
        }
        else
        {
            self.vwOptions.isHidden = false
            self.tblMoreOptions.isHidden = false
            self.vwCancelReasons.isHidden = true
        }
    }
    
    @IBAction func clickCall(_ sender: UIButton)
    {
        var mobNumber = ""
        
        if sender.tag == 1
        {
            mobNumber = "\(deliveryDict.value(forKey: "restaurant_mobile")!)"
        }
        else
        {
            mobNumber = "\(deliveryDict.value(forKey: "customer_mobile")!)"
        }
        
        if let url = URL(string: "tel://\(mobNumber)"), UIApplication.shared.canOpenURL(url)
        {
            if #available(iOS 10, *)
            {
                UIApplication.shared.open(url)
            }
            else
            {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    @IBAction func clickWhatsapp(_ sender: UIButton)
    {
        var whatsappNumber = ""
        
        if sender.tag == 1
        {
            whatsappNumber = "\(deliveryDict.value(forKey: "restaurant_mobile")!)"
        }
        else
        {
            whatsappNumber = "\(deliveryDict.value(forKey: "customer_mobile")!)"
        }
        let urlWhats = "whatsapp://send?phone=\(whatsappNumber)"
        if let urlString = urlWhats.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        {
            if let whatsappURL = URL(string: urlString) {
                if UIApplication.shared.canOpenURL(whatsappURL)
                {
                    UIApplication.shared.open(whatsappURL, options: [:], completionHandler: nil)
                }
                else
                {
                    let alt: UIAlertController = UIAlertController(title: NSLocalizedString("Sorry", comment: ""), message: "Install WhatsApp to Continue", preferredStyle: UIAlertController.Style.alert)
                    alt.addAction(UIAlertAction(title: "Install", style: UIAlertAction.Style.default, handler: { (UIAlertAction) -> Void in
                        let appStoreUrl = URL(string: "itms://itunes.apple.com/in/app/whatsapp-messenger/id310633997?mt=8")
                        UIApplication.shared.open(appStoreUrl!, options: [:], completionHandler: nil)
                        //UIApplication.shared.openURL(NSURL(string: "itms://itunes.apple.com/in/app/whatsapp-messenger/id310633997?mt=8")! as URL)
                        
                    }))
                    alt.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
                    self.present(alt, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func clickBack(sender: AnyObject!)
    {
        self.dismiss(animated: true, completion: nil)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController")
            as! HomeViewController
        self.present(viewController, animated: false, completion: { () -> Void in
        })
    }
    
    @IBAction func clickClose(sender: AnyObject!)
    {
        self.vwOptions.isHidden = true
        self.vwCancelReasons.isHidden = true
    }
    
    // MARK: MTSlideToOpenDelegate
    func mtSlideToOpenDelegateDidFinish(_ sender: MTSlideToOpenView) {
        sender.resetStateWithAnimation(false)
        if orderStatus == "3" || orderStatus == "5" || orderStatus == "6"
        {
            updateStatus(status: "8")
        }else if orderStatus == "8"
        {
            updateStatus(status: "9")
        }
        
    }
    
    @IBAction func clickChangeMapType(sender: AnyObject)
    {
        if self.mapView.mapType == .terrain
        {
            self.mapView.mapType = .satellite
        }
        else
        {
            self.mapView.mapType = .terrain
        }
    }
    
    @IBAction func clickChangeMapView(sender: AnyObject)
    {
        if self.imgFullSizeView.image == UIImage(named:"ic_fullsize")
        {
            self.imgFullSizeView.image = UIImage(named:"ic_collapse")
            self.mapView.frame.size.height = UIScreen.main.bounds.height - (UIScreen.main.bounds.height / 3)
            self.mapView.translatesAutoresizingMaskIntoConstraints = true
            self.perform(#selector(setFrames), with: nil, afterDelay: 0.0)
        }
        else
        {
            self.imgFullSizeView.image = UIImage(named:"ic_fullsize")
            self.mapView.frame.size.height = (UIScreen.main.bounds.height - 150)/2
            self.mapView.translatesAutoresizingMaskIntoConstraints = true
            self.perform(#selector(setFrames), with: nil, afterDelay: 0.0)
        }
    }
    
    @IBAction func clickCurrentLocation(sender: AnyObject)
    {
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func clickTrack(_ sender: Any)
    {
        let order_status_id = "\(self.deliveryDict.value(forKey: "order_status_id")!)"
        if order_status_id == "3" || order_status_id == "5" || order_status_id == "6"
        {
            if let pickupLatitude = self.deliveryDict.value(forKey: "pickup_latitude"), pickupLatitude as! String != "", let pickupLongitude =  self.deliveryDict.value(forKey: "pickup_longitude"), pickupLongitude as! String != ""
            {
                if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
                    
                    if let url = URL(string: "comgooglemaps-x-callback://?saddr=&daddr=\(pickupLatitude),\(pickupLongitude)&directionsmode=driving&x-success=sourceapp://?resume=true&x-source=SourceApp") {
                        UIApplication.shared.open(url, options: [:])
                    }}

                else {
                    if let urlDestination = URL.init(string: "https://www.google.co.in/maps/dir/?saddr=&daddr=\(pickupLatitude),\(pickupLongitude)&directionsmode=driving") {
                        UIApplication.shared.open(urlDestination)
                    }
                }
            }
        }
        else if order_status_id == "8"
        {
            if let deliveryLat = self.deliveryDict.value(forKey: "delivery_latitude"), deliveryLat as! String != "", let deliveryLong =  self.deliveryDict.value(forKey: "delivery_longitude"), deliveryLong as! String != ""
            {
                if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
                    
                    if let url = URL(string: "comgooglemaps-x-callback://?saddr=&daddr=\(deliveryLat),\(deliveryLong)&directionsmode=driving&x-success=sourceapp://?resume=true&x-source=SourceApp") {
                        UIApplication.shared.open(url, options: [:])
                    }}

                else {
                    if let urlDestination = URL.init(string: "https://www.google.co.in/maps/dir/?saddr=&daddr=\(deliveryLat),\(deliveryLong)&directionsmode=driving") {
                        UIApplication.shared.open(urlDestination)
                    }
                }
            }
        }
    }
    
    @IBAction func clickCancelOrder(_ sender: Any)
    {
        
        if selectedIndex != ""
        {
            
            self.cancelOrder(statusID: selectedIndex)
        }
        else
        {
            SharedManager.showAlertWithMessage(title: NSLocalizedString("Sorry", comment: ""), alertMessage: NSLocalizedString("Please select a reason to cancel", comment: ""), viewController: self)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //Dispose of any resources that can be recreated.
    }
    
    
    //MARK: Functions
    func setupUI(){
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 5
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.vwBottom.addSubview(customizeSlideToOpen)
        self.imgFullSizeView.image = UIImage(named:"ic_fullsize")
        getDeliverydetail()
    }
    
    @objc func setFrames()
    {
        self.tblProducts.frame.size.height = self.tblProducts.contentSize.height
        self.tblProducts.translatesAutoresizingMaskIntoConstraints = true
        self.vwProductDetail.frame.size.height = self.tblProducts.contentSize.height + 122
        self.vwDeliveryDetail.frame.origin.y = self.mapView.frame.size.height
        self.vwDeliveryDetail.translatesAutoresizingMaskIntoConstraints = true
        self.vwProductDetail.frame.origin.y = self.vwDeliveryDetail.frame.origin.y + self.vwDeliveryDetail.frame.size.height
        self.vwProductDetail.translatesAutoresizingMaskIntoConstraints = true
        var height = self.mapView.frame.size.height + self.vwDeliveryDetail.frame.size.height + self.vwProductDetail.frame.size.height + 10
        self.vwContainer.frame.size.height = height
        self.vwContainer.frame.origin.y = 0
        self.vwContainer.translatesAutoresizingMaskIntoConstraints = true
        if !isHistory{
            height = height + vwBottom.frame.size.height
        }
        self.mainScrollView.addSubview(vwContainer)
        self.mainScrollView.contentSize = CGSize(width: self.view.bounds.size.width, height: height)
        mainScrollView.setContentOffset(.zero, animated: true)
        mainScrollView.scrollsToTop = true
        self.settingLocation()
    }
    
    func settingLocation()  {
        var fromLatLong = ""
        var toLatLong = ""
        if let pickupLat = deliveryDict.value(forKey: "pickup_latitude"), "\(pickupLat)" != ""{
            if let pickupLong = deliveryDict.value(forKey: "pickup_longitude"), "\(pickupLong)" != ""{
                fromLatLong = "\(pickupLat),\(pickupLong)"
            }
        }
        if let deliveryLat = deliveryDict.value(forKey: "delivery_latitude"), "\(deliveryLat)" != ""{
            if let deliveryLong = deliveryDict.value(forKey: "delivery_longitude"), "\(deliveryLong)" != ""{
                toLatLong = "\(deliveryLat),\(deliveryLong)"
            }
        }
        self.createRoutes(fromLatLong, toAdd: toLatLong)
        SharedManager.dismissHUD(viewController: self)
    }
    
    func createRoutes(_ fromAdd: String, toAdd: String) {
        if self.routePolyline != nil
        {
            self.clearRoute()
            self.waypointsArray.removeAll(keepingCapacity: false)
        }
        self.mapTasks.getDirections(fromAdd , destination: toAdd, waypoints: nil, travelMode: TravelModes.driving, completionHandler: { (status, success) -> Void in
            if success
            {
                self.configureMapAndMarkersForRoute()
            }
        })
    }
    
    func configureMapAndMarkersForRoute() {
        originMarker = GMSMarker(position: self.mapTasks.originCoordinate)
        originMarker.map = self.mapView
        let image = UIImage(named: "ic_location_green")
        originMarker.icon = image
        originMarker.title = lblStoreName.text!
        
        destinationMarker = GMSMarker(position: self.mapTasks.destinationCoordinate)
        destinationMarker.map = self.mapView
        let image2 = UIImage(named: "ic_location_red")
        destinationMarker.icon = image2
        destinationMarker.title = lblCustomerName.text!

        if originMarker != nil, destinationMarker != nil, locationMarker != nil {
            var markers = [GMSMarker]()
            markers = [originMarker, destinationMarker, locationMarker]
            var bounds = GMSCoordinateBounds()
            for marker in markers {
                bounds = bounds.includingCoordinate(marker.position)
            }
        }
        self.drawRoute()
    }
    
    func drawRoute()
    {
        let route = mapTasks.overviewPolyline["points"] as! String
        let path: GMSPath = GMSPath(fromEncodedPath: route)!
        routePolyline = GMSPolyline(path: path)
        routePolyline.map = mapView
        routePolyline.strokeWidth = 2.0
        routePolyline.strokeColor = UIColor.red
    }

    func updateLocationoordinates(coordinates:CLLocationCoordinate2D) {
        if originMarker != nil && destinationMarker != nil {
            var markers = [GMSMarker]()
            markers = [originMarker, destinationMarker, locationMarker]
            var bounds = GMSCoordinateBounds()
            for marker in markers {
                bounds = bounds.includingCoordinate(marker.position)
            }
        }
    }
    
    func clearRoute()
    {
        originMarker.map = nil
        destinationMarker.map = nil
        routePolyline.map = nil
        
        originMarker = nil
        destinationMarker = nil
        routePolyline = nil
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        if routePolyline != nil  {
            let positionString = String(format: "%f", coordinate.latitude) + "," + String(format: "%f", coordinate.longitude)
            waypointsArray.append(positionString)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.last != nil {
            let locValue: CLLocationCoordinate2D = manager.location!.coordinate
            driverLatitude = locValue.latitude
            driverLongitude = locValue.longitude
            self.updateLocationoordinates(coordinates: locValue)
            if self.locationMarker != nil {
                self.locationMarker.map = nil
            }
            self.locationMarker = GMSMarker()
            self.locationMarker.position = locValue
            let markerImg = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            markerImg.image = UIImage(named: "myloc")
            markerImg.contentMode = .scaleAspectFit
            self.locationMarker.iconView = markerImg
            self.locationMarker.map = self.mapView
            
            if self.valSeconds == 4{
                let camera = GMSCameraPosition.camera(withLatitude: driverLatitude, longitude: driverLongitude, zoom: 17)
                self.mapView?.animate(to: camera)
                self.valSeconds = 0
            }
            self.valSeconds = self.valSeconds + 1
            
        }
    }
    
    @objc func clickMoreDetails(sender:UIBarButtonItem)
    {
        if self.vwOptions.isHidden == false
        {
            self.vwOptions.isHidden = true
            self.tblMoreOptions.isHidden = true
            self.vwCancelReasons.isHidden = true
        }
        else
        {
            self.vwOptions.isHidden = false
            self.tblMoreOptions.isHidden = false
            self.vwCancelReasons.isHidden = true
        }
    }
    
    // MARK: API Methods
    func getDeliverydetail() {
        SharedManager.showHUD(viewController: self)
        let params = [
            "order_id": orderId
        ] as [String: Any]
        let urlStr = "\(ConfigUrl.baseUrl)order-info"
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
                        print(result)
                        if let code = result.value(forKeyPath: "success.status")
                        {
                            if code as! String == "200"
                            {
                                self.deliveryDict = (result.value(forKey: "order") as AnyObject) as! NSDictionary
                                self.lblOrderID.text = "\(NSLocalizedString("Order ID : ", comment: ""))\(self.deliveryDict.value(forKey: "order_id")!)"
                                self.lblPaymentTotal.text = "\(self.deliveryDict.value(forKey: "total")!)"
                                self.lblPaymentStatus.text = "\(self.deliveryDict.value(forKey: "payment_method")!)"
                                self.lblDate.text = "\(self.deliveryDict.value(forKey: "date_delivery")!)"
                                self.lblStoreName.text = "\(self.deliveryDict.value(forKey: "vendor")!)"
                                self.lblStoreMobile.text = "\(self.deliveryDict.value(forKey: "vendor_mobile")!)"
                                self.lblCustomerName.text = "\(self.deliveryDict.value(forKey: "customer_first_name")!) \(self.deliveryDict.value(forKey: "customer_last_name")!)"
                                self.lblCustomerMobile.text = "\(self.deliveryDict.value(forKey: "customer_mobile")!)"
                                self.lblStatus.text = "\(self.deliveryDict.value(forKey: "delivery_status")!)"
                                self.lblStatus.textAlignment = isRTLenabled == true ? .left : .right
                                self.orderStatus = "\(self.deliveryDict.value(forKey: "order_status_id")!)"
                                self.orderId = "\(self.deliveryDict.value(forKey: "order_id")!)"
                                self.lblPickupAddress.text = "\(self.deliveryDict.value(forKey: "pickup_address")!)"
                                self.lblDeliveryAddress.text = "\(self.deliveryDict.value(forKey: "delivery_address")!)"
                                self.lblPaymentTotal.textAlignment = isRTLenabled == true ? .left : .right
                                self.lblPaymentStatus.textAlignment = isRTLenabled == true ? .left : .right
                                self.lblPaymentTotalTitle.textAlignment = isRTLenabled == true ? .left : .right
                                self.lblPaymentStatusTitle.textAlignment = isRTLenabled == true ? .left : .right
                                let order_status_id = "\(self.deliveryDict.value(forKey: "order_status_id")!)"
                                let contactless_delivery = "\(self.deliveryDict.value(forKey: "contactless_delivery")!)"
                                if contactless_delivery == "1" {
                                    self.lblContactless.isHidden = false
                                }else {
                                    self.lblContactless.isHidden = true
                                }
                                self.productsArr = (self.deliveryDict.value(forKey: "product") as! NSArray).mutableCopy() as! NSMutableArray
                                //self.totalsArr = (self.deliveryDict.value(forKey: "totals") as! NSArray).mutableCopy() as! NSMutableArray
                                
                                if self.isHistory{
                                    self.vwCancelOrder.isHidden = true
                                    self.vwBottom.isHidden = true
                                    self.viewTrack.isHidden = true
                                }else{
                                    if order_status_id == "3" || order_status_id == "5" || order_status_id == "6"
                                    {
                                        if self.isHistory == false{
                                            var image = UIImage(named: "More_options")
                                            image = image?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
                                            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.clickMoreDetails(sender:)))
                                        }
                                        self.customizeSlideToOpen.defaultLabelText = "Slide to Pickup"
                                        self.vwBottom.isHidden = false
                                        if let status = UserDefaults.standard.string(forKey: "SHIFT_STATUS"), status != "", status == "1" {
                                            self.customizeSlideToOpen.isHidden = false
                                        } else {
                                            self.customizeSlideToOpen.isHidden = true
                                        }
                                        self.viewTrack.isHidden = false
                                    }
                                    else if order_status_id == "8"
                                    {
                                        self.navigationItem.rightBarButtonItem = nil
                                        self.customizeSlideToOpen.defaultLabelText = "Slide to Deliver"
                                        self.vwBottom.isHidden = false
                                        if let status = UserDefaults.standard.string(forKey: "SHIFT_STATUS"), status != "", status == "1" {
                                            self.customizeSlideToOpen.isHidden = false
                                        } else {
                                            self.customizeSlideToOpen.isHidden = true
                                        }
                                        self.viewTrack.isHidden = false
                                    }else{
                                        self.navigationItem.rightBarButtonItem = nil
                                        self.vwBottom.isHidden = true
                                        self.viewTrack.isHidden = true
                                    }
                                }
                                self.tblProducts.reloadData()
                                self.perform(#selector(self.setFrames), with: nil, afterDelay: 2.0)
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
    
    func updateStatus(status : String)
    {
        SharedManager.showHUD(viewController: self)
        let params = [
            "order_id": orderId,
            "status": status
        ] as [String: Any]
        let urlStr = "\(ConfigUrl.baseUrl)order-status/update"
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
                            UserDefaults.standard.set(status, forKey: "DELIVERY_STATUS")
                            let alert = UIAlertController(title: "Wow!", message: NSLocalizedString("Order status updated successfully!", comment: ""), preferredStyle: UIAlertController.Style.alert)
                            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: {(alert :UIAlertAction) in
                                
                                self.ref = Database.database().reference()
                                
                                let orderId = "\(self.deliveryDict.value(forKey: "order_id")!)"
                                
                                if status == "8"
                                {
                                    self.navigationItem.rightBarButtonItem = nil
                                    self.ref.child("task_status").child(orderId).setValue(["task_status_id": status]) {
                                        (error:Error?, ref:DatabaseReference) in
                                        if let error = error {
                                            print(error)
                                        } else {
                                            self.getDeliverydetail()
                                        }
                                    }
                                }else if status == "9"
                                {
                                    self.ref.child("task_status").child(orderId).updateChildValues(["task_status_id": status]) {
                                        (error:Error?, ref:DatabaseReference) in
                                        if let error = error {
                                            print(error)
                                        } else {
                                            self.ref.child("tasks").child(orderId).updateChildValues(["status": "0"]) {
                                                (error:Error?, ref:DatabaseReference) in
                                                if let error = error {
                                                    print(error)
                                                } else {
                                                    self.window = UIWindow(frame: UIScreen.main.bounds)
                                                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                                    let viewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController")
                                                    let navigationController = UINavigationController.init(rootViewController: viewController)
                                                    self.window?.rootViewController = navigationController
                                                    self.window?.makeKeyAndVisible()
                                                }
                                            }
                                        }
                                    }
                                }
                            }))
                            self.present(alert, animated: true, completion: nil)
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
                    //  self.switchObj.isUserInteractionEnabled = true
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
    
    func cancelOrder(statusID : String)
    {
        SharedManager.showHUD(viewController: self)
        let params = [
            "order_id": orderId,
            "reason": statusID
        ] as [String: Any]
        let urlStr = "\(ConfigUrl.baseUrl)order-cancel"
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
                    print(result)
                    if let code = result.value(forKeyPath: "success.status")
                    {
                        if code as! String == "200"
                        {
                            self.vwOptions.isHidden = true
                            self.vwCancelReasons.isHidden = true
                            self.navigationController?.popViewController(animated: true)
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
    
    func getCancelReasons()
    {
        let params = [String: Any]()
        let urlStr = "\(ConfigUrl.baseUrl)cancel-reason"
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
                            print(responseObject.result.value!)
                            let result = responseObject.result.value! as AnyObject
                            self.cancelReasonArr = (result.value(forKey: "status") as! NSArray).mutableCopy() as! NSMutableArray
                            self.tblCancelReasons.reloadData()
                            self.tblMoreOptions.isHidden = true
                            self.vwCancelReasons.isHidden = false
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
}

extension DeliveryDetailViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        if tableView == tblProducts
        {
            return 2
        }
        else
        {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if tableView == tblProducts
        {
            if section == 0
            {
                print(productsArr)
                return productsArr.count
            }
            else
            {
                print(totalsArr)
                return totalsArr.count
            }
        }
        else if tableView == tblMoreOptions
        {
            return moreOptionsArr.count
        }
        else
        {
            return cancelReasonArr.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if tableView == tblProducts
        {
            if indexPath.section == 0
            {
                let cell:ProductsTableViewCell = self.tblProducts.dequeueReusableCell(withIdentifier: "productCell") as! ProductsTableViewCell
                
                cell.lblProductName.text = "\((productsArr.object(at: indexPath.row) as AnyObject).value(forKey: "name")!)"
                cell.lblQuantity.text = "\((productsArr.object(at: indexPath.row) as AnyObject).value(forKey: "quantity")!)"
                cell.lblTotal.text = "\((productsArr.object(at: indexPath.row) as AnyObject).value(forKey: "total")!)"
                
                let imageUrl =  "\((productsArr.object(at: indexPath.row) as AnyObject).value(forKey: "logo")!)"
                
                if imageUrl != ""
                {
                    let trimmedUrl = imageUrl.trimmingCharacters(in: CharacterSet(charactersIn: "")).replacingOccurrences(of: " ", with: "%20") as String
                    cell.imgProduct.sd_setImage(with: URL(string: trimmedUrl))
                }
                else
                {
                    cell.imgProduct.image = UIImage (named: "no_image")
                }
                
                return cell
            }
            else
            {
                let cell:ProductsTableViewCell = self.tblProducts.dequeueReusableCell(withIdentifier: "TotalCell") as! ProductsTableViewCell
                
                cell.lblTotalTitle.text = "\((totalsArr.object(at: indexPath.row) as AnyObject).value(forKey: "title")!)"
                cell.lblTotalValue.text = "\((totalsArr.object(at: indexPath.row) as AnyObject).value(forKey: "value")!)"
                cell.lblTotalTitle.textAlignment = isRTLenabled == true ? .left : .right
                cell.lblTotalValue.textAlignment = isRTLenabled == true ? .left : .right
                return cell
            }
        }
        else if tableView == tblMoreOptions
        {
            let cell:OptionsTableViewCell = self.tblMoreOptions.dequeueReusableCell(withIdentifier: "optionCell") as! OptionsTableViewCell
            
            cell.lblOption.text = moreOptionsArr[indexPath.row]
            
            return cell
        }
        else
        {
            let cell:OptionsTableViewCell = self.tblCancelReasons.dequeueReusableCell(withIdentifier: "cancelReasonCell") as! OptionsTableViewCell
            
            cell.lblReason.text = "\((cancelReasonArr.object(at: indexPath.row) as AnyObject).value(forKey: "name")!)"
            
            if selectedIndex == "\((cancelReasonArr.object(at: indexPath.row) as AnyObject).value(forKey: "status_id")!)"
            {
                cell.imgCheckbox.image = UIImage (named: "ic_check_box")
            }
            else
            {
                cell.imgCheckbox.image = UIImage (named: "ic_uncheck_box")
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if tableView == tblProducts
        {
            if indexPath.section == 0
            {
                return 81
            }
            else
            {
                return 30
            }
        }
        else if tableView == tblMoreOptions
        {
            return 43
        }
        else
        {
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if tableView == tblMoreOptions
        {
            if indexPath.row == 0
            {
                
                getCancelReasons()
            }
            else
            {
                self.vwOptions.isHidden = true
                self.tblMoreOptions.isHidden = true
            }
        }
        else if tableView == tblCancelReasons
        {
            selectedIndex = "\((cancelReasonArr.object(at: indexPath.row) as AnyObject).value(forKey: "status_id")!)"
            self.tblCancelReasons.reloadData()
            
          //  self.vwCancelReasons.frame.size.height = self.tblCancelReasons.contentSize.height + 45
        }
    }
}
