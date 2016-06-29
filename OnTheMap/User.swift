//
//  User.swift
//  OnTheMap
//
//  Created by Leqi Long on 6/19/16.
//  Copyright © 2016 Student. All rights reserved.
//

struct User {
    let key: String
    let firstName: String
    let lastName: String
    var url: String
    
    init(key: String) {
        self.key = key
        firstName = ""
        lastName = ""
        url = ""
    }
    
    init(key: String, firstName: String, lastName: String, url: String) {
        self.key = key
        self.firstName = firstName
        self.lastName = lastName
        self.url = url
    }
}
