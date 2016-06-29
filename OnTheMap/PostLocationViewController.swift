//
//  PostLocationViewController.swift
//  OnTheMap
//
//  Created by Leqi Long on 6/21/16.
//  Copyright © 2016 Student. All rights reserved.
//

import UIKit
import MapKit
import Foundation

class PostLocationViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate {
    
    //MARK: outlets
    

    @IBOutlet weak var topSection: UIView!
    @IBOutlet weak var middleSection: UIView!
    @IBOutlet weak var bottomSection: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: properties
    private let parseClient = ParseClient.sharedClient()
    let dataSource = DataSource.sharedClient()

    var objectID: String? = nil
    //var area: MKCoordinateRegion?
    var placemark: CLPlacemark? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureInitialUI()
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(recognizer)
    }
    
    @IBAction func findButtonPressed(sender: AnyObject) {
        if locationTextField.text!.isEmpty{
            alertWithError("You didn't enter any location")
            return
        }
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(locationTextField.text!){ info, error in
            if let _ = error {
                self.alertWithError("Cannot find location")
                self.activityIndicator.hidden = true
            }else{
                if let locations = info as [CLPlacemark]?{
                    self.placemark = locations[0]
                    self.configureSecondUI()
                    self.mapView.showAnnotations([MKPlacemark(placemark: self.placemark!)], animated: true)
                    self.activityIndicator.hidden = true
                }
            }
        }
        
    }
    
    @IBAction func submitButtonPressed(sender: AnyObject) {
        
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        
        if urlTextField.text!.isEmpty{
            alertWithError("You haven't entered an URL yet")
            return 
        }
        
        guard let user = dataSource.user,
        let placemark = placemark,
            let mark = placemark.location else{
                alertWithError("Can't find student information and location")
                return
        }
        
        let handler: ((NSError?, String)->Void) = {(error, mediaURL) in
            if let _ = error{
                dispatch_async(dispatch_get_main_queue()) {
                    self.alertWithError("Cannot post your information. Try again later"){(alert) in
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                }
            }else{
                self.dataSource.user!.url = mediaURL
                self.parseClient.getStudentLocations{(studentLocations, error) in
                    if let _ = error{
                        dispatch_async(dispatch_get_main_queue()) {
                            self.alertWithError("Cannot post your information. Try again later"){(alert) in
                                self.dismissViewControllerAnimated(true, completion: nil)
                            }
                        }
                    }else{
                        self.dataSource.students = studentLocations!
                    }
                }
                self.dismissViewControllerAnimated(true, completion: nil)
            
            }
        
        }

        let mediaURL = urlTextField.text!.hasPrefix("https://") ? urlTextField.text! : "https://\(urlTextField.text!)"
        let location = Location(latitude: mark.coordinate.latitude, longitude: mark.coordinate.longitude, mapString: locationTextField.text!)
            
        if let objectID = objectID{
            parseClient.updateStudentLocation(objectID, url: mediaURL, location: StudentLocation(objectID: objectID, user: user, location: location)){(success, error) in
                handler(error, mediaURL)
            }
        }else{
            parseClient.addAStudentLocation(mediaURL, location: StudentLocation(objectID: "", user: user, location: location)){(success, error) in
                handler(error, mediaURL)
            }
        }
        
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func viewTapped(recognizer: UITapGestureRecognizer){
        locationTextField.resignFirstResponder()
        urlTextField.resignFirstResponder()
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        locationTextField.resignFirstResponder()
        urlTextField.resignFirstResponder()
        dismissViewControllerAnimated(true, completion: nil)
    }
    

    //MARK: Configure UI
    
    func configureInitialUI(){
        locationTextField.delegate = self
        activityIndicator.hidden = true
        urlTextField.hidden = true
        submitButton.hidden = true
        mapView.hidden = true
        findButton.layer.cornerRadius = 5
        promptLabel.text = "Where are you studying today?"
        topSection.backgroundColor = UIColor.whiteColor()
        bottomSection.backgroundColor = UIColor.whiteColor()
        middleSection.backgroundColor = UIColor(red: 0, green: 0.5333, blue: 0.8863, alpha: 1.0)
        locationTextField.textColor = UIColor.whiteColor()
        findButton.backgroundColor = UIColor(red: 0.9569, green: 0.9765, blue: 0.9765, alpha: 1.0)
    }
    
    private func configureSecondUI(){
        urlTextField.delegate = self
        mapView.delegate = self
        submitButton.hidden = false
        findButton.hidden = true
        urlTextField.hidden = false
        mapView.hidden = false
        locationTextField.hidden = true
        activityIndicator.hidden = true
        promptLabel.text = "Enter a URL to share here"
        topSection.backgroundColor = UIColor(red: 0, green: 0.5333, blue: 0.8863, alpha: 1.0)
        middleSection.backgroundColor = UIColor.clearColor()
        bottomSection.backgroundColor = UIColor.clearColor()
        promptLabel.textColor = UIColor.whiteColor()
        urlTextField.textColor = UIColor.whiteColor()
        cancelButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        submitButton.backgroundColor = UIColor(red: 0.9569, green: 0.9765, blue: 0.9765, alpha: 1.0)
    }
    
}

