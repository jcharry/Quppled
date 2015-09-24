//
//  HomeScreenModel.swift
//  QuppledV5
//
//  Created by Jamie Charry on 7/13/15.
//  Copyright (c) 2015 Jamie Charry. All rights reserved.
//

import Foundation
import Parse

class HomeScreenModel {
    
    // TODO: implement fetching of top match for the day
    /* the fetching method must not fetch a previously suggested
    match.  Instead, all previously matched qupples should be 
    saved into an array and can be accessed via a different screen
    
    Maybe only show recent matches from the last week?
    */
    var currentUser: PFUser?
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var todaysMatch: PFUser? {
        didSet {
            
            // Post Notification to pass user to to the Home Screen VC
            let notificationCenter = NSNotificationCenter.defaultCenter()
            notificationCenter.postNotificationName(QuppledConstants.MatchIsSetNotificationName, object: self, userInfo: ["todaysUser": todaysMatch!])
            
        }
    }
    
    /* TODO: Fix this issue! I currently save today's user to NSUserDefaults.  But what that means is that without fetching a new user
    that user will ALWAYS be shown, until the new fetch request is set.  This means that if I log into the app on the same device,
    but as a different user, I'll get the match that is stored on the phone, even if that match is the logged in user. */
    
    /* TODO: implement a sorting algorithm to identify the top match from all users... not sure how to do this yet
        This probably should be done in the cloud - the app shouldn't handle this sorting */
    var users = [PFUser]()
    var previouslyMatchedUserEmails = [String]()
    
    func getTodaysMatch() {
        
        currentUser = PFUser.currentUser()
        
        // Check if a new fetch is required.  Query bool saved in User Defaults
        if let newFetchRequired = defaults.objectForKey(QuppledConstants.NewFetchRequiredDefaultsKey) as? Bool {
            if newFetchRequired == true {
                //FIXME: If all users have already been matched, this method throws an error!
                
                // First get all matches, then remove previously matched users
                // When we're done removing users, set todaysMatch, which will trigger
                // the VC to respond to the newly found user
                if let query = PFUser.query() {
//                    query.cachePolicy = PFCachePolicy.CacheElseNetwork
                    query.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) -> Void in
                        // Array is optional, so we must unwrap it first before iterating through it
                        if let objs = objects as? [PFUser] {
                            for obj in objs {
                                self.users.append(obj)
                            }
                        }
                        print("all users are \(self.users)")
                        // Remove all previously matched users from full list of users
                        self.removePreviouslyMatchedUsers()
                        
                        // Set today's match
                        // Ensure there are actually users left to match, if not, handle that case
                        if self.users.count != 0 {
                            self.todaysMatch = self.users[0]
                            print("today's matched user: \(self.todaysMatch)")

                            // append this match to previously matched array, so it can be uploaded back to Parse
                            self.previouslyMatchedUserEmails.append(self.todaysMatch!.email!)
                            self.currentUser?.setObject(self.previouslyMatchedUserEmails, forKey: ParseKeys.ParseUserPreviouslyMatchedUserEmailsKey)
                            self.currentUser?.saveInBackground()
                            
                            // store reference to todays user in NSUserDefaults
                            self.defaults.setObject(self.todaysMatch!.email, forKey: QuppledConstants.TodaysUsersEmailKey)
                        } else {
                            // TODO: DO SOMETHING WHEN THERE ARE NO MORE USERS TO MATCH!
                            print("no more users to match, ya dummy")
                            let notificationCenter = NSNotificationCenter.defaultCenter()
                            notificationCenter.postNotification(NSNotification(name: "noMatchesAvailable", object: self))
                            
                        }
                    })
                }
                
                // Set newFetchRequired to false, so the next load of the app presents the current match
                // instead of fetching more users
                defaults.setBool(false, forKey: QuppledConstants.NewFetchRequiredDefaultsKey)
            }
            else if newFetchRequired == false {
                // Load reference to user from NSUserDefaults
                // Fetch just that user from Parse database
                let todaysUserEmail = defaults.objectForKey(QuppledConstants.TodaysUsersEmailKey) as! String
                if let query = PFUser.query() {
                    query.whereKey("email", containsString: todaysUserEmail)
                    query.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) -> Void in
                        if let objs = objects {
                            for obj in objs {
                                self.todaysMatch = (obj as! PFUser)
                            }
                        }
                    })
                }
            }
        }
    }
    
    func removePreviouslyMatchedUsers() {
        if currentUser != nil {
            // first remove current user
            users.removeAtIndex(users.indexOf(currentUser!)!)
//            println("users are \(users)")
            
            if let oldMatches = currentUser!.objectForKey(ParseKeys.ParseUserPreviouslyMatchedUserEmailsKey) as? [String] {
                previouslyMatchedUserEmails = oldMatches
                print("previously matched user emails are: \(previouslyMatchedUserEmails)")
                var userIndex = 0
                for user in users {
                    print("user email is: \(user.email)")
                    if previouslyMatchedUserEmails.contains((user.email!)) {
                        users.removeAtIndex(users.indexOf(user)!)
                    }
                    userIndex++
                }
            }
        }
    }
    
    var commonAnswers = [String]()
    func determineMatchPercentage(userToMatch: PFUser) -> Int {
        commonAnswers.removeAll(keepCapacity: true)
        var counterIndex = 0
        var correctMatches = 0
        currentUser = PFUser.currentUser()
        
        if currentUser != nil {
            if let currentUserAnswers = currentUser!.objectForKey(ParseKeys.ParseUserAlreadyAnsweredQuestionsKey) as? [String:String], userAnswers = userToMatch.objectForKey(ParseKeys.ParseUserAlreadyAnsweredQuestionsKey) as? [String:String] {
                
                print("current answers are: \(currentUserAnswers)")
                print("matched user answers are: \(userAnswers)")
                
                for (question, answer) in currentUserAnswers {
                    if let userAnswer = userAnswers["\(question)"] {
                        // this will only fire when the current question is contained in the matched users dictionary of already answered questions
                        if answer == userAnswer {
                            correctMatches++
                            commonAnswers.append(answer)
                        }
                        counterIndex++
                    }
                }
                let percentage = (Float(correctMatches) / Float(counterIndex)) * 100
                let percAsInt = Int(percentage)
                print(commonAnswers)
                return percAsInt
            }
            
        }
        return 0
    }
    
    func pickThreeCommonAnswers() -> [String] {
        var commonAnswersCopy = commonAnswers
        // if array is 3 items or less, don't shuffle, just return
        if commonAnswersCopy.count < 4 {
            return commonAnswersCopy
        }
        
        for i in 0..<(commonAnswersCopy.count - 1) {
            let j = Int(arc4random_uniform(UInt32(commonAnswersCopy.count - i))) + i
            swap(&commonAnswersCopy[i], &commonAnswersCopy[j])
        }
        return commonAnswersCopy
    }
    
}
