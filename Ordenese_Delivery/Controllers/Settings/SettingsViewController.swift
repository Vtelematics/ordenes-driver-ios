//
//  SettingsViewController.swift
//  FoodDelivery
//
//  Created by Apple on 31/05/18.
//  Copyright © 2018 Adyas Iinfotech. All rights reserved.
//

import UIKit
import Alamofire
import Reachability
import OpalImagePicker
import Photos

class SettingsViewController: ParentViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    @IBOutlet weak var tblMain: UITableView!
    @IBOutlet weak var lblProfileName: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileBlurImage: UIImageView!
    @IBOutlet weak var vwChangePassword: UIView!
    @IBOutlet weak var txtOldPwd: UITextField!
    @IBOutlet weak var txtNewPwd: UITextField!
    @IBOutlet weak var txtConfirmPwd: UITextField!
    
    let imagePicker = UIImagePickerController()
    
    var userDetails = [String: Any]()
    
    var isEdited = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SharedManager.showHUD(viewController: self)
        self.txtNewPwd.textAlignment = isRTLenabled == true ? .right : .left
        self.txtOldPwd.textAlignment = isRTLenabled == true ? .right : .left
        self.txtConfirmPwd.textAlignment = isRTLenabled == true ? .right : .left
        userIDStr = UserDefaults.standard.string(forKey: "USER_ID")!
        getProfileInfo()
    }
    
    //MARK: Function
    func getProfileInfo(){
        let params = [
            "language_id": languageID
        ] as [String: Any]
        let urlStr = "\(ConfigUrl.baseUrl)profile-info"
        let setFinalURl = urlStr.addingPercentEncoding (withAllowedCharacters: .urlQueryAllowed)!
        var request = URLRequest(url: URL(string: setFinalURl)!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue(userIDStr, forHTTPHeaderField: "Driver-Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let setTemp: [String : Any] = params
        if let jsonData: Data = try? JSONSerialization.data(withJSONObject: setTemp, options: .prettyPrinted) {
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
                                self.userDetails = result.value(forKey: "driver_info") as! [String: Any]
                                let encodedData = NSKeyedArchiver.archivedData(withRootObject: self.userDetails)
                                UserDefaults.standard.set(encodedData, forKey: kUserDetails)
                                self.lblProfileName.text = "\(self.userDetails["name"]!)"
                                if let imageUrl = self.userDetails["driver_pic"]
                                {
                                    if "\(imageUrl)" != "<null>" && "\(imageUrl)" != ""
                                    {
                                        let trimmedUrl = (imageUrl as AnyObject).trimmingCharacters(in: CharacterSet(charactersIn: "")).replacingOccurrences(of: " ", with: "%20") as String
                                        self.profileImage.sd_setImage(with: URL(string: trimmedUrl))
                                        self.profileBlurImage.sd_setImage(with: URL(string: trimmedUrl))
                                    }
                                }
                                self.tblMain.reloadData()
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
        imagePicker.delegate = self
        tblMain.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tblMain.contentOffset = CGPoint(x: 0, y: -225)
        // Do any additional setup after loading the view.
    }
    
    func changePasswordDone(){
        self.view.endEditing(true)
        SharedManager.showHUD(viewController: self)
        let params = [
            "password": self.txtNewPwd.text!,
            "confirm_password": self.txtConfirmPwd.text!,
            "language_id": languageID
        ] as [String: Any]
        let urlStr = "\(ConfigUrl.baseUrl)change-password"
        let setFinalURl = urlStr.addingPercentEncoding (withAllowedCharacters: .urlQueryAllowed)!
        var request = URLRequest(url: URL(string: setFinalURl)!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue(userIDStr, forHTTPHeaderField: "Driver-Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
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
                    print(result)
                    if let code = result.value(forKeyPath: "success.status")
                    {
                        if code as! String == "200"
                        {
                            self.vwChangePassword.isHidden = true
                            self.txtOldPwd.text = ""
                            self.txtNewPwd.text = ""
                            self.txtConfirmPwd.text = ""
                            SharedManager.showAlertWithMessage(title: "", alertMessage: NSLocalizedString("Your Password updated Successfully", comment: ""), viewController: self)
                            SharedManager.dismissHUD(viewController: self)
                        }else{
                            SharedManager.showAlertWithMessage(title: "", alertMessage: result.value(forKeyPath: "success.message") as! String, viewController: self)
                            SharedManager.dismissHUD(viewController: self)
                        }
                    }else{
                        SharedManager.dismissHUD(viewController: self)
                         SharedManager.showAlertWithMessage(title: "", alertMessage: result.value(forKeyPath: "error.message") as! String, viewController: self)
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
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "ErrorViewController")
                as! ErrorViewController
            self.present(viewController, animated: true, completion: { () -> Void in
            })
        }
    }
    
    func saveProfile(){
        self.view.endEditing(true)
        SharedManager.showHUD(viewController: self)
        var index = IndexPath(row: 0, section: 0)
        let cell: ProfileTableViewCell = self.tblMain.cellForRow(at: index) as! ProfileTableViewCell
        index = IndexPath(row: 1, section: 0)
        let params = [
            "name": cell.txtFname.text!,
            "sur_name": cell.txtLname.text!,
            "email": cell.txtEmail.text!
        ] as [String: Any]
        let urlStr = "\(ConfigUrl.baseUrl)profile-edit"
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
        if Connectivity.isConnectedToInternet()
        {
            Alamofire.request(request).responseJSON { (responseObject) -> Void in
                if responseObject.result.isSuccess
                {
                    let result = responseObject.result.value! as AnyObject
                    if let code = result.value(forKeyPath: "success.status")
                    {
                        SharedManager.dismissHUD(viewController: self)
                        if code as! String == "200"
                        {
                            SharedManager.showAlertWithMessage(title: "", alertMessage: NSLocalizedString("Your Account has been updated Successfully", comment: ""), viewController: self)
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
        }else
        {
            SharedManager.dismissHUD(viewController: self)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "ErrorViewController")
                as! ErrorViewController
            self.present(viewController, animated: true, completion: { () -> Void in
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK: Button action
    @IBAction func clickSaveDetails(_ sender: Any)
    {
        self.saveProfile()
    }
    
    @IBAction func clickProfilePicture(_ sender: Any)
    {
        let actionSheet: UIAlertController = UIAlertController(title: NSLocalizedString("Change Profile Picture", comment: ""), message: "", preferredStyle: .actionSheet)
        
        let cancelActionButton = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { _ in
            print("Cancel")
        }
        actionSheet.addAction(cancelActionButton)
        let cameraAction = UIAlertAction(title: NSLocalizedString("Camera", comment: ""), style: .default)
        { _ in
            if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera))
            {
                self.imagePicker.delegate = self
                self.imagePicker.allowsEditing = false
                self.imagePicker.sourceType = UIImagePickerController.SourceType.camera
                self.imagePicker.cameraCaptureMode = .photo
                self.present(self.imagePicker, animated: true, completion: nil)
            }
            else
            {
                SharedManager.showAlertWithMessage(title: NSLocalizedString("Camera Not Found", comment: ""), alertMessage: NSLocalizedString("This device has no Camera", comment: ""), viewController: self)
            }
        }
        actionSheet.addAction(cameraAction)
        let galleryAction = UIAlertAction(title: NSLocalizedString("Gallery", comment: ""), style: .default)
        { _ in
            
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.allowsEditing = false
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        actionSheet.addAction(galleryAction)
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.dismiss(animated: true, completion: {})
        guard let image = (info[UIImagePickerController.InfoKey.originalImage] as? UIImage) else { return }
        SharedManager.showHUD(viewController: self)
        profileImage.image = image
        let imageData:NSData = image.jpegData(compressionQuality: 0.01)! as NSData
        let baseStr = imageData.base64EncodedString(options: [])
        let params = [
            "image": baseStr
        ] as [String: Any]
        self.view.endEditing(true)
        let urlStr = "\(ConfigUrl.baseUrl)profile-picture"
        let setFinalURl = urlStr.addingPercentEncoding (withAllowedCharacters: .urlQueryAllowed)!
        var request = URLRequest(url: URL(string: setFinalURl)!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue(userIDStr, forHTTPHeaderField: "Driver-Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
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
                            SharedManager.dismissHUD(viewController: self)
                            SharedManager.showAlertWithMessage(title: "", alertMessage: NSLocalizedString("Your profile Image uploaded", comment: ""), viewController: self)
                            self.getProfileInfo()
                        }
                    }else{
                        SharedManager.dismissHUD(viewController: self)
                         SharedManager.showAlertWithMessage(title: "", alertMessage: result.value(forKeyPath: "error.message") as! String, viewController: self)
                    }
                }
                if responseObject.result.isFailure
                {
                    SharedManager.dismissHUD(viewController: self)
                    let error : Error = responseObject.result.error!
                    SharedManager.showAlertWithMessage(title: NSLocalizedString("Sorry", comment: ""), alertMessage: error.localizedDescription, viewController: self)
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
   
    //MARK: Change Password
    @IBAction func clickClose(_ sender: Any)
    {
        self.view.endEditing(true)
        self.vwChangePassword.isHidden = true
    }
    
    @IBAction func clickChangePasswordDone(_ sender: Any)
    {
        if !txtNewPwd.hasText
        {
            SharedManager.showAlertWithMessage(title: NSLocalizedString("Sorry", comment: ""), alertMessage: NSLocalizedString("Please enter new Password", comment: ""), viewController: self)
        }
        else
        {
            if !txtConfirmPwd.hasText
            {
                SharedManager.showAlertWithMessage(title: NSLocalizedString("Sorry", comment: ""), alertMessage: NSLocalizedString("Please re-enter your new Password", comment: ""), viewController: self)
            }
            else
            {
                self.changePasswordDone()
            }
        }
    }
    
    @IBAction func clickChangePassword(_ sender: Any)
    {
        self.txtOldPwd.text = ""
        self.txtNewPwd.text = ""
        self.txtConfirmPwd.text = ""
        self.vwChangePassword.isHidden = false
    }
    
    //MARK: TableView Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if indexPath.row == 0
        {
            let cell:ProfileTableViewCell = self.tblMain.dequeueReusableCell(withIdentifier: "detailCell") as! ProfileTableViewCell
            
            if userDetails.count != 0
            {
                cell.txtFname.text = "\(userDetails["name"]!)"
                cell.txtLname.text = "\(userDetails["sur_name"]!)"
                cell.txtEmail.text = "\(userDetails["email"]!)"
                cell.txtPhone.text = "\(userDetails["telephone"]!)"
            }
            cell.txtFname.textAlignment = isRTLenabled == true ? .right : .left
            cell.txtLname.textAlignment = isRTLenabled == true ? .right : .left
            cell.txtEmail.textAlignment = isRTLenabled == true ? .right : .left
            cell.txtPhone.textAlignment = isRTLenabled == true ? .right : .left
            return cell
        }
//        else if indexPath.row == 1
//        {
//            let cell:ProfileTableViewCell = self.tblMain.dequeueReusableCell(withIdentifier: "accountCell") as! ProfileTableViewCell
//            if userDetails.count != 0
//            {
//                let bankDetails = userDetails["bank_details"] as! [String: Any]
//                if bankDetails.count != 0
//                {
//                    cell.txtAccountName.text = "\(bankDetails["account_name"]!)"
//                    cell.txtBank.text = "\(bankDetails["bank_name"]!)"
//                    cell.txtAccountNum.text = "\(bankDetails["account_no"]!)"
//                    cell.txtIfsc.text = "\(bankDetails["bank_code"]!)"
//                }
//                else
//                {
//                    cell.txtAccountName.text = ""
//                    cell.txtBank.text = ""
//                    cell.txtAccountNum.text = ""
//                    cell.txtIfsc.text = ""
//                }
//                cell.txtAccountName.textAlignment = .left
//                cell.txtBank.textAlignment = .left
//                cell.txtAccountNum.textAlignment = .left
//                cell.txtIfsc.textAlignment = .left
//            }
//            return cell
//        }
        else
        {
            let cell:ProfileTableViewCell = self.tblMain.dequeueReusableCell(withIdentifier: "settingsCell") as! ProfileTableViewCell
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if indexPath.row == 0{
            return 327
        }
//        else if indexPath.row == 1{
//            return 357
//        }
        else{
            return 64
        }
    }
}

