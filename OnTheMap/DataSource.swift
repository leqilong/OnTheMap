//
//  DataSource.swift
//  OnTheMap
//
//  Created by Leqi Long on 6/28/16.
//  Copyright © 2016 Student. All rights reserved.
//

import Foundation

class DataSource: NSObject{
    
    let parseClient = ParseClient.sharedClient()
    var students = [StudentLocation]()
    var user: User?
    
    override init() {
        super.init()
    }
    
    // MARK: Singleton Instance
    
    private static var sharedInstance = DataSource()
    
    class func sharedClient() -> DataSource {
        return sharedInstance
    }
}