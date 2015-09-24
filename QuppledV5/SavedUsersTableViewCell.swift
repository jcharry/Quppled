//
//  SavedUsersTableViewCell.swift
//  QuppledV5
//
//  Created by Jamie Charry on 8/19/15.
//  Copyright (c) 2015 Jamie Charry. All rights reserved.
//

import UIKit
import Parse

class SavedUsersTableViewCell: UITableViewCell {
    
    var user: PFUser? {
        didSet {
            updateUI()
        }
    }

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var namesLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    
    func updateUI() {
        if let actualUser = user {
            let imageFile = user?.objectForKey(QuppledConstants.ParseUserProfilePhotoKey) as! PFFile
            
            //FIXME: this *should* happen asychronously, but for now just do it on the main thread
            let imageData: NSData?
            
            do {
                imageData = try imageFile.getData()
                profileImageView.image = UIImage(data: imageData!)
            } catch _ {
                imageData = nil
            }
            

            // Set images and labels
            namesLabel.text = "\(actualUser.objectForKey(QuppledConstants.ParseUserFirstPartnerNameKey)!) & \(actualUser.objectForKey(QuppledConstants.ParseUserSecondPartnerNameKey)!)"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
