//
//  Constants.swift
//  OnTheMap
//
//  Created by Leqi Long on 6/16/16.
//  Copyright © 2016 Student. All rights reserved.
//

extension ParseClient{
    
    // MARK: Constants
    struct ParseConstants {
        // MARK: URL components
        static let ApiScheme = "https"
        static let ApiHost = "api.parse.com"
        static let ApiPath = "/1/classes"
    }

    struct Objects {
        static let StudentLocation = "/StudentLocation"
    }
    
    // MARK: ParameterKeys
    
    struct ParameterKeys {
        static let Limit = "limit"
        static let Order = "order"
        static let Where = "where"
        static let UniqueKey = "uniqueKey"
    }
    
    // MARK: ParameterValues
    
    struct ParameterValues {
        static let OneHundred = 100
        static let TwoHundred = 200
        static let MostRecentlyUpdated = "-updatedAt"
        static let MostRecentlyCreated = "-createdAt"
    }
    
    struct HeaderFieldKeys {
        static let AppId = "X-Parse-Application-Id"
        static let API = "X-Parse-REST-API-Key"
        static let Accept = "Accept"
        static let ContentType = "Content-Type"
    }
    
    struct HeaderFieldValues{
        static let AppId = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let API = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let JSON = "application/json"
    }
    
    struct JSONResponseKeys{
        
        // MARK: StudentLocation
        static let Results = "results"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let UpdatedAt = "updatedAt"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let ObjectID = "objectId"
        static let UniqueKey = "uniqueKey"
        static let Error = "error"
        
    }
    
    struct Notifications {
        static let ObjectUpdated = "Updated"
        static let ObjectUpdatedError = "Error"
    }

    
}