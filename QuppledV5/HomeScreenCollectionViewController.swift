//
//  HomeScreenCollectionViewController.swift
//  QuppledV4
//
//  Created by Jamie Charry on 6/24/15.
//  Copyright (c) 2015 Jamie Charry. All rights reserved.
//

import UIKit
import Parse

protocol HomeScreenCollectionViewControllerDelegate {
    func toggleMenu()
}

class HomeScreenCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    private struct Constants {
        static let CellReuseIdentifier = "ProfileCell"
        static let MatchIsSetNotificationName = "todaysMatchIsSet"
        static let FetchNewUserNotificationName = "fetchNewUser"

    }
    
    var delegate: HomeScreenCollectionViewControllerDelegate?
    
    var users = [PFUser]()
    var homeScreenModel = HomeScreenModel()
    var seguedFrom: String?
    var todaysMatch: PFUser? {
        didSet {
            collectionView?.reloadData()
        }
    }
    var todaysMatchImages = [NSData]()
    var profileImage: UIImage?
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let blur = UIBlurEffect(style: .Dark)
        let visualEffectView = UIVisualEffectView(effect: blur)
        visualEffectView.frame = CGRect(origin: CGPointZero, size: CGSize(width: view.bounds.width, height: view.bounds.height + bottomLayoutGuide.length))
        
        collectionView?.subviews[0].insertSubview(visualEffectView, atIndex: 1)
        
        //TODO: Force a new fetch for now
//        let defaults = NSUserDefaults.standardUserDefaults()
//        defaults.setBool(true, forKey: QuppledConstants.NewFetchRequiredDefaultsKey)
        
        
        // Get today's match!
        homeScreenModel.getTodaysMatch()
//        if newFetchRequired == false {
//            todaysMatch = todaysMatchedUser
//        } else {
//        }
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "updateTodaysUser:", name: QuppledConstants.MatchIsSetNotificationName, object: homeScreenModel)
//        notificationCenter.addObserver(self, selector: "fetchNewUser:", name: Constants.FetchNewUserNotificationName, object: nil)


        // Uncomment the following line to preserve selection between presentations
//         self.clearsSelectionOnViewWillAppear = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if seguedFrom != nil {
            print("segued from \(seguedFrom)")
        }
        
        collectionView?.reloadData()
    }
    
    
    func updateTodaysUser(notification: NSNotification) {
        
        let userInfo = notification.userInfo as! [String: PFUser]
        todaysMatch = userInfo["todaysUser"]
                
        collectionView?.reloadData()
        
        print("todays match is: \(todaysMatch)")
    }
    
//    func fetchNewUser(notification: NSNotification) {
//        homeScreenModel.getTodaysMatch()
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func menuTapped(sender: UIBarButtonItem) {
        delegate?.toggleMenu()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //#warning Incomplete method implementation -- Return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
        return 1
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.CellReuseIdentifier, forIndexPath: indexPath) as! ProfileCollectionViewCell
    
        // Configure the cell
        if let match = todaysMatch {
            cell.user = match
        }
        return cell
    }
    
    // MARK: UICollectionFlowDelegate
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: self.view.bounds.width - 40, height: self.view.bounds.width - 40)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 30, left: 20, bottom: 70, right: 20)
    }
    
    
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        print("cell index path is : \(indexPath)")
        
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! ProfileCollectionViewCell
        self.profileImage = cell.profileImageView.image
        
        
        performSegueWithIdentifier("Show Profile View", sender: self)
    }
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if let identifier = segue.identifier {
//            if let destinationVC = segue.destinationViewController as? HomeScreenViewController {
////                destinationVC.profileImage = self.profileImage
//                destinationVC.todaysMatch = todaysMatch
//            }
//        }
//    }

}
