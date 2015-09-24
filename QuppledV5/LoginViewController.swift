//
//  LoginViewController.swift
//  QuppledV4
//
//  Created by Jamie Charry on 6/16/15.
//  Copyright (c) 2015 Jamie Charry. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate {
        
    @IBOutlet weak var loginView: UIView! {
        didSet {
            loginView.alpha = 0
        }
    }
    @IBOutlet weak var signupView: UIView! {
        didSet {
            signupView.alpha = 0
        }
    }
    @IBOutlet weak var signupEmailTextField: UITextField! { didSet { signupEmailTextField.delegate = self } }
    @IBOutlet weak var signupPasswordTextField: UITextField! { didSet { signupPasswordTextField.delegate = self } }
    @IBOutlet weak var signupRepeatPasswordTextField: UITextField! { didSet { signupRepeatPasswordTextField.delegate = self } }
    @IBOutlet weak var loginEmailTextField: UITextField! { didSet { loginEmailTextField.delegate = self } }
    @IBOutlet weak var loginPasswordTextField: UITextField! { didSet { loginPasswordTextField.delegate = self } }
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Example of calling cloud code from Parse
        PFCloud.callFunctionInBackground("hello", withParameters: nil) { (result:AnyObject?, error:NSError?) -> Void in
            let response = result as? String
            print(response)
        }
        
        let firstLaunch = defaults.boolForKey(QuppledConstants.FirstLaunchDefaultsKey)
        if firstLaunch != true {
            // this is the first launch, show the welcome screen
        } else if firstLaunch {
            // not the first launch, hide the welcome scroll view
        }
        
        // First launch is over, set launched flag to true
        defaults.setBool(true, forKey: QuppledConstants.FirstLaunchDefaultsKey)
//        defaults.setBool(true, forKey: Constants.NewFetchRequiredDefaultsKey)
        
        loginEmailTextField.attributedPlaceholder = NSAttributedString(string: "email", attributes: [NSForegroundColorAttributeName:UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5)])
        loginPasswordTextField.attributedPlaceholder = NSAttributedString(string: "password", attributes: [NSForegroundColorAttributeName:UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5)])
        
        // Do any additional setup after loading the view.
        UIView.animateWithDuration(1.0) {
            self.loginView.alpha = 1
        }
//        signupTextFieldCenterPositionConstraint.constant = -30
        
        signupView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismissKeyboard"))
        loginView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismissKeyboard"))
        
        let session = PFSession()
        print(session.sessionToken)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Button Taps
    @IBAction func loginTapped(sender: UIButton) {
        PFUser.logInWithUsernameInBackground(loginEmailTextField.text!, password: loginPasswordTextField.text!) { (user: PFUser?, error: NSError?) -> Void in
            if error != nil {
                NSLog(error!.localizedDescription)
                self.createAlert("Incorrect Username or Password", message: "Re-enter credentials", actionTitle: "Continue")
            } else {
                print("logged in")
                // segue to home screen
                // Because the homescreen is in a container view, present the container view, not the home screen
//                let containerViewController = ContainerViewController()
//                self.presentViewController(containerViewController, animated: true, completion: nil)
                self.performSegueWithIdentifier(QuppledConstants.ToHomeScreenSegue, sender: sender)
            }
        }
    }

    @IBAction func dontHaveAccountTapped(sender: UIButton) {
        UIView.animateWithDuration(1.0) {
            self.loginView.alpha = 0
            self.signupView.alpha = 1
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func letsGetStartedTapped(sender: UIButton) {
        UIView.animateWithDuration(1.0) {
            self.pageControl.alpha = 0
            self.view.layoutIfNeeded()
            
        }
    }
    @IBAction func cancelSignupTapped(sender: UIButton) {
        
        UIView.animateWithDuration(1.0) {
            self.signupView.alpha = 0
            self.loginView.alpha = 1
            self.view.layoutIfNeeded()
        }
        
    }
    

    @IBAction func signupTapped(sender: UIButton) {
        let user = PFUser()
        
        if signupPasswordTextField.text == signupRepeatPasswordTextField.text {
        
            if signupEmailTextField.text != "" && signupPasswordTextField.text != "" && signupRepeatPasswordTextField.text != "" {
                // All fields contain text
                user.username = signupEmailTextField.text
                user.password = signupPasswordTextField.text
                user.email = signupEmailTextField.text
                user.signUpInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                    if error != nil {
                        NSLog(error!.localizedDescription)
                        self.createAlert("Invalid Email Address", message: "Ensure your email is entered correctly.  Otherwise the email may already be in use.", actionTitle: "Cancel")
                    } else {
                        print("signup was a success!")
                        // Now we can segue...but we shoudl segue from code, probably...
                        self.performSegueWithIdentifier(QuppledConstants.ToProfileCreationSegue, sender: self)
                    }
                })
            } else {
                createAlert("Please enter all fields", message: "", actionTitle: "Cancel")
            }
        } else {
            createAlert("Passwords don't match.", message: "Please re-enter passwords", actionTitle: "Cancel")
            signupPasswordTextField.text = ""
            signupRepeatPasswordTextField.text = ""
            signupPasswordTextField.placeholder = "Password"
            signupRepeatPasswordTextField.placeholder = "Repeat Password"
        }
        
    }
    
    
//    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
//        if identifier == QuppledConstants.ToProfileCreationSegue {
//            println("segueing to profile creation view")
//            return true
//            
//        } else if identifier == QuppledConstants.ToHomeScreenSegue {
//            println("segueing to home screen")
//            return true
//        }
//        return false
//    }
    
    // MARK: - Text Field Delegate Methods
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    func dismissKeyboard() {
        print("tapped")
        //Resign first responder on all text fields?
        signupEmailTextField.resignFirstResponder()
        signupPasswordTextField.resignFirstResponder()
        signupRepeatPasswordTextField.resignFirstResponder()
        loginEmailTextField.resignFirstResponder()
        loginPasswordTextField.resignFirstResponder()
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if let identifier = segue.identifier {
            if let tabBarController = sender?.destinationViewController as? UITabBarController {
                (tabBarController.viewControllers?.first as! HomeScreenCollectionViewController).seguedFrom = identifier
            }
        }
    }

    
    // MARK: - Helper Functions
    func createAlert(title: String, message: String, actionTitle: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: UIAlertActionStyle.Cancel, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }

}
