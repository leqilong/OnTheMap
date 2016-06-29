//
//  Client.swift
//  OnTheMap
//
//  Created by Leqi Long on 6/16/16.
//  Copyright © 2016 Student. All rights reserved.
//

import Foundation

class ParseClient: NSObject{
    // MARK: Properties
    let response: Response
    
    // MARK: Initializers
    override init(){
        let url = URLComponents(scheme: ParseConstants.ApiScheme, host: ParseConstants.ApiHost, path: ParseConstants.ApiPath)
        response = Response(url: url)
    }
    
    func createParseRequest(url: NSURL, method: HTTPMethod, body: [String:AnyObject]? = nil, headers: [String:String]? = nil, completionHandler: (parsedResult: [String:AnyObject]?, error: NSError?) -> Void){
        
        var allHeaders = [
            HeaderFieldKeys.Accept:HeaderFieldValues.JSON,
            HeaderFieldKeys.ContentType:HeaderFieldValues.JSON,
            HeaderFieldKeys.API:HeaderFieldValues.API,
            HeaderFieldKeys.AppId:HeaderFieldValues.AppId
        ]
        
        if let headers = headers {
            for (key, value) in headers{
                allHeaders[key] = value
            }
        }
        
        response.taskForAnyMethod(url, method: method, headers: allHeaders, jsonBody: body){(result, error) in
            if let result = result {
                let parsedResult = try! NSJSONSerialization.JSONObjectWithData(result, options: .AllowFragments) as! [String:AnyObject]
                completionHandler(parsedResult: parsedResult, error: nil)
            }else{
                completionHandler(parsedResult: nil, error: error)
            }
        }
    }

    // MARK: GET student locations
    func getStudentLocations(completionHandler: (studentLocations: [StudentLocation]?, error: NSError?) -> Void){
        let parameters: [String:AnyObject] = [
            ParameterKeys.Limit:ParameterValues.OneHundred,
            ParameterKeys.Order:ParameterValues.MostRecentlyUpdated
            ]
        let requestURL = response.urlForRequests(parameters, method: Objects.StudentLocation, withPathExtension: nil)
        
        createParseRequest(requestURL, method: .GET){(parsedResult, error) in
            guard error == nil else {
                print("Didn't get parsedResult")
                completionHandler(studentLocations: nil, error: error)
                return
            }
            
            if let parsedResult = parsedResult,
                let studentLocationsArray = parsedResult[JSONResponseKeys.Results] as? [[String:AnyObject]]{
                completionHandler(studentLocations: StudentLocation.studentLocationsFromMap(studentLocationsArray), error: nil)
            }else{completionHandler(studentLocations : nil, error: self.response.errorStatus(0, description: "Can't get student locations"))
            }
        }
    }
    
    //MARK: GET a student location
    func getAStudentLocation(userKey: String, completionHandler: (studentLocation: StudentLocation?, error: NSError?) -> Void){
        let parameters: [String:AnyObject] = [ParameterKeys.Where:"{\"\(ParameterKeys.UniqueKey)\":\"" + "\(userKey)" + "\"}"]
        let requestURL = response.urlForRequests(parameters, method: Objects.StudentLocation, withPathExtension: nil)
        
        createParseRequest(requestURL, method: .GET){(parsedResult, error) in
            guard error == nil else {
                print("Didn't get parsedResult")
                completionHandler(studentLocation: nil, error: error)
                return
            }
            
            if let parsedResult = parsedResult,
            let studentLocationsArray = parsedResult[JSONResponseKeys.Results] as? [[String:AnyObject]]{
                if studentLocationsArray.count == 1 {
                    completionHandler(studentLocation: StudentLocation(dictionary: studentLocationsArray[0]), error: nil)
                    return
                    
                }
            }else{
                completionHandler(studentLocation: nil, error: self.response.errorStatus(0, description: "No student found"))
            }
            
        }
        
    }
    
    //MARK: Add a student location for the first time
    func addAStudentLocation(url: String, location: StudentLocation, completionHandler: (success: Bool, error: NSError?) -> Void){
        let requestURL = response.urlForRequests(nil, method: Objects.StudentLocation, withPathExtension: nil)
        
        let body: [String:AnyObject] = [
            JSONResponseKeys.UniqueKey:location.user.key,
            JSONResponseKeys.FirstName:location.user.firstName,
            JSONResponseKeys.LastName:location.user.lastName,
            JSONResponseKeys.MapString:location.location.mapString,
            JSONResponseKeys.MediaURL:url,
            JSONResponseKeys.Latitude:location.location.latitude,
            JSONResponseKeys.Longitude:location.location.longitude
        ]
        
        createParseRequest(requestURL, method: .POST, body: body){(parsedResult, error) in
            guard error == nil else{
                completionHandler(success: false, error: error)
                return
            }
            
            if let parsedResult = parsedResult,
                let _ = parsedResult[JSONResponseKeys.ObjectID] as? String {
                completionHandler(success: true, error: nil)
                return
            }
            
            if let parsedResult = parsedResult,
                let _ = parsedResult[JSONResponseKeys.Error] as? String {
                completionHandler(success: true, error: self.response.errorStatus(0, description: "Cannot add location"))
                return
            }
            
            completionHandler(success: false, error: self.response.errorStatus(0, description: "Cannot add location"))
        }
        
    }
    
    //MARK: Update a student location
    
    func updateStudentLocation(objectID: String, url: String, location: StudentLocation, completionHandler: (success: Bool, error: NSError?) -> Void){
        let requestURL = response.urlForRequests(nil, method: Objects.StudentLocation, withPathExtension: "/\(objectID)")
        
        let body: [String:AnyObject] = [
            JSONResponseKeys.UniqueKey:location.user.key,
            JSONResponseKeys.FirstName:location.user.firstName,
            JSONResponseKeys.LastName:location.user.lastName,
            JSONResponseKeys.MapString:location.location.mapString,
            JSONResponseKeys.Latitude:location.location.latitude,
            JSONResponseKeys.Longitude:location.location.longitude,
            JSONResponseKeys.MediaURL:url
        ]
        
        createParseRequest(requestURL, method: .PUT, body: body){ (parsedResult, error) in
            guard error == nil else{
                completionHandler(success: false, error: error)
                return
            }

            if let parsedResult = parsedResult,
                let _ = parsedResult[JSONResponseKeys.UpdatedAt] as? String {
                completionHandler(success: true, error: nil)
                return
            }
            
            if let parsedResult = parsedResult,
                let _ = parsedResult[JSONResponseKeys.Error] as? String{
                completionHandler(success: true, error: self.response.errorStatus(0, description: "Cannot update location"))
                return
            }
            completionHandler(success: false, error: self.response.errorStatus(0, description: "Cannot update location"))
        }
        
    }
    
    
    // MARK: Singleton Instance
    
    private static var sharedInstance = ParseClient()
    
    class func sharedClient() -> ParseClient {
        return sharedInstance
    }
    
}