//
//  MessageViewController.swift
//  QuppledV5
//
//  Created by Jamie Charry on 8/13/15.
//  Copyright (c) 2015 Jamie Charry. All rights reserved.
//

import UIKit
import Parse

class MessageViewController: UIViewController, UITextFieldDelegate {
    
    // Properties for both users involved in this message chain
    var todaysMatch: PFUser?
    var currentUser: PFUser!
    
    // IBOutlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageFieldBottomDistanceConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageTextField: UITextField!
    
    weak var spinner = UIActivityIndicatorView()
    
    // Model object - upon view loading, query parse for all messages matching these two users
    var allMessages = [Double : (String, String)]()     // Dict format: [Timestamp: (MessageText, "Sent or Received")]

    
    // MARK: View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set spinner location, and start spinning
        spinner?.center = self.view.center
        spinner?.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        spinner?.startAnimating()
        
        // Set title of view controller, which is presented as the Nav Bar Title
        self.title = "Messages"
        
        // Set text field delegate to handle text field methods
        messageTextField.delegate = self
        
        // Scroll view tap to be used to dismiss keyboard
        scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "scrollViewTapped:"))

        // Instantiate current user
        currentUser = PFUser.currentUser()
        
        // Get all previous messages matching the two users
        queryForMessages()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Start spinner
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func queryForMessages() {
        let query = PFQuery(className: QuppledConstants.ParseActivityClassName)
        query.whereKey("fromUser", equalTo: currentUser)
        query.whereKey("toUser", equalTo: todaysMatch!)
        
        query.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) -> Void in
            if error == nil {
                
                // Unwrap objects, then cast to PFObjects
                let actualObjects = objects! as! [PFObject]
                
                
                print("downloaded objects are \(objects)")
                for obj in actualObjects {
                    self.allMessages[obj.objectForKey(QuppledConstants.ParseActivityTimestampKey) as! Double] = ((obj.objectForKey(QuppledConstants.ParseActivityMessageTextKey) as! String), "sent")
                }
                
                // Perform second query to get recieved messages
                let secondQuery = PFQuery(className: QuppledConstants.ParseActivityClassName)
                secondQuery.whereKey("fromUser", equalTo: self.todaysMatch!)
                secondQuery.whereKey("toUser", equalTo: self.currentUser)
                
                secondQuery.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
                    if error == nil {
                        
                        // Unwrap objects, then cast to PFObject
                        let actualObjects = objects! as! [PFObject]
                        for obj in actualObjects {
                            self.allMessages[obj.objectForKey(QuppledConstants.ParseActivityTimestampKey) as! Double] = ((obj.objectForKey(QuppledConstants.ParseActivityMessageTextKey) as! String), "received")
                        }
                        self.spinner?.stopAnimating()
                        self.updateMessagesUI()
                    }
                }
                // TODO: Add a spinner earlier, stop it here once the messages have loaded
            }
        }
    }
    

    @IBAction func sendTapped(sender: UIButton) {
        
        // Get message text
        if messageTextField.text == "" {
            // TODO: Create alert
            print("No text entered")
            return
        }
        
        let messageText = messageTextField.text
        let activity = PFObject(className: QuppledConstants.ParseActivityClassName)
        let timestamp = NSDate.timeIntervalSinceReferenceDate()
        activity.setObject(currentUser, forKey: QuppledConstants.ParseActivityFromUserKey)
        activity.setObject(todaysMatch!, forKey: QuppledConstants.ParseActivityToUserKey)
        activity.setObject(messageText!, forKey: QuppledConstants.ParseActivityMessageTextKey)
        activity.setObject("message", forKey: QuppledConstants.ParseActivityTypeKey)
        activity.setObject(timestamp, forKey: QuppledConstants.ParseActivityTimestampKey)
        
        print("current user is: \(currentUser)")
        print("activity object: \(activity)")
        
        activity.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            if success {
                // TODO: figure out how to send Push notification to other user!!!
                
                // Clear out text field
                self.messageTextField.text = ""
                self.allMessages[timestamp] = (messageText!, "sent")
                self.updateMessagesUI()
                
            }
        }
        
    }
    
    func addMessageViews(messageArray: [(String, String)]) {
        
        // Message array is an array of Tuples, with the first
        // object containing the text, and the second containing
        // a string identifing if the message was sent or recieved
        // I.E. message.0 = "Message Text" and message.1 = "sent" or "received"
        
        var counter: CGFloat = 0
        var scrollViewContentHeight: CGFloat = 35.0
        
        for message in messageArray {
            // Set label properties.  Get suggested label size based on text
            // size using sizeToFit(). Then add a few points to the label so 
            // the frame of the label doesn't hug the text so much
            let messageLabel = UILabel()
            messageLabel.text = message.0
            messageLabel.textAlignment = NSTextAlignment.Center
            messageLabel.sizeToFit()
            messageLabel.frame = CGRect(x: 0, y: 0, width: messageLabel.frame.width + 10, height: messageLabel.frame.height + 5)
            messageLabel.layer.cornerRadius = 5
            messageLabel.clipsToBounds = true
            
            scrollViewContentHeight += messageLabel.frame.height + 15
            
            // If message was sent, display it on the right
            // If received, display it on the left of the screen
            if message.1 == "sent" {
                // frame should be on the right
                messageLabel.frame.origin = CGPoint(x: self.view.frame.width - messageLabel.frame.width - 10, y: 35 + (messageLabel.frame.height+10)*counter)
                messageLabel.backgroundColor = UIColor.greenColor()
            } else {
                // frame should be on the left
                messageLabel.frame.origin = CGPoint(x: 10, y: 35 + (messageLabel.frame.height+10)*counter)
                messageLabel.backgroundColor = UIColor.lightGrayColor()
            }
            
            counter++
            contentView.addSubview(messageLabel)
        }
        contentView.frame = CGRect(origin: scrollView.frame.origin, size: CGSize(width: self.view.frame.width, height: scrollViewContentHeight))
        scrollView.contentSize = CGSize(width: view.frame.width, height: contentView.frame.height)
    }
    
    func updateMessagesUI() {
        
        print("ALL MESSAGES: \(allMessages)")
        
        var timestampArray = [Double]()
        var messagesArray = [(String, String)]()
        // Sort all messages dictionary by their date keys
        for (timestamp, _) in allMessages {
            timestampArray.append(timestamp)
        }
        
        let sortedArray = timestampArray.sort {$0 < $1}
        
        for timestamp in sortedArray {
            if let message = allMessages[timestamp] {
                messagesArray.append(message)
            }
        }
        
        print("Messages in order: \(messagesArray)")
        
        addMessageViews(messagesArray)
        
    }
    
    // MARK: Text field delegate methods
    func textFieldDidBeginEditing(textField: UITextField) {
        //animate text field up
//        println("Scroll view content size is: \(scrollView.contentSize)")
//        println("Scroll view's frame size is: \(scrollView.frame.height)")
//        var bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.height)
        UIView.animateWithDuration(0.3, animations: { () -> Void in
//            self.scrollView.setContentOffset(bottomOffset, animated: true)
            self.messageFieldBottomDistanceConstraint.constant = 230
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        self.messageTextField.resignFirstResponder()
//        println("Scroll view content size is: \(scrollView.contentSize)")
//        println("Scroll view's frame size is: \(scrollView.frame.height)")
//        var bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.height)
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.messageFieldBottomDistanceConstraint.constant = 16
//            self.scrollView.setContentOffset(bottomOffset, animated: true)
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Send tapped, trigger send method
        self.sendTapped(sendButton)
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        messageTextField.endEditing(true)
    }
    
    func scrollViewTapped(sender: UIScrollView) {
        print("scroll view tapped")
        messageTextField.endEditing(true)
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
