//
//  EaringHistoryVC.swift
//  FoodesoftDelivery
//
//  Created by Apple on 30/08/19.
//  Copyright © 2019 Adyas Iinfotech. All rights reserved.
//
//CalendarViewDataSource, CalendarViewDelegate
import UIKit
import Alamofire
import Reachability

class EarningHistoryVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet  var clBackGrounVw: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet  var txtFrom: UITextField!
    @IBOutlet  var txtTo: UITextField!
    @IBOutlet  var lblTotalOrder: UILabel!
    @IBOutlet  var lblTotalEarning: UILabel!
    @IBOutlet  var imgBack: UIImageView!
    @IBOutlet  var tblEarning: UITableView!
    
    var earnignArr = NSMutableArray()
    var datefor = ""

    var isScrolledOnce : Bool = false
    var page:Int = 1
    var pageCount = Double()
    var limit:String = "15"
    var minimumDate = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clBackGrounVw.isHidden = true
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Date()
        
        let cal = Calendar.current
        let toDate = cal.startOfDay(for: Date())
        let fromDate = Calendar.current.date(byAdding: .day, value: -6, to: toDate)
        let Formatter = DateFormatter()
        Formatter.dateFormat = "yyyy-MM-dd"
        self.txtFrom.text = Formatter.string(from: fromDate!)
        self.txtTo.text = Formatter.string(from: toDate)
        getEarnings()
    }
    
    @IBAction func datepickerfunction(_ sender: Any) {
        
    }
    
    @IBAction func clickBack(sender: AnyObject!)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clickDone(_ sender: Any) {
        if datefor ==  "From" {
            txtFrom.text = datePickerDate()
            txtTo.text = ""
        }else{
            txtTo.text = datePickerDate()
            self.getEarnings()
        }
        clBackGrounVw.isHidden = true
    }
    
    @IBAction func clickCancel(_ sender: Any) {
        clBackGrounVw.isHidden = true
    }
    
    //MARK: CALENDER
    @IBAction func fromDate(sender:UIButton) {
        //minimumDate = Date()
        //print(minimumDate)
        //datePicker.minimumDate = minimumDate
        clBackGrounVw.isHidden = false
        datefor = "From"
    }
    @IBAction func toDate(sender:UIButton) {
        if self.txtFrom.text != ""{
            clBackGrounVw.isHidden = false
            datefor = "To"
            //datePicker.minimumDate = minimumDate
        }else{
            SharedManager.showAlertWithMessage(title: NSLocalizedString("Sorry", comment: ""), alertMessage: NSLocalizedString("Please select from date", comment: ""), viewController: self)
        }
    }
    
    func datePickerDate() -> String
    {
        let dateSelected = datePicker.date
        let Formatter = DateFormatter()
        Formatter.dateFormat = "yyyy-MM-dd"
        //minimumDate = dateSelected
        print(Formatter.string(from: dateSelected))
        return Formatter.string(from: dateSelected)
    }
    //MARK: TableView Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if earnignArr.count != 0{
            return earnignArr.count
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:MenuTableViewCell = self.tblEarning.dequeueReusableCell(withIdentifier: "earningCell") as! MenuTableViewCell
        cell.lblDeliveryData.text = "\((self.earnignArr.object(at: indexPath.row) as AnyObject).value(forKey: "delivered_date")!)"
        cell.lblProductCount.text = "\((self.earnignArr.object(at: indexPath.row) as AnyObject).value(forKey: "total_items")!) \(NSLocalizedString("Items", comment: ""))"
        cell.lblCommissionAmt.text = "\((self.earnignArr.object(at: indexPath.row) as AnyObject).value(forKey: "delivery_fee")!)"
        cell.lblOrderId.text = "#\((self.earnignArr.object(at: indexPath.row) as AnyObject).value(forKey: "order_id")!)"
        cell.lblOrderId.frame.size.height = cell.lblRestaurantName.frame.size.height
        cell.lblOrderId.translatesAutoresizingMaskIntoConstraints = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if tableView == self.tblEarning
        {
            return 87
        }
        else
        {
            return 0
        }
    }
    
    //MARK: API
    func getEarnings(){
        SharedManager.showHUD(viewController: self)
        page = 1
        let params = [
            "page": page,
            "page_per_unit": limit,
            "start_date": self.txtFrom.text!,
            "end_date": self.txtTo.text!
        ] as [String: Any]
        print(params)
        let urlStr = "\(ConfigUrl.baseUrl)delivery-commission"
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
                                SharedManager.dismissHUD(viewController: self)
                                let result = responseObject.result.value! as AnyObject
                                self.earnignArr = (result.value(forKey: "commissions") as! NSArray).mutableCopy() as! NSMutableArray
                                self.lblTotalOrder.text = "\(result.value(forKeyPath: "totals.total")!)"
                                self.lblTotalEarning.text = "\(result.value(forKeyPath: "totals.total_amount")!)"
                                let total = "\(result.value(forKeyPath: "total")!)"
                                self.pageCount = Double(Int(total)!/Int(self.limit)!)
                                self.tblEarning.reloadData()
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
            page += 1
            SharedManager.showHUD(viewController: self)
            let params = [
                "page": page,
                "page_per_unit": limit,
                "filter_date_start": self.txtFrom.text!,
                "filter_date_end": self.txtTo.text!
            ] as [String: Any]
            let urlStr = "\(ConfigUrl.baseUrl)delivery-commission"
            let setFinalURl = urlStr.addingPercentEncoding (withAllowedCharacters: .urlQueryAllowed)!
            var request = URLRequest(url: URL(string: setFinalURl)!)
            request.httpMethod = HTTPMethod.get.rawValue
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(userIDStr, forHTTPHeaderField: "Driver-Authorization")
            if let jsonData: Data = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted) {
                let jsonString = String(data: jsonData , encoding: .utf8)
                request.httpBody = jsonData
            }
            if Connectivity.isConnectedToInternet()
            {
                Alamofire.request(request).responseJSON
                    { (responseObject) -> Void in
                        if responseObject.result.isSuccess
                        {
                            let result = responseObject.result.value! as AnyObject
                            if let code = result.value(forKeyPath: "success.status")
                            {
                                if code as! String == "200"
                                {
                                    let result = responseObject.result.value! as AnyObject
                                    let array = (result.value(forKey: "commissions") as! NSArray).mutableCopy() as! NSMutableArray
                                    self.earnignArr.addObjects(from: array as! [Any])
                                    print(self.earnignArr)
                                    self.tblEarning.reloadData()
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
                                SharedManager.showAlertWithMessage(title: "Sorry", alertMessage: "The Internet connection appears to be offline", viewController: self)
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
}

