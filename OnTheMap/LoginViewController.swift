//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Leqi Long on 6/16/16.
//  Copyright © 2016 Student. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {

    // MARK: Properties
    let udacityClient = UdacityClient.sharedClient()
    let dataSource = DataSource.sharedClient()
    let appDelegate = AppDelegate.getDelegate()
    var keyboardOnScreen = false
    
    // MARK: Outlets
    
    @IBOutlet weak var promptToLoginLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var debugTextLabel: UILabel!
    @IBOutlet weak var udacityLogoImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var facebookLoginButton: FBSDKLoginButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate.logout()
        configureLaunchScreen()
        
        subscribeToNotification(UIKeyboardWillShowNotification, selector: #selector(keyboardWillShow))
        subscribeToNotification(UIKeyboardWillHideNotification, selector: #selector(keyboardWillHide))
        subscribeToNotification(UIKeyboardDidShowNotification, selector: #selector(keyboardDidShow))
        subscribeToNotification(UIKeyboardDidHideNotification, selector: #selector(keyboardDidHide))

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if appDelegate.getAccessToken() == nil{
            facebookLoginButton.enabled = true
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromAllNotifications()
    }
    
    //MARK: Sign up
    @IBAction func signUpButtonPressed(sender: AnyObject) {
        let signUpURL = NSURL(string: UdacityClient.UdacityConstants.SignUpURL)
        if UIApplication.sharedApplication().canOpenURL(signUpURL!){
            UIApplication.sharedApplication().openURL(signUpURL!)
        }
        
    }
    //MARK: Login
    @IBAction func loginPressed(sender: AnyObject) {
        
        userDidTapView(self)
        
        if usernameTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            alertWithError("Username or password empty")
        }else{
            activityIndicator.hidden = false
            activityIndicator.startAnimating()
            setUIEnabled(false)
            udacityClient.loginUdacity(usernameTextField.text!, password: passwordTextField.text!){(userKey, error) in
                dispatch_async(dispatch_get_main_queue()) {
                    if let userKey = userKey {
                        self.getUserDataWithUserKey(userKey)
                    } else {
                        self.alertWithError(error!.localizedDescription)
                        self.activityIndicator.hidden = true
                        self.setUIEnabled(true)
                    }
                }
            }
        }
        
    }
    
    
    private func getUserDataWithUserKey(userKey: String) {
        udacityClient.getUserData(userKey) { (user, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if let user = user {
                    self.dataSource.user = user
                    self.completeLogin()
                }else{
                    self.alertWithError(error!.localizedDescription)

                }
            }
        }
    }
    
    private func completeLogin() {
            self.setUIEnabled(true)
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("navigateToTabBarController") as! UINavigationController
            self.presentViewController(controller, animated: true, completion: nil)
    }
    
    func configureLaunchScreen(){
        activityIndicator.hidden = true
        facebookLoginButton.readPermissions = ["public_profile"]
        facebookLoginButton.delegate = self
    }
    
    // MARK: FBSDKLoginButtonDelegate Methods
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {

        usernameTextField.text! = ""
        passwordTextField.text! = ""
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        
        if error != nil{
            alertWithError(error.localizedDescription)
            return
        }else if result.isCancelled{
            dismissViewControllerAnimated(true, completion: nil)
        }else{
            if let token = result.token.tokenString {
                udacityClient.loginViaFacebook(token){(userKey, error) in
                    dispatch_async(dispatch_get_main_queue()) {
                        if let userKey = userKey {
                            self.getUserDataWithUserKey(userKey)
                        } else {
                            self.appDelegate.logout()
                            self.alertWithError(error!.localizedDescription)
                            self.activityIndicator.hidden = true
                            self.setUIEnabled(true)
                        }
                        
                    }
                    
                }
            }else{
                alertWithError(error!.localizedDescription)
            }

        }
        activityIndicator.hidden = true
    }

    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        facebookLoginButton.enabled = true
    }
    
    func loginButtonWillLogin(loginButton: FBSDKLoginButton!) -> Bool {
        if appDelegate.getAccessToken() == nil{
            usernameTextField.text! = ""
            passwordTextField.text! = ""
        }
        return true
    }
    
    
    // MARK: Show/Hide Keyboard
    
    func keyboardWillShow(notification: NSNotification) {
        if !keyboardOnScreen {
            view.frame.origin.y -= keyboardHeight(notification)
            udacityLogoImageView.hidden = true
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if keyboardOnScreen {
            view.frame.origin.y += keyboardHeight(notification)
            udacityLogoImageView.hidden = false
        }
    }
    
    func keyboardDidShow(notification: NSNotification) {
        keyboardOnScreen = true
    }
    
    func keyboardDidHide(notification: NSNotification) {
        keyboardOnScreen = false
    }
    
    private func keyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    private func resignIfFirstResponder(textField: UITextField) {
        if textField.isFirstResponder() {
            textField.resignFirstResponder()
        }
    }

    @IBAction func userDidTapView(sender: AnyObject) {
        resignIfFirstResponder(usernameTextField)
        resignIfFirstResponder(passwordTextField)
    }

}

extension LoginViewController {
    
    private func setUIEnabled(enabled: Bool) {
        usernameTextField.enabled = enabled
        passwordTextField.enabled = enabled
        loginButton.enabled = enabled
        
        // adjust login button alpha
        if enabled {
            loginButton.alpha = 1.0
        } else {
            loginButton.alpha = 0.5
        }
    }

    
    private func subscribeToNotification(notification: String, selector: Selector) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    private func unsubscribeFromAllNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
