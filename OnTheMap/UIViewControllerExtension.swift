//
//  UIViewControllerExtension.swift
//  OnTheMap
//
//  Created by Leqi Long on 6/28/16.
//  Copyright © 2016 Student. All rights reserved.
//

import Foundation

extension UIViewController{
    func alertWithError(message: String, completionHandler: ((UIAlertAction) -> Void)? = nil) {
        dispatch_async(dispatch_get_main_queue()) {
            let alert = UIAlertController(title: "", message: message, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: completionHandler))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }

}