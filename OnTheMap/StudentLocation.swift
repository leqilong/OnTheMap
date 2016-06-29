//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by Leqi Long on 6/16/16.
//  Copyright © 2016 Student. All rights reserved.
//

struct StudentLocation{
    
    // MARK: Properties
    let objectId: String
    let user: User
    let location: Location
    
    // MARK: Initializers
    
    // construct a StudentLocation from a dictionary
    init(dictionary: [String:AnyObject]) {
        objectId = dictionary[ParseClient.JSONResponseKeys.ObjectID] as? String ?? ""
        let firstName = dictionary[ParseClient.JSONResponseKeys.FirstName] as? String ?? ""
        let lastName = dictionary[ParseClient.JSONResponseKeys.LastName] as? String ?? ""
        let mediaURL = dictionary[ParseClient.JSONResponseKeys.MediaURL] as? String ?? ""
        let uniqueKey = dictionary[ParseClient.JSONResponseKeys.UniqueKey] as? String ?? "No unique key"
        user = User(key: uniqueKey, firstName: firstName, lastName: lastName, url: mediaURL)
        
        
        let latitude = dictionary[ParseClient.JSONResponseKeys.Latitude]  as? Double ?? 0.0
        let longitude = dictionary[ParseClient.JSONResponseKeys.Longitude] as? Double ?? 0.0
        let mapString = dictionary[ParseClient.JSONResponseKeys.MapString] as? String ?? ""
        location = Location(latitude: latitude, longitude: longitude, mapString: mapString)
    }

    static func studentLocationsFromMap(results: [[String:AnyObject]]) -> [StudentLocation] {
        
        var students = [StudentLocation]()
        
        // iterate through array of dictionaries, each StudentLocation is a dictionary
        for result in results {
            students.append(StudentLocation(dictionary: result))
        }
        
        return students
    }
    
    init(user: User, location: Location) {
        objectId = ""
        self.user = user
        self.location = location
    }
    
    init(objectID: String, user: User, location: Location) {
        self.objectId = objectID
        self.user = user
        self.location = location
    }

}

extension StudentLocation: Equatable {}

func ==(lhs: StudentLocation, rhs: StudentLocation) -> Bool {
    return lhs.objectId == rhs.objectId
}