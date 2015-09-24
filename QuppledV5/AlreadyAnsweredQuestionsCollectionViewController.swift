//
//  AlreadyAnsweredQuestionsCollectionViewController.swift
//  QuppledV5
//
//  Created by Jamie Charry on 7/15/15.
//  Copyright (c) 2015 Jamie Charry. All rights reserved.
//

import UIKit
import Parse

let reuseIdentifier = "Question Cell"

class AlreadyAnsweredQuestionsCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var currentUser: PFUser?
    
    let model = QuestionModel()
    var questionsDict = [String: (String, String)]()
    var myAnswersDict: [String: String]?
    var allAnswers = [[String]]()
    var myAnswers = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentUser = PFUser.currentUser()
        
        // Get all questions
        let questions = model.getQuestions(questionsAlreadyAnswered: [String:String](), removeQuestions: false)
//        println(questions)
        for question in questions {
            let questionNumber = question.questionNumber
            let firstAnswer = question.answers[0]
            let secondAnswer = question.answers[1]
            _ = [firstAnswer, secondAnswer]
            questionsDict[questionNumber] = (firstAnswer, secondAnswer)
            allAnswers.append([firstAnswer, secondAnswer])
        }
        
        // Get my answers
        myAnswersDict = currentUser?.objectForKey(QuppledConstants.ParseUserAlreadyAnsweredQuestionsKey) as? [String:String]
        
        if myAnswersDict != nil {
            for (_, answer) in myAnswersDict! {
                myAnswers.append(answer)
            }
        }
        
        // Register for notification
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "viewBroughtToFront", name: QuppledConstants.AlreadyAnsweredViewControllerBroughtToFront, object: nil)
        
//        println(myAnswers)
        
//        println(questionsDict)
//        println(answers)
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes,  All classes to be used MUST be registered or they will not be recognized
//        self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView!.registerClass(AlreadyAnsweredQuestionsCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }
    
    func viewBroughtToFront() {
        print("already answered view is visible! Load any changes!")
        // need to check model - if lenghts are not equal, update the view
        // TODO: Update the view so it matches the data... The code below does not work
        // because the newQuestions view does not save the object to PFUser appropriately
        // for me to just grab it here.  Not sure of the answer right yet.
        if let alreadyAnsweredQuestions = currentUser?.objectForKey(QuppledConstants.ParseUserAlreadyAnsweredQuestionsKey) as? [String:String] {
            if alreadyAnsweredQuestions.count != myAnswersDict?.count {
                // there is a mismatch
                print(alreadyAnsweredQuestions)
                print(myAnswersDict)
            }
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        return self.allAnswers.count
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }

//    var rowCounter = 0
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! AlreadyAnsweredQuestionsCollectionViewCell
        
        // Configure the cell
        let randInt = Int(arc4random() % 5)
        _ = UIColor.randomColor(randInt)
        
        // Cell Section refers to question number (or index of answers array), and Row refers to the answer item
        let answerText = allAnswers[indexPath.section][indexPath.row]
        
        // Check to see if answer text is contained in myAnswers array
        if myAnswers.contains(answerText) {
            // Identified cells that correspond to my chosen answers
            cell.backgroundColor = UIColor.greenColor()
        } else {
            cell.backgroundColor = UIColor.whiteColor()
        }
        
        cell.answerText = answerText
        
        cell.layer.cornerRadius = 10
    
        return cell
    }

    // MARK: UICollectionViewDelegate
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        // TODO: Start spinner
        
        // If the background color is green, then that answer has already been selected,
        // do nothing.  If it's not green, then lock the
        func completionBlock(success: Bool, error: NSError) {
            print("woo")
        }

        // Get section - the section corresponds to the question number
        let questionNumber = indexPath.section + 1
        if myAnswersDict != nil {
//            println("question\(questionNumber) : \(allAnswers[indexPath.section][indexPath.row])")
            myAnswersDict!["question\(questionNumber)"] = allAnswers[indexPath.section][indexPath.row]
            currentUser?.setObject(myAnswersDict!, forKey: QuppledConstants.ParseUserAlreadyAnsweredQuestionsKey)
            currentUser?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                if success == true {
                    //TODO: Stop spinner!
                    // Get the cell that was tapped
                    if let tappedCell = collectionView.cellForItemAtIndexPath(indexPath) as? AlreadyAnsweredQuestionsCollectionViewCell {
                        
                        var otherCell: AlreadyAnsweredQuestionsCollectionViewCell?
                        
                        // Get other cell in the section
                        let row = indexPath.row
                        switch row {
                        case 0:
                            // first item in section tapped
                            otherCell = collectionView.cellForItemAtIndexPath(NSIndexPath(forRow: 1, inSection: indexPath.section)) as? AlreadyAnsweredQuestionsCollectionViewCell
                        case 1:
                            // second item in section tapped
                            otherCell = collectionView.cellForItemAtIndexPath(NSIndexPath(forRow: 0, inSection: indexPath.section)) as? AlreadyAnsweredQuestionsCollectionViewCell
                        default: break
                        }
                        
                        if tappedCell.backgroundColor != UIColor.greenColor() {
                            tappedCell.backgroundColor = UIColor.greenColor()
                            if otherCell != nil {
                                otherCell!.backgroundColor = UIColor.whiteColor()
                            }
                        }
                    }
                } // END if success == true
                
                if error != nil {
                    print("couldn't save - with error <\(error?.localizedDescription)>")
                }
            })
            
        }
        
        
    }

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
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
//        return 5
//    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width/2, height: 50)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 5, right: 0)
    }

}

extension UIColor {
    class func randomColor(seed: Int) -> UIColor {
        switch seed {
        case 0:
            return UIColor.greenColor()
        case 1:
            return UIColor.orangeColor()
        case 2:
            return UIColor.cyanColor()
        case 3:
            return UIColor.redColor()
        case 4:
            return UIColor.purpleColor()
        default:
            return UIColor.whiteColor()
        }
    }
}
