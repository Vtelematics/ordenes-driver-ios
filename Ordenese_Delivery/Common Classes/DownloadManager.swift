
//  DownloadManager.swift
//  E-Commerce
//
//  Created by Apple on 24/06/15.
//  Copyright (c) 2015 Apple. All rights reserved.
//

import UIKit

class DownloadManager: NSObject {
  
    class func downloadDataFromServer(_ parameter:String , urlString: String) ->NSDictionary
    {
        let request = NSMutableURLRequest()
        request.url = URL(string: urlString)
       // request.setValue("application/json; charset=utf-8", forHTTPHeaderField:"Content-Disposition")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"
        
       // jsonData = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
        
        let data = (parameter as NSString).data(using: String.Encoding.utf8.rawValue)
        request.httpBody = data
        
        var Error:NSError? = nil
        
        var returnData: Data?
        do {
            returnData = try NSURLConnection.sendSynchronousRequest(request as URLRequest, returning: nil)
        } catch let error as NSError {
            Error = error
            returnData = nil
        }
        
        if(Error == nil)
        {
            return self.validateResponds(returnData!)
        }
        let errorResult:NSDictionary = [
            "status" : "401",
            "message" : "Error message"
        ]

        return errorResult
    }
    
    class func downloadDataFromServerWithCustomer(_ parameter:String , urlString: String, customerKey: String) ->NSDictionary
    {
        let request = NSMutableURLRequest()
        request.url = URL(string: urlString)
        request.setValue(customerKey, forHTTPHeaderField:"Customer-Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"
        
        // jsonData = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
        
        let data = (parameter as NSString).data(using: String.Encoding.utf8.rawValue)
        request.httpBody = data
        
        var Error:NSError? = nil
        
        var returnData: Data?
        do {
            returnData = try NSURLConnection.sendSynchronousRequest(request as URLRequest, returning: nil)
        } catch let error as NSError {
            Error = error
            returnData = nil
        }
        
        if(Error == nil)
        {
            return self.validateResponds(returnData!)
        }
        let errorResult:NSDictionary = [
            "status" : "401",
            "message" : "Error message"
        ]
        
        return errorResult
    }
    
    class func downloadDataFromServerGetMethod(_ urlString: String) ->NSDictionary
    {
        let urlString: String! = urlString
        let request: NSMutableURLRequest = NSMutableURLRequest()
        
        let escapedString:String = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!

        request.url = URL(string: escapedString)
        request.httpMethod = "GET"
        
        var Error:NSError? = nil
        var returnData: Data?
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
           // returnData = data
           // print("Response: \(String(describing: response!))")
        })
        task.resume()
        do {
            returnData = try NSURLConnection.sendSynchronousRequest(request as URLRequest, returning: nil)
        } catch let error as NSError
        {
            Error = error
            returnData = nil
        }
        return self.validateResponds(returnData!)
    }
    
    class func downloadDataFromServerGetCustomer(_ urlString: String, customerKey: String) ->NSDictionary
    {
        let urlString: String! = urlString
        let request: NSMutableURLRequest = NSMutableURLRequest()
        
        let escapedString:String = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        request.url = URL(string: escapedString)
        request.httpMethod = "GET"
        request.setValue(customerKey, forHTTPHeaderField:"Customer-Authorization")
       // request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        
        var Error:NSError? = nil
        var returnData: Data?
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            // returnData = data
            // print("Response: \(String(describing: response!))")
        })
        task.resume()
        do {
            returnData = try NSURLConnection.sendSynchronousRequest(request as URLRequest, returning: nil)
        } catch let error as NSError
        {
            Error = error
            returnData = nil
        }
        return self.validateResponds(returnData!)
    }
    
    
    class func validateResponds(_ data:Data) ->NSDictionary
    {
        var dictData: NSDictionary?
        
        let resultString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        print("Flawed JSON String: \(resultString)")
        
        var jsonError:NSError? = nil
        do{
            if  let dict  = try  JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary
            {
                dictData = dict
                return dictData!
            }
            else {
                let resultString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                print("Flawed JSON String: \(resultString)")
                let errorResult:NSDictionary = [
                    "httpCode" : 401,
                    "message" : "Something went wrong"
                ]
                return errorResult
            }
        }
            

        catch let error as NSError
        {
            let dict = ["status":"400", "message":"\(error.localizedDescription)"]
            dictData = dict as NSDictionary?
        }
        return dictData!
    }
    
    
    class func downloadDataFromServerGetMethodArray(_ urlString: String) ->NSArray
    {
        let urlString: String! = urlString
        let request: NSMutableURLRequest = NSMutableURLRequest()
        
        let escapedString:String = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        request.url = URL(string: escapedString)
        request.httpMethod = "GET"
        var Error:NSError? = nil
        var returnData: Data?
        do {
            returnData = try NSURLConnection.sendSynchronousRequest(request as URLRequest, returning: nil)
        } catch let error as NSError {
            Error = error
            returnData = nil
        }
        return self.validateRespondsArray(returnData!)
    }
    class func validateRespondsArray(_ data:Data) -> NSArray
    {
        var dictData: NSArray?
        
        //   var jsonError:NSError? = nil
        do{
            if  let dict  = try  JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSArray
            {
                dictData = dict
                  return dictData!
            }
                
            else {
                let resultString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                print("Flawed JSON String: \(resultString)")
                let errorResult:NSArray = ["Something went worng"]
                return errorResult
            }
        }
            
            
        catch let error as NSError
        {
            let dict = [error.localizedDescription]
            dictData = dict as NSArray?
        }
        return dictData!
    }
    
}
