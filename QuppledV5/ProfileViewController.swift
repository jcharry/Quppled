//
//  ProfileViewController.swift
//  QuppledV5
//
//  Created by Jamie Charry on 8/19/15.
//  Copyright (c) 2015 Jamie Charry. All rights reserved.
//

import UIKit
import Parse

class ProfileViewController: UIViewController, ProfileViewDelegate {
    
    var user: PFUser?

    @IBOutlet weak var scrollView: UIScrollView!
    var profileView: ProfileView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateUI() {
        
        profileView = ProfileView(frame: CGRect(origin: scrollView.bounds.origin, size: CGSize(width: self.view.frame.width, height: 1000)), parseUser: user!)
        if profileView != nil {
            
            // Hide unneccesary buttons
            profileView!.saveToFavoritesButton.hidden = true
            profileView!.likeButton.hidden = true
            
            profileView!.delegate = self
            scrollView.addSubview(profileView!)
            scrollView.contentSize = CGSize(width: self.view.frame.width, height: 1000-128)
            print("scroll view frame; \(scrollView.frame) & profileView frame: \(profileView!.frame)")
            print("scroll view bounds: \(scrollView.bounds) and scroll view bounds origin: \(scrollView.bounds.origin)")
            print("scroll view content size = \(scrollView.contentSize)")
            scrollView.layoutIfNeeded()
        }
    }
    
    func messageButtonTapped(sender: UIButton) {
        print("messageButtonTapped")
        performSegueWithIdentifier("To Message View", sender: self)
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let dVC = segue.destinationViewController as? MessageViewController {
            dVC.todaysMatch = self.user!
        }

    }


}
