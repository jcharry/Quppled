//
//  ProfileCollectionViewCell.swift
//  QuppledV4
//
//  Created by Jamie Charry on 6/24/15.
//  Copyright (c) 2015 Jamie Charry. All rights reserved.
//

import UIKit
import Parse

class ProfileCollectionViewCell: UICollectionViewCell {
    
    
    // MARK: Storyboard Outlets
    // they are all initially set to empty so that no placeholder text accidentally shows up
    @IBOutlet weak var firstCommonAnswer: UILabel! { didSet {
        firstCommonAnswer.text = ""
        }
    }
    @IBOutlet weak var secondCommonAnswer: UILabel! {
        didSet {
            secondCommonAnswer.text = ""
        }
    }
    @IBOutlet weak var thirdCommonAnswer: UILabel! {
        didSet {
            thirdCommonAnswer.text = ""
        }
    }
    @IBOutlet weak var nameLabel: UILabel! {
        didSet {
            nameLabel.text = ""
        }
    }
    @IBOutlet weak var ageLabel: UILabel! {
        didSet {
            ageLabel.text = ""
        }
    }
    @IBOutlet weak var profileImageView: UIImageView! {
        didSet {
            profileImageView.layer.cornerRadius = 20
            profileImageView.clipsToBounds = true
        }
    }
    @IBOutlet weak var matchPercentLabel: UILabel! {
        didSet {
            matchPercentLabel.text = ""
        }
    }
    
    var user: PFUser? {
        didSet {
            updateUI()
            matchPercent = 0
        }
    }
    
    let homeScreenModel = HomeScreenModel()
    
    var matchPercent: Int = 0
    
    var commonAnswerBackgroundView: UIView?
    
    func updateUI() {
        if let actualUser = user {
            commonAnswerBackgroundView?.removeFromSuperview()
            commonAnswerBackgroundView = nil
            
            if let firstName = actualUser.objectForKey(QuppledConstants.ParseUserFirstPartnerNameKey) as? String, secondName = actualUser.objectForKey(QuppledConstants.ParseUserSecondPartnerNameKey) as? String, firstAge = actualUser.objectForKey(QuppledConstants.ParseUserFirstPartnerAgeKey) as? Int, secondAge = actualUser.objectForKey(QuppledConstants.ParseUserSecondPartnerAgeKey) as? Int {
                nameLabel.text = "\(firstName) & \(secondName)"
                ageLabel.text = "\(firstAge) & \(secondAge) years old"
            }
            
            if let profileImage = actualUser.objectForKey(QuppledConstants.ParseUserProfilePhotoKey) as? PFFile {
                profileImage.getDataInBackgroundWithBlock({ (data: NSData?, error: NSError?) -> Void in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.profileImageView.image = UIImage(data: data!)
                    })
                })
            }
            
            matchPercent = homeScreenModel.determineMatchPercentage(user!)
            let threeCommonAnswers = homeScreenModel.pickThreeCommonAnswers()
            matchPercentLabel.text = "\(matchPercent)%"
            
            if threeCommonAnswers.count > 2 {
                firstCommonAnswer.text = threeCommonAnswers[0]
                secondCommonAnswer.text = threeCommonAnswers[1]
                thirdCommonAnswer.text = threeCommonAnswers[2]
                firstCommonAnswer.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
                firstCommonAnswer.layer.cornerRadius = 20
                secondCommonAnswer.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
                secondCommonAnswer.layer.cornerRadius = 20
                thirdCommonAnswer.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
                thirdCommonAnswer.layer.cornerRadius = 20
            } else if threeCommonAnswers.count > 1 {
                firstCommonAnswer.text = threeCommonAnswers[0]
                secondCommonAnswer.text = threeCommonAnswers[1]
                firstCommonAnswer.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
                firstCommonAnswer.layer.cornerRadius = 20
                secondCommonAnswer.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
                secondCommonAnswer.layer.cornerRadius = 20
            } else if threeCommonAnswers.count == 1 {
                firstCommonAnswer.text = threeCommonAnswers[0]
                firstCommonAnswer.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
                firstCommonAnswer.layer.cornerRadius = 20
            } else {
                // do nothing
            }
            
//            // Get max length of three labels
//            let maxLength = max(firstCommonAnswer.bounds.width, secondCommonAnswer.bounds.width, thirdCommonAnswer.bounds.width)
//            commonAnswerBackgroundView = UIView(frame: CGRectMake(profileImageView.frame.width - maxLength, profileImageView.frame.origin.y , maxLength + 8, firstCommonAnswer.bounds.height + secondCommonAnswer.bounds.height + thirdCommonAnswer.bounds.height + 24))
//            commonAnswerBackgroundView!.backgroundColor = UIColor.blackColor()
//            commonAnswerBackgroundView!.alpha = 0.5
//            commonAnswerBackgroundView!.layer.cornerRadius = 30
//            self.insertSubview(commonAnswerBackgroundView!, belowSubview: firstCommonAnswer)
//            self.layoutIfNeeded()
            
        }
    }
    

    
    
}
