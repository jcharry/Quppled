//
//  ProfileCreationViewController.swift
//  QuppledV4
//
//  Created by Jamie Charry on 6/17/15.
//  Copyright (c) 2015 Jamie Charry. All rights reserved.
//

import UIKit
import Parse
import CoreLocation

class ProfileCreationViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, CLLocationManagerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let defaults = NSUserDefaults.standardUserDefaults()

    var contentView: UIView!
    var scrollView: UIScrollView!
    
    var firstPartnerNameTextField: UITextField!
    var firstPartnerAgeTextField: UITextField!
    var secondPartnerNameTextField: UITextField!
    var secondPartnerAgeTextField: UITextField!
    
    var continueButton: UIButton!
    var takePhotoButton: UIButton!
    var uploadPhotoButton: UIButton!
    
    let locationManager = CLLocationManager()
    
    var profileImageView: UIImageView! {
        didSet {
            profileImageView.layer.cornerRadius = 20
            profileImageView.clipsToBounds = true
        }
    }
    
    var locationPicker: UIPickerView?
    let pickerLocations = ["Manhattan","Westchester","Brooklyn","Queens","Staten Island"]
    
    var imageData: NSData?
    var imageFile: PFFile?
    
    var currentUser: PFUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Ask for permission to use their location
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        // Check defaults to check if a new fetch is required. If a user is creating a new profile
        // from a phone that already has the app, then we need to ensure they get a new fetch, not the stored user
        
        defaults.setBool(true, forKey: QuppledConstants.NewFetchRequiredDefaultsKey)
        
        
        // Set up view heirarchy
        scrollView = UIScrollView(frame: self.view.frame)
        contentView = UIView(frame: CGRect(origin: self.view.frame.origin, size: CGSize(width: self.view.frame.width, height: self.view.frame.height*2)))
        contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismissKeyboard"))
        
        setUpTextFields()
        setUpImageView()
        setUpPickerView()
        setUpButtons()
        
        scrollView.contentSize = contentView.frame.size
        
        scrollView.addSubview(contentView)
        view.addSubview(scrollView)
        
        
        // Get current user
        if let pfuser = PFUser.currentUser() {
            currentUser = pfuser
            print("current user is: \(currentUser!.username)")
        } else {
            NSLog("coudln't find a current user")
        }
    }
    
    func setUpImageView() {
        profileImageView = UIImageView(frame: CGRect(x: 30, y: 44, width: 150, height: 150))
        profileImageView.backgroundColor = UIColor.blueColor()
        contentView.addSubview(profileImageView)
    }
    
    func setUpButtons() {
        takePhotoButton = UIButton(type: .Custom)
        takePhotoButton.setTitle("Take Photo", forState: .Normal)
        takePhotoButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        takePhotoButton.frame = CGRect(x: 30, y: 202, width: 58, height: 26)
        takePhotoButton.addTarget(self, action: "takePhotoTapped", forControlEvents: UIControlEvents.TouchUpInside)
        takePhotoButton.titleLabel?.textAlignment = NSTextAlignment.Center
        takePhotoButton.titleLabel?.font = UIFont(name: "Palatino", size: 10)
        
        uploadPhotoButton = UIButton(type: .Custom)
        uploadPhotoButton.setTitle("Upload Photo", forState: .Normal)
        uploadPhotoButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
        uploadPhotoButton.frame = CGRect(x: 109, y: 202, width: 71, height: 26)
        uploadPhotoButton.addTarget(self, action: "uploadPhotoTapped", forControlEvents: UIControlEvents.TouchUpInside)
        uploadPhotoButton.titleLabel?.textAlignment = NSTextAlignment.Center
        uploadPhotoButton.titleLabel?.font = UIFont(name: "Palatino", size: 10)
        
        continueButton = UIButton(type: UIButtonType.Custom)
        continueButton.setTitle("Save & Continue", forState: UIControlState.Normal)
        continueButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
        continueButton.frame = CGRect(x: self.view.frame.width/2, y: locationPicker!.frame.origin.y + locationPicker!.frame.height + 20, width: 114, height: 44)
        continueButton.center.x = self.view.center.x
        continueButton.addTarget(self, action: "continueTapped", forControlEvents: UIControlEvents.TouchUpInside)
        continueButton.titleLabel?.font = UIFont(name: "Palatino", size: 12)
        
        contentView.addSubview(continueButton)
        contentView.addSubview(takePhotoButton)
        contentView.addSubview(uploadPhotoButton)
    }
    
    func setUpTextFields() {
        // create and format all text fields
        firstPartnerAgeTextField = UITextField()
        secondPartnerAgeTextField = UITextField()
        firstPartnerNameTextField = UITextField()
        secondPartnerNameTextField = UITextField()
        
        setTextFieldParams(firstPartnerNameTextField, x: 0, y: 279, placeHolderText: "First Partner Name", keyboardType: "Name")
        setTextFieldParams(firstPartnerAgeTextField, x: 0, y: 331, placeHolderText: "First Partner Age", keyboardType: "Age")
        setTextFieldParams(secondPartnerNameTextField, x: 0, y: 448, placeHolderText: "Second Partner Name", keyboardType: "Name")
        setTextFieldParams(secondPartnerAgeTextField, x: 0, y: 500, placeHolderText: "Second Partner Age", keyboardType: "Age")
    }
    
    func setTextFieldParams(textField: UITextField, x: CGFloat, y: CGFloat, placeHolderText: String, keyboardType: String) {
        // set frame, text properties, delegate, and add to superview
        textField.frame = CGRect(x: x, y: y, width: self.view.frame.width, height: 44)
        textField.textAlignment = NSTextAlignment.Center
        textField.placeholder = placeHolderText
        textField.delegate = self
        
        if keyboardType == "Age" {
            textField.keyboardType = UIKeyboardType.NumberPad
        }
        contentView.addSubview(textField)
    }
    
    func setUpPickerView() {
        locationPicker = UIPickerView(frame: CGRect(x: 0, y: 591, width: self.view.frame.width, height: 20))
        locationPicker?.delegate = self
        locationPicker?.dataSource = self
        contentView.addSubview(locationPicker!)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dismissKeyboard() {
        // resign first responder on all text fields
        firstPartnerAgeTextField.resignFirstResponder()
        firstPartnerNameTextField.resignFirstResponder()
        secondPartnerAgeTextField.resignFirstResponder()
        secondPartnerNameTextField.resignFirstResponder()
    }
        
    func continueTapped() {
        if firstPartnerNameTextField.text != "" && firstPartnerAgeTextField.text != "" && secondPartnerNameTextField.text != "" && secondPartnerAgeTextField.text != "" {
            
            if let firstAge = NSNumberFormatter().numberFromString(firstPartnerAgeTextField.text!) {
                if let secondAge = NSNumberFormatter().numberFromString(secondPartnerAgeTextField.text!) {
                    
                    if imageFile != nil {
                        saveUserInfo(firstAge: Int(firstAge), secondAge: Int(secondAge), firstName: firstPartnerNameTextField.text!, secondName: secondPartnerNameTextField.text!)
                        
                        // instantiate quiz VC and segue
                        let quizVC = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier(QuppledConstants.QuizViewControllerStoryboardID) as! QuizViewController
                        quizVC.seguedFrom = "From Profile Creation"
                        presentViewController(quizVC, animated: true, completion: nil)
                        
//                        performSegueWithIdentifier(Constants.SegueFromProfileCreation, sender: sender)
                    } else {
                        createAlert("We really need you to upload a profile photo", message: "", actionTitle: "Cancel")
                    }
                }
                
            } else {
                createAlert("We know you're probably timeless and all.  But...", message: "Please enter a number for your age", actionTitle: "Cancel")
                firstPartnerAgeTextField.text = ""
                secondPartnerAgeTextField.text = ""
            }
            
        } else {
            createAlert("Please fill out all fields", message: "We need this information to continue", actionTitle: "Cancel")
        }
    }
    
    func saveUserInfo(firstAge firstAge: Int, secondAge: Int, firstName: String, secondName: String) {
        currentUser?.setObject(imageFile!, forKey: ParseKeys.ParseUserProfilePhotoKey)
        currentUser?.setObject(firstAge, forKey: ParseKeys.ParseUserFirstPartnerAgeKey)
        currentUser?.setObject(secondAge, forKey: ParseKeys.ParseUserSecondPartnerAgeKey)
        currentUser?.setObject(firstName, forKey: ParseKeys.ParseUserFirstPartnerNameKey)
        currentUser?.setObject(secondName, forKey: ParseKeys.ParseUserSecondPartnerNameKey)
        
        currentUser?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
            if error != nil {
                NSLog(error!.localizedDescription)
            }
            if success == true {
                // info uploaded successfully, present next screen
            }
        })
    }
    
    // MARK: - Camera Methods & Image Picker Delegate Methods
    func takePhotoTapped() {
        // Take a photo using the camera
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            
            // Device has a camera, now create the image picker controller
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
            imagePicker.allowsEditing = false
            
            presentViewController(imagePicker, animated: true, completion: nil)
            
        }
    }
    
    
    
    func uploadPhotoTapped() {
        // load a photo from camera roll
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum) {
            
            // Device has a camera, now create the image picker controller
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
            imagePicker.allowsEditing = true
            
            presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let imagePicked = info[UIImagePickerControllerEditedImage] as! UIImage
        profileImageView.image = imagePicked
        imageData = UIImageJPEGRepresentation(imagePicked, 0.8)
        if imageData != nil {
            imageFile = PFFile(name: "profile_photo.jpg", data: imageData!)
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if let destinationVC = segue.destinationViewController as? QuizContainerViewController {
            if let identifier = segue.identifier {
                destinationVC.seguedFrom = identifier
            }
        }
    }
    
    // MARK: - Helper Functions
    func createAlert(title: String, message: String, actionTitle: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: UIAlertActionStyle.Cancel, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: - Text Field Delegate Method
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    // MARK: - UIPickerView Delegate & Data Source
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerLocations.count
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerLocations[row]
    }
    
    // MARK: CLLocation Delegate Method
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
    }

}
//
//extension UIImage {
//    class func resizeImage(image:UIImage,
//}
