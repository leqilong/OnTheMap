//
//  StudentsListTableViewController.swift
//  OnTheMap
//
//  Created by Leqi Long on 6/21/16.
//  Copyright © 2016 Student. All rights reserved.
//

import UIKit

class StudentsListTableViewController: UITableViewController{

    
    //MARK: properties
    private let parseClient = ParseClient.sharedClient()
    let dataSource = DataSource.sharedClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(refreshStudentsList), name: "\(ParseClient.Objects.StudentLocation)\(ParseClient.Notifications.ObjectUpdatedError)", object: nil)
        
    }
    
    func refreshStudentsList(){
        tableView.reloadData()
    }


    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.students.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        /* Get cell type */
        let cellReuseIdentifier = "studentCell"
        let student = dataSource.students[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as! StudentTableViewCell
        
        /* Set cell defaults */
        let first = student.user.firstName
        let last = student.user.lastName
        cell.studentNameLabel.text = "\(first) \(last)"
        
        return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let studentMediaURL = dataSource.students[indexPath.row].user.url
        
        if let url = NSURL(string: studentMediaURL) {
            if UIApplication.sharedApplication().canOpenURL(url) {
                UIApplication.sharedApplication().openURL(url)
            } else {
                displayError("Can't open url")
            }
        }
    }
    
    // MARK: Notifications
    
    private func sendDataNotification(notificationName: String) {
        NSNotificationCenter.defaultCenter().postNotificationName(notificationName, object: nil)
    }
    
    
    // MARK: Alert
    private func displayError(message: String) {
        let alertView = UIAlertController(title: "", message: message, preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil))
        self.presentViewController(alertView, animated: true, completion: nil)
    }



    
}
