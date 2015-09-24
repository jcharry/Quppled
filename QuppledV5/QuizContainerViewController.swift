//
//  QuizContainerViewController.swift
//  QuppledV5
//
//  Created by Jamie Charry on 7/15/15.
//  Copyright (c) 2015 Jamie Charry. All rights reserved.
//

import UIKit

class QuizContainerViewController: UIViewController {
    
    enum ViewState {
        case NewQuestionOnTop
        case AlreadyAnsweredOnTop
    }
    
    var seguedFrom: String?
    
    @IBOutlet weak var overlayToHideSegmentedController: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var alreadyAnsweredContainer: UIView!
    @IBOutlet weak var newQuestionsContainer: UIView!
    
    var currentState = ViewState.NewQuestionOnTop
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        print("Container VC was segued to from: \(seguedFrom)")
        
        segmentedControl.addTarget(self, action: "segmentedControlValueChanged:", forControlEvents: UIControlEvents.ValueChanged)
        
        // set up layout based on where segue came from
        
        // if segued from Profile Creation, hide segmented control
        // else, it should sit below segmented control
        if seguedFrom == QuppledConstants.SegueFromProfileCreation {
            overlayToHideSegmentedController.alpha = 1
        } else {
            overlayToHideSegmentedController.alpha = 0
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func segmentedControlValueChanged(sender: UISegmentedControl) {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        switch sender.selectedSegmentIndex {
        case 0:
            print("new questions segment selected")
            
            if currentState != ViewState.NewQuestionOnTop {
                // swap views & post notification
                notificationCenter.postNotificationName(QuppledConstants.NewQuestionsViewControllerBroughtToFront, object: self)
                view.sendSubviewToBack(alreadyAnsweredContainer)
                currentState = ViewState.NewQuestionOnTop
            }
        case 1:
            print("already answered segment selected")
            
            //bring already answered container to front of view hierarchy
            if currentState != ViewState.AlreadyAnsweredOnTop {
                // swap views
                notificationCenter.postNotificationName(QuppledConstants.AlreadyAnsweredViewControllerBroughtToFront, object: self)
                view.sendSubviewToBack(newQuestionsContainer)
                currentState = ViewState.AlreadyAnsweredOnTop
            }
        default: break
        }
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if let destinationVC = segue.destinationViewController as? QuizViewController {
            if segue.identifier == QuppledConstants.EmbedSegueNewQuestionsVC {
                destinationVC.seguedFrom = self.seguedFrom
            }
        }
    }

}
