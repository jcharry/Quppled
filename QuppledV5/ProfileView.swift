//
//  ProfileView.swift
//  QuppledV5
//
//  Created by Jamie Charry on 8/17/15.
//  Copyright (c) 2015 Jamie Charry. All rights reserved.
//

import UIKit
import Parse

@objc
protocol ProfileViewDelegate {
    optional func messageButtonTapped(sender: UIButton)
    optional func likeButtonTapped(sender: UIButton)
    optional func saveToFavoritesButtonTapped(sender: UIButton)
}

class ProfileView: UIView, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var saveToFavoritesButton: UIButton!
    @IBOutlet weak var namesLabel: UILabel!
    @IBOutlet weak var agesLabel: UILabel!
    @IBOutlet weak var occupationsLabel: UILabel!
    @IBOutlet weak var summaryTextView: UITextView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeaderLabel: UILabel!
    
    var view: UIView!
    var loadedUser: PFUser?
    var delegate: ProfileViewDelegate?
    var commonAnswers: [String]?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    // Designated initializer
    convenience init(frame: CGRect, parseUser: PFUser?) {
        // Initializes self with standard initializer
        self.init(frame: frame)
        
        // Set's up view from xib file
        xibSetup()
        
        // Set current user - which will be used to update labels
        loadedUser = parseUser
        
        // Setup properties and labels
        setupViews()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    func xibSetup() {
        view = loadViewFromNib()
        
        // Use bounds, not frame, or it'll be offset
        view.frame = bounds
        
        // Make the view stretch with the containing view
        view.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        
        // Adding custom subview to top of view hierarchy
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "ProfileView", bundle: bundle)
        let nibview = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
        return nibview
    }
    
    func setupViews() {
        
        // Set buttons to have rounded backgrounds
        messageButton.layer.cornerRadius = 20
        likeButton.layer.cornerRadius = 20
        saveToFavoritesButton.layer.cornerRadius = 20
        
        // Set labels based on user data
        if let user = loadedUser {
            namesLabel.text = "  \(user.objectForKey(QuppledConstants.ParseUserFirstPartnerNameKey)!) & \(user.objectForKey(QuppledConstants.ParseUserSecondPartnerNameKey)!)"
            agesLabel.text = "  Ages \(user.objectForKey(QuppledConstants.ParseUserFirstPartnerAgeKey)!) & \(user.objectForKey(QuppledConstants.ParseUserSecondPartnerAgeKey)!)"
            
            if let summary = user.objectForKey(QuppledConstants.ParseUserSummaryKey) as? String {
                summaryTextView.text = summary
            } else {
                summaryTextView.text = "  Look's like there's nothing here"
            }
            
            // Download profile image and set image view
            let imageFile = user.objectForKey(QuppledConstants.ParseUserProfilePhotoKey) as! PFFile
            let imageData: NSData?
            do {
                imageData = try imageFile.getData()
                profileImageView.image = UIImage(data: imageData!)
            } catch _ {
                print("something went wrong")
            }
            
            // Call the model to identify common answers
            // And display them in the table view
            commonAnswers = identifyCommonAnswers()
            tableView.reloadData()
            
        }
    }
    
    func identifyCommonAnswers() -> [String] {
        let currentUser = PFUser.currentUser()
//        _ = currentUser?.objectForKey(QuppledConstants.ParseUserAlreadyAnsweredQuestionsKey) as! [String: String]
//        _ = loadedUser?.objectForKey(QuppledConstants.ParseUserAlreadyAnsweredQuestionsKey) as! [String: String]
        
        let model = HomeScreenModel()
        model.determineMatchPercentage(loadedUser!)
        let commonAnswers = model.commonAnswers
        print("common answers are: \(commonAnswers)")
        
        return commonAnswers
        
    }
    
    
    @IBAction func messageTapped(sender: UIButton) {
        delegate?.messageButtonTapped!(sender)
    }
    @IBAction func likeTapped(sender: UIButton) {
        delegate?.likeButtonTapped!(sender)
    }
    @IBAction func saveTapped(sender: UIButton) {
        delegate?.saveToFavoritesButtonTapped!(sender)
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        tableView.registerNib(UINib(nibName: "ProfileViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "cell")
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! ProfileViewCell
        
        cell.label.text = commonAnswers![indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commonAnswers!.count
    }

}
