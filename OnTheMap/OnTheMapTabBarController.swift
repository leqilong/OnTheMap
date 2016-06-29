//
//  OnTheMapTabBarController.swift
//  OnTheMap
//
//  Created by Leqi Long on 6/21/16.
//  Copyright © 2016 Student. All rights reserved.
//

import UIKit

class OnTheMapTabBarController: UITabBarController{
    
    private let udacityClient = UdacityClient.sharedClient()
    private let parseClient = ParseClient.sharedClient()
    let appDelegate = AppDelegate.getDelegate()
    let dataSource = DataSource.sharedClient()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()

    }
    
    //MARK: Add new location
    
    func pinPressed(){
        if let user = dataSource.user{
            parseClient.getAStudentLocation(user.key){(studentLocation, error) in
                dispatch_async(dispatch_get_main_queue()) {
                    if let studentLocation = studentLocation{
                        self.overwriteAlert{(alert) in
                            self.showPostLocationViewController(studentLocation.objectId)
                        }
                    }else{
                        self.showPostLocationViewController()
                    }
                }
            }
        }
    }

    // MARK: Refresh Student Locations
    
    func updateStudentLocations() {
        parseClient.getStudentLocations{ (studentLocations, error) in
            if let _ = error {
                self.sendDataNotification("\(ParseClient.Objects.StudentLocation)\(ParseClient.Notifications.ObjectUpdatedError)")
                dispatch_async(dispatch_get_main_queue()) {
                    self.displayError("Cannot refresh at this moment. Try again later")
                }

            } else {
                self.dataSource.students = studentLocations!
                self.sendDataNotification("\(ParseClient.Objects.StudentLocation)\(ParseClient.Notifications.ObjectUpdated)")
            }
        }
    }
    
    // MARK: Log out
    
    func logoutButtonPressed(){
        udacityClient.deleteUdacitySession{(success, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if let _ = error{
                    self.displayError("Unable to log out")
                }else{
                    FBSDKLoginManager().logOut()
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }
        }
    }
    
    func configureUI(){
        let logoutImageName = "logout.png"
        let logoutButton = UIButton(type: .Custom)
        logoutButton.setImage(UIImage(named: logoutImageName), forState: UIControlState.Normal)
        logoutButton.addTarget(self, action: #selector(logoutButtonPressed), forControlEvents: UIControlEvents.TouchUpInside)
        logoutButton.frame = CGRectMake(0, 0, 20, 20)
        let logoutBarButton = UIBarButtonItem(customView: logoutButton)
        self.navigationItem.leftBarButtonItem = logoutBarButton
        
        let refreshImageName = "refresh.png"
        let refreshButton = UIButton(type: .Custom)
        refreshButton.setImage(UIImage(named: refreshImageName), forState: UIControlState.Normal)
        refreshButton.addTarget(self, action: #selector(updateStudentLocations), forControlEvents: UIControlEvents.TouchUpInside)
        refreshButton.frame = CGRectMake(CGFloat(view.frame.maxX - 20), 0, 20, 20)
        let refreshBarButton = UIBarButtonItem(customView: refreshButton)
        
        let pinImageName = "pin.png"
        let pinButton = UIButton(type: .Custom)
        pinButton.setImage(UIImage(named: pinImageName), forState: UIControlState.Normal)
        pinButton.addTarget(self, action: #selector(pinPressed), forControlEvents: UIControlEvents.TouchUpInside)
        pinButton.frame = CGRectMake(view.frame.maxX, 0, 20, 20)
        let pinBarButton = UIBarButtonItem(customView: pinButton)
        
        self.navigationItem.setRightBarButtonItems([pinBarButton, refreshBarButton], animated: true)
        self.navigationItem.title = "On the Map"

    }
    
    func overwriteAlert(completionHanlder: ((UIAlertAction) -> Void)? = nil){
        let alertView = UIAlertController(title: "Overwrite Location?", message: "You are already on the map, would you like to overwrite the location?", preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "Overwrite", style: .Default, handler: completionHanlder))
        alertView.addAction(UIAlertAction(title:"Cancel", style: .Cancel, handler: nil))
        self.presentViewController(alertView, animated: true, completion: nil)

    }
    
    func displayError(message: String){
        let alertView = UIAlertController(title: "Refresh", message: message, preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil))
        self.presentViewController(alertView, animated: true, completion: nil)
    }
    
    func showPostLocationViewController(objectID: String? = nil){
        let ViewController = self.storyboard?.instantiateViewControllerWithIdentifier("postLocation") as! PostLocationViewController
        if let objectID = objectID{
            ViewController.objectID = objectID
         }
        self.presentViewController(ViewController, animated: true, completion: nil)
    }
    
    //MARK: Notification
    func sendDataNotification(notificationName: String) {
        NSNotificationCenter.defaultCenter().postNotificationName(notificationName, object: nil)
    }

    
}
