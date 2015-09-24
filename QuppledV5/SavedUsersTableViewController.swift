//
//  SavedUsersTableViewController.swift
//  QuppledV5
//
//  Created by Jamie Charry on 8/18/15.
//  Copyright (c) 2015 Jamie Charry. All rights reserved.
//

import UIKit
import Parse

class SavedUsersTableViewController: UITableViewController {
    
    var currentUser: PFUser?
    var savedMatchesIdentifiers: [String]? {
        didSet {
//            reloadTableView()
        }
    }
    var allSavedUsers: [PFUser]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Saved Matches"
        
        currentUser = PFUser.currentUser()
        allSavedUsers = [PFUser]()
        
        queryForSavedMatches()
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "reloadTableView", name: QuppledConstants.SavedUsersUpdated, object: nil)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func reloadTableView() {
        
        savedMatchesIdentifiers = [String]()
        allSavedUsers = [PFUser]()
        queryForSavedMatches()
    }
    
    func queryForSavedMatches() {
        // Get saved matches
        savedMatchesIdentifiers = currentUser?.objectForKey(QuppledConstants.ParseUserSavedMatches) as? [String]
        if savedMatchesIdentifiers != nil {
            let query = PFUser.query()
            query!.whereKey("username", containedIn: savedMatchesIdentifiers!)
            query!.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) -> Void in
                if error == nil {
                    let objs = (objects as! [PFUser])
                    for obj in objs {
                        self.allSavedUsers?.append(obj)
                    }
                    self.tableView.reloadData()
                }
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if allSavedUsers != nil && allSavedUsers?.count != 0 {
            return allSavedUsers!.count
        }
        
        return 0
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("profileCell", forIndexPath: indexPath) as! SavedUsersTableViewCell

        // Configure the cell...
        if allSavedUsers != nil && allSavedUsers?.count != 0 {
            cell.user = allSavedUsers![indexPath.row]
            
            return cell
        }
            return UITableViewCell()
        
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 300
    }
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Get user
        if allSavedUsers != nil && allSavedUsers?.count != 0 {
            let userToPass = allSavedUsers![indexPath.row]
            performSegueWithIdentifier(QuppledConstants.ToProfileView, sender: userToPass)
        }
        
        // Segue
        
        
        // Pass off user to new VC
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if let dVC = segue.destinationViewController as? ProfileViewController {
            dVC.user = sender as? PFUser
        }
    }


}
