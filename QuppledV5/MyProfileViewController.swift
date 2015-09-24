//
//  MyProfileViewController.swift
//  QuppledV5
//
//  Created by Jamie Charry on 8/18/15.
//  Copyright (c) 2015 Jamie Charry. All rights reserved.
//

import UIKit
import Parse

class MyProfileViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    var profileView: ProfileView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileView = ProfileView(frame: CGRect(origin: CGPoint(x: 0, y: -64), size: CGSize(width: self.view.frame.width, height: 1000)), parseUser: PFUser.currentUser())
        if profileView != nil {
            profileView?.backgroundColor = UIColor.greenColor()
            profileView!.tableViewHeaderLabel.text = "My Answers"
            profileView!.messageButton.hidden = true
            profileView!.likeButton.hidden = true
            profileView!.saveToFavoritesButton.hidden = true
            scrollView.contentSize = CGSize(width: self.view.frame.width, height: 1000-128)
            scrollView.addSubview(profileView!)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func editTapped(sender: UIBarButtonItem) {
        performSegueWithIdentifier(QuppledConstants.ToProfileEdit, sender: self)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
