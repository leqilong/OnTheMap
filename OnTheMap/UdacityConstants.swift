//
//  UdacityConstants.swift
//  OnTheMap
//
//  Created by Leqi Long on 6/16/16.
//  Copyright © 2016 Student. All rights reserved.
//

extension UdacityClient{
    
    struct UdacityConstants {
        
        // MARK: URLs
        static let ApiScheme = "https"
        static let ApiHost = "www.udacity.com"
        static let ApiPath = "/api"

        static let SignUpURL = "https://www.udacity.com/account/auth#!/signup"
    }
    
    struct Methods{
        static let UserData = "/users/"
        static let CreateSession = "/session"
        static let DeleteSession = "/session"
    }
    
    // MARK: HeaderKeys
    
    struct HeaderFieldKeys {
        static let Accept = "Accept"
        static let ContentType = "Content-Type"
        static let XSRFToken = "X-XSRF-TOKEN"
    }
    
    // MARK: HeaderValues
    
    struct HeaderFieldValues {
        static let JSON = "application/json"
    }
    
    // MARK: HTTPBodyKeys
    
    struct HTTPBodyKeys {
        static let Udacity = "udacity"
        static let Username = "username"
        static let Password = "password"
    }
    
    // MARK: Udacity Response Keys
    struct UdacityJSONResponseKeys {
        static let Account = "account"
        static let Registered = "registered"
        static let Key = "key"
        
        static let Session = "session"
        static let SessionID = "id"
        static let SessionExpiration = "expiration"
        
        static let User = "user"
        static let LastName = "last_name"
        static let FirstName = "first_name"
        
        static let Status = "status"
        static let Error = "error"

    }
    
    struct Cookies {
        static let XSRFToken = "XSRF-TOKEN"
    }
    
}
