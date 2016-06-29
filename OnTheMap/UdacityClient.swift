//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Leqi Long on 6/16/16.
//  Copyright © 2016 Student. All rights reserved.
//

import Foundation

class UdacityClient: NSObject{
    
    // MARK: Properties
    
    let response: Response
    var user: User? = nil
    
    override init(){
        let urlComponents = URLComponents(scheme: UdacityConstants.ApiScheme, host: UdacityConstants.ApiHost, path: UdacityConstants.ApiPath)
        response = Response(url: urlComponents)
    }
    
    func createUacityRequest(url: NSURL, method: HTTPMethod, body: [String:AnyObject]? = nil, headers: [String:String]? = nil, completionHandler: (parsedResult: [String:AnyObject]?, error: NSError?) -> Void){
        
        var allHeaders = [
            HeaderFieldKeys.Accept:HeaderFieldValues.JSON,
            HeaderFieldKeys.ContentType:HeaderFieldValues.JSON
            
        ]
        
        if let headers = headers {
            for (key, value) in headers{
                allHeaders[key] = value
            }
        }
        
        response.taskForAnyMethod(url, method: method, headers: allHeaders, jsonBody: body){(result, error) in
            if let result = result {
                let parsedResult = try! NSJSONSerialization.JSONObjectWithData(result.subdataWithRange(NSMakeRange(5, result.length - 5)), options: .AllowFragments) as! [String:AnyObject]
                completionHandler(parsedResult: parsedResult, error: nil)
            }else{
                completionHandler(parsedResult: nil, error: error)
            }
        }
    }
    
    //MARK: Login
    
    func loginUdacity(username: String, password: String, facebookAccessToken: String? = nil, completionHandler: (userKey: String?, error: NSError?) -> Void){
        
        let requestURL = response.urlForRequests(nil, method: Methods.CreateSession, withPathExtension: nil)
        var body = [String:AnyObject]()
        
        if let facebookAccessToken = facebookAccessToken{
            body["facebook_mobile"] = [
                "access_token":facebookAccessToken
            ]
        }else{
            body[HTTPBodyKeys.Udacity] = [
                HTTPBodyKeys.Username:username,
                HTTPBodyKeys.Password:password
            ]
        }
        
        createUacityRequest(requestURL, method: .POST, body: body){(parsedRessult, error) in
                guard error == nil else {
                completionHandler(userKey: nil, error: error)
                return
            }
            
            if let parsedRessult = parsedRessult{
                if let status = parsedRessult[UdacityJSONResponseKeys.Status] as? Int,
                    let error = parsedRessult[UdacityJSONResponseKeys.Error] as? String {
                    completionHandler(userKey: nil, error: self.response.errorStatus(status, description: error))
                    return
                }
                if let account = parsedRessult[UdacityJSONResponseKeys.Account] as? [String:AnyObject],
                    let key = account[UdacityJSONResponseKeys.Key] as? String {
                    completionHandler(userKey: key, error: nil)
                    return
                }
            }
            
             completionHandler(userKey: nil, error: self.response.errorStatus(0, description: "Unable to login"))

        }
        
    }
    
    //MARK: Login via facebook
    
    func loginViaFacebook(accessToken: String, completionHandler: (userKey: String?, error: NSError?) -> Void){
        loginUdacity("", password: "", facebookAccessToken: accessToken, completionHandler: completionHandler)
    }
   
    //MARK: Get user public data
    func getUserData(userKey: String, completionHandler: (user: User?, error: NSError?) -> Void){
        let requestURL = response.urlForRequests(nil, method: Methods.UserData, withPathExtension: userKey)
        
        createUacityRequest(requestURL, method: .GET){(parsedResult, error) in
            guard error == nil else {
                completionHandler(user: nil, error: error)
                return
            }
            
            if let parsedResult = parsedResult,
            let userData = parsedResult[UdacityJSONResponseKeys.User] as? [String:AnyObject],
            let firstName = userData[UdacityJSONResponseKeys.FirstName] as? String,
                let lastName = userData[UdacityJSONResponseKeys.LastName] as? String{
                completionHandler(user: User(key: userKey, firstName: firstName, lastName: lastName, url: ""), error: nil)
                
            }else{
                completionHandler(user: nil, error: self.response.errorStatus(0, description: "No user data"))
            }
        }
    }
    
    //MARK: Log out Udacity 
    func deleteUdacitySession(completionHandler: (success: Bool, error: NSError?)->Void){
        let requestURL = response.urlForRequests(nil, method: Methods.DeleteSession, withPathExtension: nil)
        var logoutHeaders = [String:String]()
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == Cookies.XSRFToken { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            logoutHeaders[HeaderFieldKeys.XSRFToken] = xsrfCookie.value
        }
        
        createUacityRequest(requestURL, method: .DELETE){(parsedResult, error) in
            guard error == nil else{
                completionHandler(success: false, error: error)
                return
            }
            
            if let _ = parsedResult,
                let _ = parsedResult![UdacityJSONResponseKeys.Session] as? [String:AnyObject]{
                completionHandler(success: true, error: nil)
            }else{
                completionHandler(success: false, error: self.response.errorStatus(0, description: "Cannot logout"))
            }
        }
    }
    
    // MARK: Singleton Instance
    
    private static var sharedInstance = UdacityClient()
    
    class func sharedClient() -> UdacityClient {
        return sharedInstance
    }

    

}