//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Leqi Long on 6/20/16.
//  Copyright © 2016 Student. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    // MARK: Properties
    private let parseClient = ParseClient.sharedClient()
    let dataSource = DataSource.sharedClient()
    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(showStudentLocations), name: "\(ParseClient.Objects.StudentLocation)\(ParseClient.Notifications.ObjectUpdated)", object: nil)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refreshStudentLocations()
    }

    
    func showStudentLocations(){
        var annotations = [MKPointAnnotation]()
        
            for location in dataSource.students {
                
                let first = location.user.firstName
                let last = location.user.lastName
                let mediaURL = location.user.url
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = location.location.coordinate
                annotation.title = "\(first) \(last)"
                annotation.subtitle = mediaURL
                
                annotations.append(annotation)
            }
 
        dispatch_async(dispatch_get_main_queue()) {
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.mapView.addAnnotations(annotations)
        }

    }

    
    // MARK: - MKMapViewDelegate
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .Red
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }

      func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            if let toOpen = NSURL(string: ((view.annotation?.subtitle)!)!) {
                if app.canOpenURL(toOpen){
                    app.openURL(toOpen)
                }else{
                    alertWithError("Cannot open URL")
                }
            }
        }
    }
    
    func refreshStudentLocations() {
        parseClient.getStudentLocations { (studentLocations, error) in
            guard error == nil else {
                self.sendDataNotification("\(ParseClient.Objects.StudentLocation)\(ParseClient.Notifications.ObjectUpdatedError)")
                dispatch_async(dispatch_get_main_queue()) {
                    self.alertWithError("Error trying to retrieve students information")
                }

                return
            }

            self.dataSource.students = studentLocations!
            self.sendDataNotification("\(ParseClient.Objects.StudentLocation)\(ParseClient.Notifications.ObjectUpdated)")
        }
    }
    
    // MARK: Notifications
    
    private func sendDataNotification(notificationName: String) {
        NSNotificationCenter.defaultCenter().postNotificationName(notificationName, object: nil)
    }

}
