//
//  ProfileViewController.swift
//  QuppledV5
//
//  Created by Jamie Charry on 7/16/15.
//  Copyright (c) 2015 Jamie Charry. All rights reserved.
//

import UIKit
import Parse

class HomeScreenViewController: UIViewController, ProfileViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    var profileView: ProfileView?
    
    // Matched user
    var todaysMatch: PFUser? {
        didSet {
            updateUI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TEST CODE: NEW FETCH REQUIRED
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(true, forKey: QuppledConstants.NewFetchRequiredDefaultsKey)
        
        // Create homescreen model isntance, and fetch user
        let homeScreenModel = HomeScreenModel()
        
        
        // Register for notification of finding today's user
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "updateTodaysUser:", name: QuppledConstants.MatchIsSetNotificationName, object: homeScreenModel)
        notificationCenter.addObserver(self, selector: "updateViewWithNoMatch", name: QuppledConstants.NoMatchNotificationName, object: homeScreenModel)
        
        homeScreenModel.getTodaysMatch()
        
        // Set title of VC for navigation controller
        self.title = "Today's Match"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        profileView?.identifyCommonAnswers()
        profileView?.tableView.reloadData()
    }
    
    func updateTodaysUser(notification: NSNotification) {
        
        let userInfo = notification.userInfo as! [String: PFUser]
        todaysMatch = userInfo["todaysUser"]
        
        print("todays match is: \(todaysMatch)")
    }
    
    func updateUI() {
        
        profileView = ProfileView(frame: CGRect(origin: scrollView.bounds.origin, size: CGSize(width: self.view.frame.width, height: 1000)), parseUser: todaysMatch!)
        if profileView != nil {
            profileView!.delegate = self
            scrollView.addSubview(profileView!)
            scrollView.contentSize = CGSize(width: self.view.frame.width, height: 1000-128)
            print("scroll view frame; \(scrollView.frame) & profileView frame: \(profileView!.frame)")
            print("scroll view bounds: \(scrollView.bounds) and scroll view bounds origin: \(scrollView.bounds.origin)")
            print("scroll view content size = \(scrollView.contentSize)")
            scrollView.layoutIfNeeded()
        }
    }
    
    func updateViewWithNoMatch() {
        let view = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        view.center = self.view.center
        view.text = "No Matches Available. Check back tomorrow as new users may have signed up!"
        self.view.addSubview(view)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Profile View Delegate Methods - handle button taps
    func messageButtonTapped(sender: UIButton) {
        print("message button ttapped")
        performSegueWithIdentifier("To Message View", sender: sender)
        
    }
    
    func saveToFavoritesButtonTapped(sender: UIButton) {
        print("save to favorite button tapped")
        
        // Get saved users array
        var arrayOfSavedMatches: [String]? = PFUser.currentUser()?.objectForKey(QuppledConstants.ParseUserSavedMatches) as? [String]
        
        // If the user doesn't have any saved matches - arrayOfSavedMatches will be nil
        // Otherwise, the user has other saved matches, so this match must be appended to that array
        if arrayOfSavedMatches != nil {
            
            // Check if user currently exists in that array
            if (arrayOfSavedMatches!).contains((todaysMatch!.username!)) {
                // Create alert saying user already saved
                self.animateableLabel("User already saved!")
            } else {
                // User has not already been saved - append user to array
                arrayOfSavedMatches!.append(todaysMatch!.username!)
                PFUser.currentUser()?.setObject(arrayOfSavedMatches!, forKey: QuppledConstants.ParseUserSavedMatches)
                PFUser.currentUser()?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                    if success == true {
                        // Save was successful
                        // Show brief alert
                        self.animateableLabel("Match Saved!")
                        let notificationCenter = NSNotificationCenter.defaultCenter()
                        notificationCenter.postNotification(NSNotification(name: QuppledConstants.SavedUsersUpdated, object: self))
                    }
                    if error != nil {
                        // TODO: Show brief alert that somethign went wrong with saving
                        self.animateableLabel("Something went wrong!")
                    }
                })
            }
            
        } else {
            // This is their first match! Create array and save to arrayOfSavedMatches
            arrayOfSavedMatches = [String]()
            arrayOfSavedMatches?.append(todaysMatch!.username!)
            PFUser.currentUser()?.setObject(arrayOfSavedMatches!, forKey: QuppledConstants.ParseUserSavedMatches)
            PFUser.currentUser()?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                if success == true {
                    // Save was successful, pop up a temporary view to let the user know
                    self.animateableLabel("Match Saved!")
                    let notificationCenter = NSNotificationCenter.defaultCenter()
                    notificationCenter.postNotification(NSNotification(name: QuppledConstants.SavedUsersUpdated, object: self))
                }
                
                if error != nil {
                    // TODO: Alert the user somethign went wrong
                    self.animateableLabel(error!.localizedDescription)
                    print(error?.localizedDescription)
                }
            })
        }
    
    }
    
    func likeButtonTapped(sender: UIButton) {
        print("like button tapped")
        
    }
    
    // MARK: - Helper Functions
    func createAlert(title: String, message: String, actionTitle: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: UIAlertActionStyle.Cancel, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func animateableLabel(text: String) {
        let alertLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
        alertLabel.center = self.view.center
        alertLabel.alpha = 0
        alertLabel.text = text
        alertLabel.textAlignment = NSTextAlignment.Center
        alertLabel.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.8)
        alertLabel.layer.cornerRadius = 20
        alertLabel.clipsToBounds = true
        self.view.addSubview(alertLabel)
        UIView.animateWithDuration(1, delay: 0.5, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: { () -> Void in
            alertLabel.alpha = 1
            self.view.layoutIfNeeded()
            }, completion: { (success: Bool) -> Void in
                if success == true {
                    UIView.animateWithDuration(0.3, delay: 1, options: [], animations: { () -> Void in
                        alertLabel.alpha = 0
                        self.view.layoutIfNeeded()
                        
                        }, completion: nil)
                }
        })
    }

    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let dVC = segue.destinationViewController as? MessageViewController {
            dVC.todaysMatch = self.todaysMatch
        }
    }


}
