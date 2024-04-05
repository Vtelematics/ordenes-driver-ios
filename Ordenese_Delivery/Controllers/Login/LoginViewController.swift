//
//  LoginViewController.swift
//  FoodDelivery
//
//  Created by Adyas Iinfotech on 16/03/18.
//  Copyright © 2018 Adyas Iinfotech. All rights reserved.
//

import UIKit
import Alamofire
import OneSignal

class LoginViewController: UIViewController {
    
    @IBOutlet var btnLogin: UIButton!
    
    @IBOutlet var txtUsername: UITextField!
    @IBOutlet var txtPassword: UITextField!
    @IBOutlet var vwForgot: UIView!
    @IBOutlet var vwLanguage: UIView!
    @IBOutlet var txtEmailForgot: UITextField!
    @IBOutlet var imgPasswordVisible: UIImageView!
    @IBOutlet var lblJoinNow: UILabel!
    
    //register
    @IBOutlet var vwSignup: UIView!
    @IBOutlet var txtRegName: UITextField!
    @IBOutlet var txtRegUsername: UITextField!
    @IBOutlet var txtRegPassword: UITextField!
    @IBOutlet var txtRegConfirmPwd: UITextField!
    @IBOutlet var txtRegTelephone: UITextField!
    @IBOutlet var imgRegPwdVisible: UIImageView!
    @IBOutlet var imgRegConfirmPwdVisible: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    
    //MARK: Button Actions
    
    @IBAction func clickForgotSend(_ sender: Any)
    {
        if txtEmailForgot.hasText
        {
            if self.isValidEmail(testStr: txtEmailForgot.text!)
            {
                self.updatePassword()
            }else{
                SharedManager.showAlertWithMessage(title: NSLocalizedString("Sorry", comment: ""), alertMessage: NSLocalizedString("Please Enter a Valid Email-Id", comment: ""), viewController: self)
            }
        }else{
            SharedManager.showAlertWithMessage(title: NSLocalizedString("Sorry", comment: ""), alertMessage: NSLocalizedString("Please Enter your Email-Id", comment: ""), viewController: self)
        }
    }

    @IBAction func clickLogin(_ sender: Any)
    {
        if !txtUsername.hasText
        {
            SharedManager.showAlertWithMessage(title: NSLocalizedString("Sorry", comment: ""), alertMessage: NSLocalizedString("Please enter Username", comment: ""), viewController: self)
        }
        else
        {
            if !txtPassword.hasText
            {
                SharedManager.showAlertWithMessage(title: NSLocalizedString("Sorry", comment: ""), alertMessage: NSLocalizedString("Please enter Password", comment: ""), viewController: self)
            }
            else
            {
                self.loginApi()
            }
        }
    }

    @IBAction func clickForgotPwd(_ sender: Any)
    {
        self.vwForgot.isHidden = false
    }
    
    @IBAction func clickForgotClose(_ sender: Any)
    {
        view.endEditing(true)
        self.vwForgot.isHidden = true
    }
    
    @IBAction func clickArabic(_ sender: Any)
    {
        /*UserDefaults.standard.set("2", forKey: "language_id")
        UserDefaults.standard.removeObject(forKey: "AppleLanguages")
        UserDefaults.standard.set(["ar"], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        //  LanguageManager.isCurrentLanguageRTL()
        //  LanguageManager.currentLanguageString()
        
        LanguageManager.currentLanguageCode()
        LanguageManager.saveLanguage(by: 1)
        LanguageManager.setupCurrentLanguage()*/
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        self.navigationController?.pushViewController(viewController, animated: true)
        self.present(viewController, animated: true, completion: nil)
    }
    
    @IBAction func clickEnglish(_ sender: Any)
    {
       /* UserDefaults.standard.set("1", forKey: "language_id")
        UserDefaults.standard.removeObject(forKey: "AppleLanguages")
        UserDefaults.standard.set(["en"], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        //  LanguageManager.isCurrentLanguageRTL()
        //  LanguageManager.currentLanguageString()
        
        LanguageManager.currentLanguageCode()
        LanguageManager.saveLanguage(by: 0)
        LanguageManager.setupCurrentLanguage()*/
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        self.present(viewController, animated: true, completion: nil)
    }
    
    @IBAction func clickViewPwd(_ sender: Any)
    {
        if self.txtPassword.isSecureTextEntry
        {
            self.txtPassword.isSecureTextEntry = false
            imgPasswordVisible.image = UIImage (named: "ic_visibility")
        }
        else
        {
            self.txtPassword.isSecureTextEntry = true
            imgPasswordVisible.image = UIImage (named: "ic_visibility_off")
        }
    }
    
    @IBAction func clickJoinNow(_ sender: Any)
    {
        self.txtRegName.text! = ""
        self.txtRegUsername.text! = ""
        self.txtRegPassword.text! = ""
        self.txtRegConfirmPwd.text! = ""
        self.txtRegTelephone.text! = ""
        self.vwSignup.isHidden = false
    }
    
    @IBAction func clickSignupBack(_ sender: Any)
    {
        self.vwSignup.isHidden = true
    }
    
    @IBAction func clickRegViewPwd(_ sender: Any)
    {
        if self.txtRegPassword.isSecureTextEntry
        {
            self.txtRegPassword.isSecureTextEntry = false
            imgRegPwdVisible.image = UIImage (named: "ic_visibility")
        }
        else
        {
            self.txtRegPassword.isSecureTextEntry = true
            imgRegPwdVisible.image = UIImage (named: "ic_visibility_off")
        }
    }
    
    @IBAction func clickRegViewConfirmPwd(_ sender: Any)
    {
        if self.txtRegConfirmPwd.isSecureTextEntry
        {
            self.txtRegConfirmPwd.isSecureTextEntry = false
            imgRegConfirmPwdVisible.image = UIImage (named: "ic_visibility")
        }
        else
        {
            self.txtRegConfirmPwd.isSecureTextEntry = true
            imgRegConfirmPwdVisible.image = UIImage (named: "ic_visibility_off")
        }
    }
    
    @IBAction func clickSignup(_ sender: Any)
    {
        if txtRegName.text == ""
        {
            SharedManager.showAlertWithMessage(title: NSLocalizedString("Sorry", comment: ""), alertMessage: NSLocalizedString("Please Enter your Name", comment: ""), viewController: self)
        }
        else
        {
            if txtRegUsername.text == ""
            {
                SharedManager.showAlertWithMessage(title: NSLocalizedString("Sorry", comment: ""), alertMessage: NSLocalizedString("Please Enter your Username", comment: ""), viewController: self)
            }
            else
            {
                if txtRegTelephone.text == "" {
                    SharedManager.showAlertWithMessage(title: NSLocalizedString("Sorry", comment: ""), alertMessage: NSLocalizedString("Please Enter your Phone Number", comment: ""), viewController: self)
                }
                else
                {
                    if txtRegPassword.text == ""
                    {
                        SharedManager.showAlertWithMessage(title: NSLocalizedString("Sorry", comment: ""), alertMessage: NSLocalizedString("Please Enter Password", comment: ""), viewController: self)
                    }
                    else
                    {
                        if txtRegConfirmPwd.text == ""
                        {
                            SharedManager.showAlertWithMessage(title: NSLocalizedString("Sorry", comment: ""), alertMessage: NSLocalizedString("Please Re-Enter Password", comment: ""), viewController: self)
                        }
                        else
                        {
                            if txtRegConfirmPwd.text != txtRegPassword.text
                            {
                                SharedManager.showAlertWithMessage(title: NSLocalizedString("Sorry", comment: ""), alertMessage: NSLocalizedString("Passwords Mismatching", comment: ""), viewController: self)
                            }
                            else
                            {
                                self.signUpApi()
                            }
                        }
                    }
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Funtions
    func loginApi()
    {
        self.view.endEditing(true)
        SharedManager.showHUD(viewController: self)
        let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
        if let id = status.subscriptionStatus.userId {
            notificationId = id
            OneSignal.sendTag("delivery_user_id", value: "\(notificationId)")
            print("\nOneSignal UserId:", id)
        }
        var aParameters = [String : Any]()
        aParameters["telephone"] = self.txtUsername.text!
        aParameters["password"] = self.txtPassword.text!
        aParameters["device_type"] = "2"
        aParameters["push_id"] = notificationId
        aParameters["language_id"] = languageID
        let urlStr = "\(ConfigUrl.baseUrl)login"
        let setFinalURl = urlStr.addingPercentEncoding (withAllowedCharacters: .urlQueryAllowed)!
        var request = URLRequest(url: URL(string: setFinalURl)!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let setTemp: [String : Any] = aParameters as [String : Any]
        if let jsonData: Data = try? JSONSerialization.data(withJSONObject: setTemp, options: .prettyPrinted) {
            let jsonString = String(data: jsonData , encoding: .utf8)!
            print(jsonString)
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
                            print(result)
                            let userDetails = result.value(forKey: "driver_info") as! [String: Any]
                            let encodedData = NSKeyedArchiver.archivedData(withRootObject: userDetails)
                            UserDefaults.standard.set(userDetails["secret_key"], forKey: "USER_ID")
                            UserDefaults.standard.set(userDetails["driver_id"], forKey: "DRIVER_ID")
                            UserDefaults.standard.set(encodedData, forKey: kUserDetails)
                            UserDefaults.standard.set(userDetails["shift_status"], forKey: "SHIFT_STATUS")
                            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
                            self.navigationController?.pushViewController(viewController, animated: true)
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
        }else{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "ErrorViewController")
                as! ErrorViewController
            self.present(viewController, animated: true, completion: { () -> Void in
            })
        }
    }
    
    func signUpApi()
    {
        self.view.endEditing(true)
        SharedManager.showHUD(viewController: self)

        if let userId = OneSignal.getPermissionSubscriptionState().subscriptionStatus.userId{
            notificationId = userId
            OneSignal.sendTag("delivery_user_id", value: "\(notificationId)")
            print("\nOneSignal UserId:", userId)
        }

        let params = [
            "name" : self.txtRegName.text!,
            "username" : self.txtRegUsername.text!,
            "password" : self.txtRegPassword.text!,
            "telephone" : self.txtRegTelephone.text!,
            "push_id" : notificationId
            ] as [String : Any]
        
        let urlStr = "\(ConfigUrl.baseUrl)delivery/account/registration"
        print("registration:\(urlStr)")
        let setFinalURl = urlStr.addingPercentEncoding (withAllowedCharacters: .urlQueryAllowed)!
        var request = URLRequest(url: URL(string: setFinalURl)!, cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 60)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let setTemp: [String : Any] = params
        
        if let jsonData: Data = try? JSONSerialization.data(withJSONObject: setTemp, options: .prettyPrinted) {
            let jsonString = String(data: jsonData , encoding: .utf8)!
            print(jsonString)
            request.httpBody = jsonData
        }
        
        Alamofire.request(request).responseJSON { (responseObject) -> Void in
            
            if responseObject.result.isSuccess
            {
                print(responseObject.result.value!)
                let result = responseObject.result.value! as AnyObject
                print(result)
                if let code = result.value(forKeyPath: "success.status")
                {
                    if code as! String == "200"
                    {
                        SharedManager.dismissHUD(viewController: self)
                        let alert = UIAlertController(title: "Thanks", message: "\(result.value(forKeyPath: "success.message")!)", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                            
                            self.txtUsername.text = self.txtRegUsername.text!
                            self.txtPassword.text = self.txtRegPassword.text!

                            self.loginApi()
                            
                            self.vwSignup.isHidden = true
                            
                        }))
                        self.present(alert, animated: true, completion: nil)
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
    
    func updatePassword(){
        self.view.endEditing(true)
        SharedManager.showHUD(viewController: self)
        let params = [
            "email": self.txtEmailForgot.text!,
            "language_id": languageID
        ] as [String: Any]
        let urlStr = "\(ConfigUrl.baseUrl)forget-password"
        let setFinalURl = urlStr.addingPercentEncoding (withAllowedCharacters: .urlQueryAllowed)!
        var request = URLRequest(url: URL(string: setFinalURl)!)
        request.httpMethod = HTTPMethod.post.rawValue
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
                            SharedManager.dismissHUD(viewController: self)
                            self.vwForgot.isHidden = true
                            SharedManager.showAlertWithMessage(title: NSLocalizedString("Sorry", comment: ""), alertMessage: NSLocalizedString("Password reset link sent to your Mail-id", comment: ""), viewController: self)
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
        }else
        {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "ErrorViewController")
                as! ErrorViewController
            self.present(viewController, animated: true, completion: { () -> Void in
            })
        }
    }
    
    func setupUI(){
        self.navigationController?.navigationBar.isHidden = true
        self.btnLogin.layer.borderColor = UIColor.white.cgColor
        let normalText = NSLocalizedString("Want to join us as a Driver?", comment: "")
        let attributedStringColor = [NSAttributedString.Key.foregroundColor : positiveBtnColor];
        let attributedString = NSAttributedString(string: NSLocalizedString("Join Now", comment: ""), attributes: attributedStringColor)
        let normalString = NSMutableAttributedString(string:normalText)
        normalString.append(attributedString)
        self.lblJoinNow.attributedText = normalString
        txtUsername.attributedPlaceholder = NSAttributedString(string: txtUsername.placeholder!, attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
        txtPassword.attributedPlaceholder = NSAttributedString(string: txtPassword.placeholder!, attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
        txtEmailForgot.attributedPlaceholder = NSAttributedString(string: txtEmailForgot.placeholder!, attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
        txtRegName.attributedPlaceholder = NSAttributedString(string: txtRegName.placeholder!, attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
        txtRegUsername.attributedPlaceholder = NSAttributedString(string: txtRegUsername.placeholder!, attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
        txtRegPassword.attributedPlaceholder = NSAttributedString(string: txtRegPassword.placeholder!, attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
        txtRegConfirmPwd.attributedPlaceholder = NSAttributedString(string: txtRegConfirmPwd.placeholder!, attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
        txtRegTelephone.attributedPlaceholder = NSAttributedString(string: txtRegTelephone.placeholder!, attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
        self.txtRegName.textAlignment = isRTLenabled == true ? .right : .left
        self.txtRegUsername.textAlignment = isRTLenabled == true ? .right : .left
        self.txtRegPassword.textAlignment = isRTLenabled == true ? .right : .left
        self.txtRegConfirmPwd.textAlignment = isRTLenabled == true ? .right : .left
        self.txtRegTelephone.textAlignment = isRTLenabled == true ? .right : .left
        self.txtUsername.textAlignment = isRTLenabled == true ? .right : .left
        self.txtPassword.textAlignment = isRTLenabled == true ? .right : .left
        self.txtEmailForgot.textAlignment = isRTLenabled == true ? .right : .left
    }
    
    func isValidEmail(testStr:String) -> Bool
    {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
}
