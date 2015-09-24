//
//  QuizViewController.swift
//  QuppledV4
//
//  Created by Jamie Charry on 6/17/15.
//  Copyright (c) 2015 Jamie Charry. All rights reserved.
//

import UIKit
import Parse

class QuizViewController: UIViewController {
    
    private struct ButtonConstants {
        static let AnswerButtonColor = UIColor(red: 107/255, green: 192/255, blue: 127/255, alpha: 1.0)
        static let ButtonCornerRadius: CGFloat = 50
    }
    
    // MARK: - Properties for Quiz View
    
    var questions = [Question()]
    let model = QuestionModel()
    var currentQuestion = Question()
    var seguedFrom: String?
    
    var currentUser: PFUser?
    var questionsAnswered: [String:String]?
    let NumberOfIntialQuestionsAsked = 10
    
    // MARK: - Storyboard Outlets
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var continueOverlayView: UIView!
    @IBOutlet weak var continueOverlayLabelTop: UILabel!
    @IBOutlet weak var continueOverlayMiddleLabel: UILabel!
    @IBOutlet weak var continueOverlayLabelBottom: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var topQuestionView: UIView! {
        didSet {
            topQuestionView.layer.cornerRadius = ButtonConstants.ButtonCornerRadius
            topQuestionView.backgroundColor = ButtonConstants.AnswerButtonColor
            topQuestionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "answerChosen:"))
        }
    }
    @IBOutlet weak var bottomQuestionView: UIView! {
        didSet {
            bottomQuestionView.layer.cornerRadius = ButtonConstants.ButtonCornerRadius
            bottomQuestionView.backgroundColor = ButtonConstants.AnswerButtonColor
            bottomQuestionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "answerChosen:"))
        }
    }
    @IBOutlet weak var bottomAnswerLabel: UILabel! { didSet {
//            bottomAnswerLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "answerChosen:")) 
        }
    }
    @IBOutlet weak var topAnswerLabel: UILabel! { didSet {
//            topAnswerLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "answerChosen:")) 
        }
    }
    
    // MARK: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("segue identifier is \(seguedFrom)")

        // Get current user and identify what questions have already been answered
        if let pfuser = PFUser.currentUser() {
            currentUser = pfuser
        } else {
            NSLog("coudln't find a current user")
        }
    
        // If screen was loaded from profile creation, show the tutorial overlay.
        // To identify if the VC was loaded form the creation view, we need to access the parent
        
        if seguedFrom == QuppledConstants.SegueFromProfileCreation {
            overlayView.alpha = 1.0
            continueOverlayView.alpha = 0
            continueOverlayLabelTop.text = "I know these may seem silly..."
            continueOverlayMiddleLabel.text = "But these questions will help us ensure you get great matches."
            continueOverlayLabelBottom.text = "After all, we believe that long lasting friendships are built on common interests and values."
            questions = model.getQuestions(questionsAlreadyAnswered: questionsAnswered!, removeQuestions: false)
        }
        // If the quiz view was accessed via tab bar
        // ensure the overlay labels say the right thing,
        // and fetch the questions that user has already answered
        else {
            questionsAnswered = currentUser?.objectForKey(QuppledConstants.ParseUserAlreadyAnsweredQuestionsKey) as? [String : String]
            if questionsAnswered != nil {
                questions = model.getQuestions(questionsAlreadyAnswered: questionsAnswered!, removeQuestions: true)
            } else {
                questionsAnswered = [String: String]()
                questions = model.getQuestions(questionsAlreadyAnswered: [String: String](), removeQuestions: false)
            }
            
            overlayView.alpha = 0
            continueOverlayView.alpha = 0
            continueOverlayLabelTop.text = ""
            continueOverlayMiddleLabel.text = "You've gone through all our questions!  Check back soon, as we'll be adding more."
            continueOverlayLabelBottom.text = ""
            continueButton.removeFromSuperview()
        }
        
        // pass the array of questions that have already been answered into getQuestions method
        // If there aren't any more questions to answer, then pop up the continue overlay to dismiss the 
        // quiz view
        currentQuestionIndex = 0
        if questions.count != 0 {
            currentQuestion = questions[currentQuestionIndex]
            topAnswerLabel.text = currentQuestion.answers[0]
            bottomAnswerLabel.text = currentQuestion.answers[1]
        } else {
            continueOverlayView.alpha = 1.0
        }
        
        
        // Register for notification from segmented selector
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "newQuestionsBroughtToFront", name: QuppledConstants.NewQuestionsViewControllerBroughtToFront, object: nil)
    }
    
    // FIXME: Answers are only saved when the view disappears
    // This could cause weird issues if the user closes the app after answering questions but without switching views
    
    func newQuestionsBroughtToFront() {
        print("New questions VC was brought to the foreground.  Update if needed!")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // save object in background
        currentUser?.setObject(questionsAnswered!, forKey: QuppledConstants.ParseUserAlreadyAnsweredQuestionsKey)
        currentUser?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
            if error != nil {
                NSLog(error!.localizedDescription)
            } else {
                print("answers saved")
                // success!
            }
        })

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func dismissOverlay(sender: UIButton) {
        UIView.animateWithDuration(1.0) {
            self.overlayView.alpha = 0
            self.topAnswerLabel.text = self.questions[0].answers[0]
            self.bottomAnswerLabel.text = self.questions[0].answers[1]
        }
    }
    
    
    @IBAction func continueToHomeScreen(sender: UIButton) {
        
//        // Save question array to user database!!!
//        currentUser?.setObject(questionsAnswered, forKey: Constants.ParseAlreadyAnsweredQuestionsKey)
//        currentUser?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
//            if error != nil {
//                NSLog(error!.localizedDescription)
//            } else {
//                // success!
//            }
//        })
        
        if seguedFrom == QuppledConstants.SegueFromProfileCreation {
            
            let homeScreenVC = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("Main Tab Bar Controller") as! UITabBarController
            
            showViewController(homeScreenVC, sender: self)
        }
    }
    
    var currentQuestionIndex = 0
    func answerChosen(sender: UIGestureRecognizer) {
        
        // If user comes to quiz screen from Profile Creation Screen...
        // Force them to answer the first 10 questions, and show overlays
        // Otherwise, operate quiz view as normal
        
        if let viewThatWasTapped = sender.view {
            // When the user taps a label...
            
            // Get label inside view
            let label = viewThatWasTapped.subviews[0] as! UILabel
            
            // Get text from label
            let chosenAnswer = label.text
            
            // Save answer into answers dict
            questionsAnswered![currentQuestion.questionNumber] = chosenAnswer
//            println(questionsAnswered["\(currentQuestion.questionNumber)"])
            
            // Check if we need to end the quiz because it's the first time going through it
            if seguedFrom == QuppledConstants.SegueFromProfileCreation {
                if currentQuestionIndex >= NumberOfIntialQuestionsAsked {
                    print("we're done! No more questions to ask")
                    UIView.animateWithDuration(1.0) {
                        self.continueOverlayView.alpha = 1.0
                        self.view.layoutIfNeeded()
                    }
                } else {
                    updateLabels(viewThatWasTapped)
                }
            } else {
                // If we are operating the quiz normally, update the labels
                updateLabels(viewThatWasTapped)
            }
        }
    }
    
    func updateLabels(viewThatWasTapped: UIView) {
        
        /* TODO: after a label is tapped, but before it's updated,
        save the new dict into the Parse database.  Upon completion of saving,
        then update the labels to reflect the new question
        This method will require a constant connection, so it's not ideal,
        but not sure how else to accomplish this at the moment.  
        Keeping this view with the other answers view in sync is proving 
        annoying.
        */
        
        // add and start spinner
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        spinner.center = self.view.center
        self.view.addSubview(spinner)
        spinner.startAnimating()
        
        currentUser?.setObject(questionsAnswered!, forKey: QuppledConstants.ParseUserAlreadyAnsweredQuestionsKey)
        currentUser?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
            if success == true {
                spinner.stopAnimating()
                self.currentQuestionIndex++
                if self.currentQuestionIndex >= self.questions.count {
                    print("NO MORE QUESTIONS!")
                    UIView.animateWithDuration(1.0) {
                        self.continueOverlayView.alpha = 1
                        self.view.layoutIfNeeded()
                    }
                }
                else {
                    // update question labels
                    self.currentQuestion = self.questions[self.currentQuestionIndex]
                    UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.TransitionCurlUp, animations: { () -> Void in
                        viewThatWasTapped.alpha = 0
                        }, completion: { [unowned self] (success: Bool) -> Void in
                            if success {
                                UIView.animateWithDuration(0.2) {
                                    viewThatWasTapped.alpha = 1
                                    self.topAnswerLabel.text = self.currentQuestion.answers[0]
                                    self.bottomAnswerLabel.text = self.currentQuestion.answers[1]
                                }
                            }
                        })
                }
            }
            if error != nil {
                print("failed with error: \(error!.localizedDescription)")
            }
        }) // End saveInBackground Block
        
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if let identifier = segue.identifier {
            if let tabBarController = sender?.destinationViewController as? UITabBarController {
                (tabBarController.viewControllers?.first as! HomeScreenCollectionViewController).seguedFrom = identifier
            }
        }
    }

}
