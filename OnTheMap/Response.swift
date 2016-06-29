//
//  Response.swift
//  OnTheMap
//
//  Created by Leqi Long on 6/18/16.
//  Copyright © 2016 Student. All rights reserved.
//

import Foundation

enum HTTPMethod: String{
    case GET, POST, PUT, DELETE
}

struct URLComponents{
    let scheme: String
    let host: String
    let path: String
}

class Response{
    
    // MARK: Properties

    let session: NSURLSession!
    let url: URLComponents
    
    init(url: URLComponents){
        
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        self.session = NSURLSession(configuration: config)
        self.url = url
    }
    
    // MARK: A generic request for any method
    
    func taskForAnyMethod(url: NSURL, method: HTTPMethod, headers: [String:String]? = nil, jsonBody: [String:AnyObject]? = nil, completionHandler: (result: NSData?, error: NSError?) -> Void){
        
        /* Build the URL, Configure the request */
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = method.rawValue
        
        /*add headers, if any*/
        if let headers = headers {
            for (key, value) in headers {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        /*add body, if any*/
        if let jsonBody = jsonBody{
            request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(jsonBody, options: NSJSONWritingOptions())
        }
        
        /* Make the request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            func displayError(error: String) {
                print(error)
                completionHandler(result: nil, error: self.errorStatus(1, description: error))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                displayError("There was an error with your request: \(error)")
                return
            }
            
            
            /* did we get a successful response?*/
            if let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode < 200 && statusCode > 299 {
                displayError("Unsuccessful response")
                return
            }
            
            completionHandler(result: data, error: nil)
        }
        
        /* Start the request */
        task.resume()

    }

    
    // MARK: create a URL
    func urlForRequests(parameters: [String:AnyObject]?, method: String, withPathExtension: String? = nil) -> NSURL{
        
        let components = NSURLComponents()
        components.scheme = url.scheme
        components.host = url.host
        components.path = url.path + (method ?? "") + (withPathExtension ?? "")
        components.queryItems = [NSURLQueryItem]()
        
        if let parameters = parameters{
            for (key, value) in parameters {
                let queryItem = NSURLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(queryItem)
            }

        }
        return components.URL!
    }
    
    // MARK: error status
    func errorStatus(status: Int, description: String) -> NSError {
        let userInfo = [NSLocalizedDescriptionKey: description]
        return NSError(domain: "Response", code: status, userInfo: userInfo)
    }
    
}